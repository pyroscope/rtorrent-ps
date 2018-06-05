// PyroScope - rTorrent Command Extensions
// Copyright (c) 2011 The PyroScope Project <pyroscope.project@gmail.com>
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along
// with this program; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

#include "config.h"
#include "globals.h"

#include <cstdio>
#include <climits>
#include <ctime>
#include <cwchar>
#include <set>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <rak/path.h>
#include <rak/algorithm.h>
#include <rak/functional.h>
#include <rak/functional_fun.h>

#include "core/download.h"
#include "core/manager.h"
#include "core/view_manager.h"
#include "rpc/parse.h"
#include "torrent/tracker.h"
#include "torrent/tracker_list.h"
#include "ui/root.h"
#include "ui/download_list.h"
#include "ui/element_base.h"
#include "ui/element_download_list.h"

#include "globals.h"
#include "control.h"
#include "command_helpers.h"


// In 0.9.x this changed to 'tr1' (dropping sigc::bind), see https://stackoverflow.com/a/4682954/2748717
// "C++ Technical Report 1" was later added to "C++11", using tr1 makes stuff compile on older GCC
#define _cxxstd_ tr1

// List of system capabilities for `system.has` command
static std::set<std::string> system_capabilities;

// handle for message log file
namespace core {
int log_messages_fd = -1;
};


#if RT_HEX_VERSION <= 0x000906
// will be merged into 0.9.7+ mainline!

namespace torrent {

/*  uniform_rng - Uniform distribution random number generator.

    This class implements a no-shared-state random number generator that
    emits uniformly distributed numbers with high entropy. It solves the
    two problems of a simple `random() % limit`, which is a skewed
    distribution due to RAND_MAX typically not being evenly divisble by
    the limit, and worse, the lower bits of typical PRNGs having extremly
    low entropy – the end result are grossly un-random number sequences.

    A `uniform_rng` instance carries its own state, unlike the `random()`
    function, and is thus thread-safe when no instance is shared between
    threads. It uses `random_r()` and `initstate_r()` from glibc.
 */
class uniform_rng {
public:
    uniform_rng();

    int rand();
    int rand_range(int lo, int hi);
    int rand_below(int limit) { return this->rand_range(0, limit-1); }

private:
    char m_state[128];
    struct ::random_data m_data;
};


uniform_rng::uniform_rng() {
    unsigned int seed = cachedTime.usec() ^ (getpid() << 16) ^ getppid();
    ::initstate_r(seed, m_state, sizeof(m_state), &m_data);
}

// return random number in interval [0, RAND_MAX]
int uniform_rng::rand()
{
    int rval;
    if (::random_r(&m_data, &rval) == -1) {
        throw torrent::input_error("system.random: random_r() failure!");
    }
    return rval;
}

// return random number in interval [lo, hi]
int uniform_rng::rand_range(int lo, int hi)
{
    if (lo > hi) {
        throw torrent::input_error("Empty interval passed to rand_range (low > high)");
    }
    if (lo < 0 || RAND_MAX < lo) {
        throw torrent::input_error("Lower bound of rand_range outside 0..RAND_MAX");
    }
    if (hi < 0 || RAND_MAX < hi) {
        throw torrent::input_error("Upper bound of rand_range outside 0..RAND_MAX");
    }

    int rval;
    const int64_t range   = 1 + hi - lo;
    const int64_t buckets = RAND_MAX / range;
    const int64_t limit   = buckets * range;

    /* Create equal size buckets all in a row, then fire randomly towards
     * the buckets until you land in one of them. All buckets are equally
     * likely. If you land off the end of the line of buckets, try again. */
    do {
        rval = this->rand();
    } while (rval >= limit);

    return (int) (lo + (rval / buckets));
}

}; // namespace torrent


static torrent::uniform_rng system_random_gen;

/*  @DOC
    `system.random = [[<lower>,] <upper>]`

    Generate *uniformly* distributed random numbers in the range
    defined by `lower`..`upper`.

    The default range with no args is `0`..`RAND_MAX`. Providing
    just one argument sets an *exclusive* upper bound, and two
    args define an *inclusive*  range.

    An example use-case is adding jitter to time values that you
    later check with `elapsed.greater`, to avoid load spikes and
    similar effects of clustered time triggers.
*/
torrent::Object apply_random(rpc::target_type target, const torrent::Object::list_type& args) {
    int64_t lo = 0, hi = RAND_MAX;

    torrent::Object::list_const_iterator itr = args.begin();
    if (args.size() > 2) {
        throw torrent::input_error("system.random accepts at most two arguments!");
    }
    if (args.size() > 1) {
        lo = (itr++)->as_value();
        hi = (itr++)->as_value();
    } else if (args.size() > 0) {
        hi = (itr++)->as_value() - 1;
    }

    return (int64_t) system_random_gen.rand_range(lo, hi);
}

// #else
// #include "torrent/utils/uniform_rng.h"
#endif


// return the "main" tracker for this download item
torrent::Tracker* get_active_tracker(torrent::Download* item) {
    torrent::TrackerList* tl = item->tracker_list();
    torrent::Tracker* tracker = 0;

    for (size_t trkidx = 0; trkidx < tl->size(); trkidx++) {
        tracker = tl->at(trkidx);
        if (tracker->is_usable() && tracker->type() == torrent::Tracker::TRACKER_HTTP
                && tracker->scrape_complete() + tracker->scrape_incomplete() > 0) {
            break;
        }
        tracker = 0;
    }
    if (!tracker && tl->size()) tracker = tl->at(0);

    return tracker;
}


// return the domain name of the "main" tracker of the given download item
std::string get_active_tracker_domain(torrent::Download* item) {
    std::string url;
    torrent::Tracker* tracker = get_active_tracker(item);

    if (tracker && !tracker->url().empty()) {
        url = tracker->url();

        // snip url to domain name
        if (url.compare(0, 7, "http://")  == 0) url = url.substr(7);
        if (url.compare(0, 8, "https://") == 0) url = url.substr(8);
        if (url.find('/') > 0) url = url.substr(0, url.find('/'));
        if (url.find(':') > 0) url = url.substr(0, url.find(':'));

        // remove some common cruft
        const char* domain_cruft[] = {
            "tracker", "1.", "2.", "001.", ".",
            "www.", "cfdata.",
            0
        };
        for (const char** cruft = domain_cruft; *cruft; cruft++) {
            int cruft_len = strlen(*cruft);
            if (url.compare(0, cruft_len, *cruft) == 0) url = url.substr(cruft_len);
        }
    }

    return url;
}


// return various scrape information of the "main" tracker for this download item
int64_t get_active_tracker_scrape_info(const int operation, torrent::Download* item) {
    int64_t scrape_num = 0;
    torrent::Tracker* tracker = get_active_tracker(item);

    if (tracker) {
        switch (operation) {
            case 1:
                scrape_num = tracker->scrape_downloaded();
                break;
            case 2:
                scrape_num = tracker->scrape_complete();
                break;
            case 3:
                scrape_num = tracker->scrape_incomplete();
                break;
        }
    }

    return scrape_num;
}


/*  @DOC
    `compare = <order>, <sort_key>=[, ...]`

    Compares two items like `less=` or `greater=`, but allows to compare
    by several different sort criteria, and ascending or descending
    order per given field. The first parameter is a string of order
    indicators, either `aA+` for ascending or `dD-` for descending.
    The default, i.e. when there's more fields than indicators, is
    ascending. Field types other than value or string are treated
    as equal (or in other words, they're ignored).

    If all fields are equal, then items are ordered in a random, but
    stable fashion.

    Configuration example:

        # VIEW: Show active and incomplete torrents (in view #9) and update every 20 seconds
        #       Items are grouped into complete, incomplete, and queued, in that order.
        #       Within each group, they're sorted by upload and then download speed.
        view.sort_current = active,"compare=----,d.is_open=,d.complete=,d.up.rate=,d.down.rate="
        schedule = filter_active,12,20,"view.filter = active,\"or={d.up.rate=,d.down.rate=,not=$d.complete=}\" ;view.sort=active"
*/
torrent::Object apply_compare(rpc::target_type target, const torrent::Object::list_type& args) {
    if (!rpc::is_target_pair(target))
        throw torrent::input_error("Can only compare a target pair.");

    if (args.size() < 2)
        throw torrent::input_error("Need at least order and one field.");

    torrent::Object::list_const_iterator itr = args.begin();
    std::string order = (itr++)->as_string();
    const char* current = order.c_str();

    torrent::Object result1;
    torrent::Object result2;

    for (torrent::Object::list_const_iterator last = args.end(); itr != last; itr++) {
        std::string field = itr->as_string();
        result1 = rpc::parse_command_single(rpc::get_target_left(target), field);
        result2 = rpc::parse_command_single(rpc::get_target_right(target), field);

        if (result1.type() != result2.type())
            throw torrent::input_error(std::string("Type mismatch in compare of ") + field);

        bool descending = *current == 'd' || *current == 'D' || *current == '-';
        if (*current) {
            if (!descending && !(*current == 'a' || *current == 'A' || *current == '+'))
                throw torrent::input_error(std::string("Bad order '") + *current + "' in " + order);
            ++current;
        }

        switch (result1.type()) {
            case torrent::Object::TYPE_VALUE:
                if (result1.as_value() != result2.as_value())
                    return (int64_t) (descending ^ (result1.as_value() < result2.as_value()));
                break;

            case torrent::Object::TYPE_STRING:
                if (result1.as_string() != result2.as_string())
                    return (int64_t) (descending ^ (result1.as_string() < result2.as_string()));
                break;

            default:
                break; // treat unknown types as equal
        }
    }

    // if all else is equal, ensure stable sort order based on memory location
    return (int64_t) (target.second < target.third);
}


static std::map<int, std::string> bound_commands[ui::DownloadList::DISPLAY_MAX_SIZE];

/*  @DOC
    ui.bind_key=display,key,"command1=[,...]"

        Binds the given key on a specified display to execute the commands when pressed.

        "display" must be one of "download_list", ...
        "key" can be either a single character for normal keys,
            ^ plus a character for control keys, or a 4 digit octal key code.

        Configuration example:
            # VIEW: Bind view #7 to the "rtcontrol" result
            schedule = bind_7,1,0,"ui.bind_key=download_list,7,ui.current_view.set=rtcontrol"
*/
torrent::Object apply_ui_bind_key(rpc::target_type target, const torrent::Object& rawArgs) {
    const torrent::Object::list_type& args = rawArgs.as_list();

    if (args.size() != 3)
        throw torrent::input_error("Expecting display, key, and commands.");

    // Parse positional arguments
    torrent::Object::list_const_iterator itr = args.begin();
    const std::string& element  = (itr++)->as_string();
    const std::string& keydef   = (itr++)->as_string();
    const std::string& commands = (itr++)->as_string();
    const bool verbose = rpc::call_command_value("ui.bind_key.verbose");

    // Get key index from definition
    if (keydef.empty() || keydef.size() > (keydef[0] == '0' ? 4 : keydef[0] == '^' ? 2 : 1))
        throw torrent::input_error("Bad key definition.");
    int key = keydef[0];
    if (key == '^' && keydef.size() > 1) key = keydef[1] & 31;
    if (key == '0' && keydef.size() != 1) {
        if (keydef.size() != 4)
            throw torrent::input_error("Bad key definition (expected 4 digit octal code).");
        key = (int) strtol(keydef.c_str(), (char **) NULL, 8);
    }

    // Look up display
    ui::DownloadList::Display displayType = ui::DownloadList::DISPLAY_MAX_SIZE;
    if (element == "download_list") {
        displayType = ui::DownloadList::DISPLAY_DOWNLOAD_LIST;
    } else {
        throw torrent::input_error(std::string("Unknown display ") + element);
    }
    ui::DownloadList* dl_list = control->ui()->download_list();
    if (!dl_list)
        throw torrent::input_error("No download list.");
    ui::ElementBase* display = dl_list->display(displayType);
    if (!display)
        throw torrent::input_error("Display not found.");

    // Bind the key to the given commands
    bool new_binding = display->bindings().find(key) == display->bindings().end();
    bound_commands[displayType][key] = commands; // keep hold of the string, so the c_str() below remains valid
    switch (displayType) {
        case ui::DownloadList::DISPLAY_DOWNLOAD_LIST:
            display->bindings()[key] =
                _cxxstd_::bind(&ui::ElementDownloadList::receive_command, (ui::ElementDownloadList*)display,
                               bound_commands[displayType][key].c_str());
            break;
        default:
            return torrent::Object();
    }

    if (!new_binding && verbose) {
        std::string msg = "Replaced key binding";
        msg += " for " + keydef + " in " + element + " with " + commands.substr(0, 30);
        if (commands.size() > 30) msg += "...";
        control->core()->push_log(msg.c_str());
    }

    return torrent::Object();
}


torrent::Object cmd_ui_focus_home() {
    ui::DownloadList* dl_list = control->ui()->download_list();
    core::View* dl_view = dl_list->current_view();

    if (!dl_view->empty_visible()) {
        dl_view->set_focus(dl_view->begin_visible());
        dl_view->set_last_changed();
    }

    return torrent::Object();
}


torrent::Object cmd_ui_focus_end() {
    ui::DownloadList* dl_list = control->ui()->download_list();
    core::View* dl_view = dl_list->current_view();

    if (!dl_view->empty_visible()) {
        dl_view->set_focus(dl_view->end_visible() - 1);
        dl_view->set_last_changed();
    }

    return torrent::Object();
}


static int ui_page_size() {
    // TODO: map 0 to the current view size, for adaptive scrolling
    return std::max(1, (int) rpc::call_command_value("ui.focus.page_size"));
}


torrent::Object cmd_ui_focus_pgup() {
    ui::DownloadList* dl_list = control->ui()->download_list();
    core::View* dl_view = dl_list->current_view();

    int skip = ui_page_size();
    if (!dl_view->empty_visible()) {
        if (dl_view->focus() == dl_view->end_visible())
            dl_view->set_focus(dl_view->end_visible() - 1);
        else if (dl_view->focus() - dl_view->begin_visible() >= skip)
            dl_view->set_focus(dl_view->focus() - skip);
        else
            dl_view->set_focus(dl_view->begin_visible());
        dl_view->set_last_changed();
    }

    return torrent::Object();
}


torrent::Object cmd_ui_focus_pgdn() {
    ui::DownloadList* dl_list = control->ui()->download_list();
    core::View* dl_view = dl_list->current_view();

    int skip = ui_page_size();
    if (!dl_view->empty_visible()) {
        if (dl_view->focus() == dl_view->end_visible())
            dl_view->set_focus(dl_view->begin_visible());
        else if (dl_view->end_visible() - dl_view->focus() > skip)
            dl_view->set_focus(dl_view->focus() + skip);
        else
            dl_view->set_focus(dl_view->end_visible() - 1);
        dl_view->set_last_changed();
    }

    return torrent::Object();
}


torrent::Object cmd_log_messages(const torrent::Object::string_type& arg) {
    if (arg.empty()) {
        control->core()->push_log_std("Closing message log file.");
    }

    if (core::log_messages_fd >= 0) {
        ::close(core::log_messages_fd);
        core::log_messages_fd = -1;
    }

    if (!arg.empty()) {
        core::log_messages_fd = open(rak::path_expand(arg).c_str(), O_WRONLY | O_APPEND | O_CREAT, 0644);

        if (core::log_messages_fd < 0) {
            throw torrent::input_error("Could not open message log file.");
        }

        control->core()->push_log_std("Opened message log file '" + rak::path_expand(arg) + "'.");
    }

    return torrent::Object();
}


torrent::Object cmd_import_return(rpc::target_type target, const torrent::Object& args) {
    // Handled in src/rpc/parse_commands.cc::parse_command_file via patch
    throw torrent::input_error("import.return");
}


torrent::Object retrieve_d_custom_if_z(core::Download* download, const torrent::Object::list_type& args) {
    torrent::Object::list_const_iterator itr = args.begin();
    if (itr == args.end())
        throw torrent::bencode_error("d.custom.if_z: Missing key argument.");
    const std::string& key = (itr++)->as_string();
    if (key.empty())
        throw torrent::bencode_error("d.custom.if_z: Empty key argument.");
    if (itr == args.end())
        throw torrent::bencode_error("d.custom.if_z: Missing default argument.");

    try {
        return download->bencode()->get_key("rtorrent").get_key("custom").get_key_string(key);
    } catch (torrent::bencode_error& e) {
        return itr->as_string();
    }
}


torrent::Object retrieve_d_custom_map(core::Download* download, bool keys_only, const torrent::Object::list_type& args) {
    if (args.begin() != args.end())
        throw torrent::bencode_error("d.custom.keys/items takes no arguments.");

    torrent::Object result = keys_only ? torrent::Object::create_list() : torrent::Object::create_map();
    torrent::Object::map_type& entries = download->bencode()->get_key("rtorrent").get_key("custom").as_map();

    for (torrent::Object::map_type::const_iterator itr = entries.begin(), last = entries.end(); itr != last; itr++) {
        if (keys_only) result.as_list().push_back(itr->first);
        else           result.as_map()[itr->first] = itr->second;
    }

    return result;
}


torrent::Object
d_multicall_filtered(const torrent::Object::list_type& args) {
  if (args.size() < 2)
    throw torrent::input_error("d.multicall.filtered requires at least 2 arguments.");
  torrent::Object::list_const_iterator arg = args.begin();

  // Find the given view
  core::ViewManager* viewManager = control->view_manager();
  core::ViewManager::iterator viewItr;

  if (!arg->as_string().empty())
    viewItr = viewManager->find(arg->as_string());
  else
    viewItr = viewManager->find("default");

  if (viewItr == viewManager->end())
    throw torrent::input_error("Could not find view '" + arg->as_string() + "'.");

  // Make a filtered copy of the current item list
  core::View::base_type dlist;
  (*viewItr)->filter_by(*++arg, dlist);

  // Generate result by iterating over all items
  torrent::Object             resultRaw = torrent::Object::create_list();
  torrent::Object::list_type& result = resultRaw.as_list();
  ++arg;  // skip to first command

  for (core::View::iterator item = dlist.begin(); item != dlist.end(); ++item) {
    // Add empty row to result
    torrent::Object::list_type& row = result.insert(result.end(), torrent::Object::create_list())->as_list();

    // Call the provided commands and assemble their results
    for (torrent::Object::list_const_iterator command = arg; command != args.end(); command++) {
      const std::string& cmdstr = command->as_string();
      row.push_back(rpc::parse_command(rpc::make_target(*item), cmdstr.c_str(), cmdstr.c_str() + cmdstr.size()).first);
    }
  }

  return resultRaw;
}


/*  throttle.names=

    Returns a list of all defined throttle names,
    including the built-in ones (i.e. '' and NULL).

    https://github.com/pyroscope/rtorrent-ps/issues/65
 */
torrent::Object cmd_throttle_names() {
    torrent::Object result = torrent::Object::create_list();
    torrent::Object::list_type& resultList = result.as_list();

    resultList.push_back(std::string());
    for (core::ThrottleMap::const_iterator itr = control->core()->throttles().begin();
         itr != control->core()->throttles().end(); itr++) {
       resultList.push_back(itr->first);
    }

    return result;
}


static const std::string& string_get_first_arg(const char* name, const torrent::Object::list_type& args) {
    if (args.size() < 1) {
        throw torrent::input_error("string." + std::string(name) + " needs a string argument!");
    }
    torrent::Object::list_const_iterator itr = args.begin();
    return itr->as_string();
}


static int64_t string_get_value_arg(const char* name, torrent::Object::list_const_iterator& itr) {
    int64_t result = 0;
    if (itr->is_string()) {
        char* junk = 0;
        result = strtol(itr->as_string().c_str(), &junk, 10);
        if (*junk) {
            throw torrent::input_error("string." + std::string(name) + ": "
                                       "junk at end of value: " + itr->as_string());
        }
    } else {
        result = itr->as_value();
    }

    ++itr;
    return result;
}


torrent::Object cmd_string_len(rpc::target_type target, const torrent::Object::list_type& args) {
    std::mbstate_t mbs = std::mbstate_t();
    std::string text = string_get_first_arg("len", args);
    const char* pos = text.c_str();
    int glyphs = 0, bytes = 0, skip;

    while (*pos && (skip = std::mbrlen(pos, text.length() - bytes, &mbs)) > 0) {
        pos += skip;
        bytes += skip;
        ++glyphs;
    }

    return (int64_t) glyphs;
}


torrent::Object cmd_string_substr(rpc::target_type target, const torrent::Object::list_type& args) {
    const std::string text = string_get_first_arg("substr", args);

    torrent::Object::list_const_iterator itr = args.begin() + 1;
    int64_t glyphs = 0, count = text.length();
    std::string fallback;
    if (itr != args.end()) glyphs = string_get_value_arg("substr(pos)", itr);
    if (itr != args.end()) count = string_get_value_arg("substr(count)", itr);
    if (itr != args.end()) fallback = (itr++)->as_string();

    if (count < 0) {
       throw torrent::input_error("string.substr: Invalid negative count!");
    }

    std::mbstate_t mbs = std::mbstate_t();
    const char* pos = text.c_str();
    int bytes = 0, skip;

    if (glyphs < 0) {
        std::string::size_type offsets[text.length() + 1];
        int64_t idx = 0;
        while (*pos && (skip = std::mbrlen(pos, text.length() - bytes, &mbs)) > 0) {
            offsets[idx++] = bytes;
            pos += skip;
            bytes += skip;
        }
        offsets[idx] = bytes;

        int64_t begidx = std::max(idx + glyphs, (int64_t) 0);
        int64_t endidx = std::min(idx, begidx + count);
        return text.substr(offsets[begidx], offsets[endidx] - offsets[begidx]);
    }

    while (glyphs-- > 0 && *pos && (skip = std::mbrlen(pos, text.length() - bytes, &mbs)) > 0) {
        pos += skip;
        bytes += skip;
    }
    if (!*pos) return fallback;

    int bytes_pos = bytes, bytes_count = 0;
    while (count-- > 0 && *pos && (skip = std::mbrlen(pos, text.length() - bytes, &mbs)) > 0) {
        pos += skip;
        bytes += skip;
        bytes_count += skip;
    }

    return text.substr(bytes_pos, bytes_count);
}


torrent::Object::value_type apply_string_contains(bool ignore_case, const torrent::Object::list_type& args) {
    if (args.size() < 2) {
        throw torrent::input_error("string.contains[_i] takes at least two arguments!");
    }

    torrent::Object::list_const_iterator itr = args.begin();
    std::string text = itr->as_string();
    if (ignore_case)
        std::transform(text.begin(), text.end(), text.begin(), ::tolower);

    for (++itr; itr != args.end(); ++itr) {
        std::string substr = itr->as_string();
        if (ignore_case)
            std::transform(substr.begin(), substr.end(), substr.begin(), ::tolower);
        if (substr.empty() || text.find(substr) != std::string::npos)
            return 1;
    }

    return 0;
}


torrent::Object cmd_string_contains(rpc::target_type target, const torrent::Object::list_type& args) {
    return apply_string_contains(false, args);
}

// XXX: Will NOT work correctly for non-ASCII strings!
torrent::Object cmd_string_contains_i(rpc::target_type target, const torrent::Object::list_type& args) {
    return apply_string_contains(true, args);
}


torrent::Object apply_string_mutate(int operation, const torrent::Object::list_type& args) {
    if (args.size() < 1) {
        throw torrent::input_error("string.* takes at least a string!");
    }

    torrent::Object::list_const_iterator itr = args.begin();
    std::string result = itr->as_string();

    for (++itr; itr != args.end(); ++itr) {
        std::string needle = itr->as_list().begin()->as_string();
        std::string subst = itr->as_list().rbegin()->as_string();

        switch (operation) {
        case 1:
            if (result == needle)
                result = subst;
            break;
        case 2:
            for (size_t pos = 0; (pos = result.find(needle, pos)) != std::string::npos; pos += subst.length()) {
                result.replace(pos, needle.length(), subst);
            }
            break;
        }
    }

    return result;
}

torrent::Object cmd_string_map(rpc::target_type target, const torrent::Object::list_type& args) {
    return apply_string_mutate(1, args);
}

torrent::Object cmd_string_replace(rpc::target_type target, const torrent::Object::list_type& args) {
    return apply_string_mutate(2, args);
}


torrent::Object cmd_array_at(rpc::target_type target, const torrent::Object::list_type& args) {
    if (args.size() != 2) {
        throw torrent::input_error("array.at takes at exactly two arguments!");
    }

    torrent::Object::list_const_iterator itr = args.begin();
    torrent::Object::list_type array = (itr++)->as_list();
    torrent::Object::value_type index = (itr++)->as_value();

    if (array.empty()) {
        throw torrent::input_error("array.at: array is empty!");
    }
    if (index < 0 || int(array.size()) <= index) {
        throw torrent::input_error("array.at: index out of bounds!");
    }

    return array.at(index);
}


void add_capability(const char* name) {
    system_capabilities.insert(name);
}


torrent::Object cmd_system_has(const torrent::Object::string_type& arg) {
    if (arg.empty()) {
        throw torrent::input_error("Passed empty string to 'system.has'!");
    }

    bool result = (system_capabilities.count(arg) != 0);
    if (!result && '=' == arg.at(arg.size()-1)) {
        result = rpc::commands.has(arg.substr(0, arg.size()-1));
    }
    return (int64_t) result;
}


torrent::Object cmd_system_has_list() {
    torrent::Object result = torrent::Object::create_list();
    torrent::Object::list_type& resultList = result.as_list();

    for (std::set<std::string>::const_iterator itr = system_capabilities.begin(); itr != system_capabilities.end(); itr++) {
       resultList.push_back(*itr);
    }

    return result;
}


torrent::Object cmd_system_has_methods(bool filter_public) {
    torrent::Object result = torrent::Object::create_list();
    torrent::Object::list_type& resultList = result.as_list();

    for (rpc::CommandMap::const_iterator itr = rpc::commands.begin(), last = rpc::commands.end(); itr != last; itr++) {
        if (bool(itr->second.m_flags & rpc::CommandMap::flag_public_xmlrpc) == filter_public) {
            resultList.push_back(itr->first);
        }
    }

    return result;
}


torrent::Object cmd_value(rpc::target_type target, const torrent::Object::list_type& args) {
    if (args.size() < 1) {
        throw torrent::input_error("'value' takes at least a number argument!");
    }
    if (args.size() > 2) {
        throw torrent::input_error("'value' takes at most two arguments!");
    }

    torrent::Object::value_type val = 0;
    if (args.front().is_value()) {
        val = args.front().as_value();
    } else {
        int base = args.size() > 1 ? args.back().is_value() ?
                   args.back().as_value() : strtol(args.back().as_string().c_str(), NULL, 10) : 10;
        char* endptr = 0;

        val = strtoll(args.front().as_string().c_str(), &endptr, base);
        while (*endptr == ' ' || *endptr == '\n') ++endptr;
        if (*endptr) {
            throw torrent::input_error("Junk at end of number: " + args.front().as_string());
        }
    }

    return val;
}


torrent::Object cmd_d_tracker_domain(core::Download* download) {
    return get_active_tracker_domain(download->download());
}


torrent::Object cmd_d_tracker_scrape_info(const int operation, core::Download* download) {
    return get_active_tracker_scrape_info(operation, download->download());
}


// MATH FUNCTIONS

inline std::vector<int64_t> as_vector(const torrent::Object::list_type& args) {
    if (args.size() == 0)
        throw torrent::input_error("Wrong argument count in as_vector.");

    std::vector<int64_t> result;

    for (torrent::Object::list_const_iterator itr = args.begin(), last = args.end(); itr != last; itr++) {
        if (itr->is_value()) {
            result.push_back(itr->as_value());
        } else if (itr->is_string()) {
            result.push_back(rpc::convert_to_value(itr->as_string()));
        } else if (itr->is_list()) {
            std::vector<int64_t> subResult = as_vector(itr->as_list());
            result.insert(result.end(), subResult.begin(), subResult.end());
        } else {
            throw torrent::input_error("Wrong type supplied to as_vector.");
        }
    }

    return result;
}


int64_t apply_math_basic(const char* name, const std::function<int64_t(int64_t,int64_t)> op,
                         const torrent::Object::list_type& args) {
    int64_t val = 0, rhs = 0;
    bool divides = !strcmp(name, "math.div") || !strcmp(name, "math.mod");

    if (args.size() == 0)
        throw torrent::input_error(std::string(name) + ": No arguments provided!");

    for (torrent::Object::list_const_iterator itr = args.begin(), last = args.end(); itr != last; itr++) {
        if (itr->is_value()) {
            rhs = itr->as_value();
        } else if (itr->is_string()) {
            rhs = rpc::convert_to_value(itr->as_string());
        } else if (itr->is_list()) {
            rhs = apply_math_basic(name, op, itr->as_list());
        } else {
            throw torrent::input_error(std::string(name) + ": Wrong argument type");
        }

        if (divides && !rhs && itr != args.begin())
            throw torrent::input_error(std::string(name) + ": Division by zero!");
        val = itr == args.begin() ? rhs : op(val, rhs);
    }

    return val;
}


int64_t apply_arith_basic(const std::function<int64_t(int64_t,int64_t)> op,
                          const torrent::Object::list_type& args) {
    if (args.size() == 0)
        throw torrent::input_error("Wrong argument count in apply_arith_basic.");

    int64_t val = 0;

    for (torrent::Object::list_const_iterator itr = args.begin(), last = args.end(); itr != last; itr++) {
        if (itr->is_value()) {
            val = itr == args.begin() ? itr->as_value()
                                      : (op(val, itr->as_value()) ? val : itr->as_value());
        } else if (itr->is_string()) {
            int64_t cval = rpc::convert_to_value(itr->as_string());
            val = itr == args.begin() ? cval : (op(val, cval) ? val : cval);
        } else if (itr->is_list()) {
            int64_t fval = apply_arith_basic(op, itr->as_list());
            val = itr == args.begin() ? fval : (op(val, fval) ? val : fval);
        } else {
            throw torrent::input_error("Wrong type supplied to apply_arith_basic.");
        }
    }

    return val;
}


int64_t apply_arith_count(const torrent::Object::list_type& args) {
    if (args.size() == 0)
        throw torrent::input_error("Wrong argument count in apply_arith_count.");

    int64_t val = 0;

    for (torrent::Object::list_const_iterator itr = args.begin(), last = args.end(); itr != last; itr++) {
        switch (itr->type()) {
            case torrent::Object::TYPE_VALUE:
            case torrent::Object::TYPE_STRING:
                val++;
                break;
            case torrent::Object::TYPE_LIST:
                val += apply_arith_count(itr->as_list());
                break;
            default:
                throw torrent::input_error("Wrong type supplied to apply_arith_count.");
        }
    }

    return val;
}

int64_t apply_arith_other(const char* op, const torrent::Object::list_type& args) {
    if (args.size() == 0)
        throw torrent::input_error("Wrong argument count in apply_arith_other.");

    if (strcmp(op, "average") == 0) {
        return (int64_t)(apply_math_basic(op, std::plus<int64_t>(), args) / apply_arith_count(args));
    } else if (strcmp(op, "median") == 0) {
        std::vector<int64_t> result = as_vector(args);
        return (int64_t)rak::median(result.begin(), result.end());
    } else {
        throw torrent::input_error("Wrong operation supplied to apply_arith_other.");
    }
}


#if RT_HEX_VERSION <= 0x000906
// https://github.com/rakshasa/rtorrent/commit/1f5e4d37d5229b63963bb66e76c07ec3e359ecba
torrent::Object cmd_system_env(const torrent::Object::string_type& arg) {
    if (arg.empty()) {
        throw torrent::input_error("system.env: Missing variable name.");
    }

    char* val = getenv(arg.c_str());
    return std::string(val ? val : "");
}

// https://github.com/rakshasa/rtorrent/commit/30d8379391ad4cb3097d57aa56a488d061e68662
torrent::Object cmd_ui_current_view() {
    ui::DownloadList* dl = control->ui()->download_list();
    core::View* view = dl ? dl->current_view() : 0;
    return view ? view->name() : std::string();
}
#endif


void initialize_command_pyroscope() {
    /*
        *_ANY – no arguments (signature `cmd_*()`)
        *_ANY_P – the 'P' means 'private'
        *_STRING – takes (one?) string argument
        *_LIST – takes any number of arguments
        *_DL, *_DL_LIST – function gets a `core::Download*` as first parameter
        *_VAR_VALUE – define a value, with getter and setter, and a default
    */

#if RT_HEX_VERSION <= 0x000906
    // these are merged into 0.9.7+ mainline! (well, maybe, PRs are ignored)
    CMD2_ANY_STRING("system.env", _cxxstd_::bind(&cmd_system_env, _cxxstd_::placeholders::_2));
    CMD2_ANY("ui.current_view", _cxxstd_::bind(&cmd_ui_current_view));
    CMD2_ANY_LIST("system.random", &apply_random);
    CMD2_ANY_LIST("d.multicall.filtered", _cxxstd_::bind(&d_multicall_filtered, _cxxstd_::placeholders::_2));
#endif

    // string.* group
    CMD2_ANY_LIST("string.len", &cmd_string_len);
    CMD2_ANY_LIST("string.substr", &cmd_string_substr);
    CMD2_ANY_LIST("string.contains", &cmd_string_contains);
    CMD2_ANY_LIST("string.contains_i", &cmd_string_contains_i);
    CMD2_ANY_LIST("string.map", &cmd_string_map);
    CMD2_ANY_LIST("string.replace", &cmd_string_replace);

    // array.* group
    CMD2_ANY_LIST("array.at", &cmd_array_at);

    // math.* group
    CMD2_ANY_LIST("math.add", std::bind(&apply_math_basic, "math.add", std::plus<int64_t>(), std::placeholders::_2));
    CMD2_ANY_LIST("math.sub", std::bind(&apply_math_basic, "math.sub", std::minus<int64_t>(), std::placeholders::_2));
    CMD2_ANY_LIST("math.mul", std::bind(&apply_math_basic, "math.mul", std::multiplies<int64_t>(), std::placeholders::_2));
    CMD2_ANY_LIST("math.div", std::bind(&apply_math_basic, "math.div", std::divides<int64_t>(), std::placeholders::_2));
    CMD2_ANY_LIST("math.mod", std::bind(&apply_math_basic, "math.mod", std::modulus<int64_t>(), std::placeholders::_2));
    CMD2_ANY_LIST("math.min", std::bind(&apply_arith_basic, std::less<int64_t>(), std::placeholders::_2));
    CMD2_ANY_LIST("math.max", std::bind(&apply_arith_basic, std::greater<int64_t>(), std::placeholders::_2));
    CMD2_ANY_LIST("math.cnt", std::bind(&apply_arith_count, std::placeholders::_2));
    CMD2_ANY_LIST("math.avg", std::bind(&apply_arith_other, "average", std::placeholders::_2));
    CMD2_ANY_LIST("math.med", std::bind(&apply_arith_other, "median", std::placeholders::_2));

    // ui.focus.* – quick paging
    CMD2_ANY("ui.focus.home", _cxxstd_::bind(&cmd_ui_focus_home));
    CMD2_ANY("ui.focus.end", _cxxstd_::bind(&cmd_ui_focus_end));
    CMD2_ANY("ui.focus.pgup", _cxxstd_::bind(&cmd_ui_focus_pgup));
    CMD2_ANY("ui.focus.pgdn", _cxxstd_::bind(&cmd_ui_focus_pgdn));
    CMD2_VAR_VALUE("ui.focus.page_size", 50);

    // system.has.*
    CMD2_ANY_STRING("system.has", _cxxstd_::bind(&cmd_system_has, _cxxstd_::placeholders::_2));
    CMD2_ANY("system.has.list", _cxxstd_::bind(&cmd_system_has_list));
    CMD2_ANY("system.has.private_methods", _cxxstd_::bind(&cmd_system_has_methods, false));
    CMD2_ANY("system.has.public_methods", _cxxstd_::bind(&cmd_system_has_methods, true));

    // d.custom.* extensions
    CMD2_DL_LIST("d.custom.if_z", _cxxstd_::bind(&retrieve_d_custom_if_z,
                                                 _cxxstd_::placeholders::_1, _cxxstd_::placeholders::_2));
    CMD2_DL_LIST("d.custom.keys", _cxxstd_::bind(&retrieve_d_custom_map,
                                                 _cxxstd_::placeholders::_1, true, _cxxstd_::placeholders::_2));
    CMD2_DL_LIST("d.custom.items", _cxxstd_::bind(&retrieve_d_custom_map,
                                                 _cxxstd_::placeholders::_1, false, _cxxstd_::placeholders::_2));

    // Misc commands
    CMD2_ANY_LIST("value", &cmd_value);
    CMD2_ANY_LIST("compare", &apply_compare);
    CMD2_ANY("ui.bind_key", &apply_ui_bind_key);
    CMD2_VAR_VALUE("ui.bind_key.verbose", 1);
    CMD2_ANY("throttle.names", _cxxstd_::bind(&cmd_throttle_names));
    CMD2_DL("d.tracker_domain", _cxxstd_::bind(&cmd_d_tracker_domain, _cxxstd_::placeholders::_1));
    CMD2_DL("d.tracker_scrape.downloaded", _cxxstd_::bind(&cmd_d_tracker_scrape_info, 1, _cxxstd_::placeholders::_1));
    CMD2_DL("d.tracker_scrape.complete", _cxxstd_::bind(&cmd_d_tracker_scrape_info, 2, _cxxstd_::placeholders::_1));
    CMD2_DL("d.tracker_scrape.incomplete", _cxxstd_::bind(&cmd_d_tracker_scrape_info, 3, _cxxstd_::placeholders::_1));

    CMD2_ANY_STRING("log.messages", _cxxstd_::bind(&cmd_log_messages, _cxxstd_::placeholders::_2));
    CMD2_ANY_P("import.return", &cmd_import_return);
    CMD2_DL("d.is_meta", _cxxstd_::bind(&torrent::DownloadInfo::is_meta_download,
                                        _cxxstd_::bind(&core::Download::info, _cxxstd_::placeholders::_1)));

    // List capabilities of this build
    add_capability("system.has");         // self
    add_capability("rtorrent-ps");        // obvious
    add_capability("colors");             // not monochrome
    add_capability("canvas_v2");          // new PS 1.1 canvas with fully dynamic columns
}
