#include "ui_pyroscope.h"

#include "config.h"
#include "globals.h"

#include <cstdio>
#include <stdlib.h>

//#include <rak/functional.h>
//#include <rak/functional_fun.h>
//#include <sigc++/adaptors/bind.h>

#include "rpc/command_variable.h"
#include "core/view.h"
#include "core/download.h"
#include "torrent/tracker.h"
#include "torrent/tracker_list.h"
#include "torrent/rate.h"
#include "display/window.h"
#include "display/canvas.h"

#include "command_helpers.h"


#define TRACKER_LABEL_WIDTH 20U

typedef std::pair<core::View::iterator, core::View::iterator> Range;

static unsigned long attr_map[3 * ps::COL_MAX] = {0};

int ratio_col[] = {
	ps::COL_PROGRESS0, ps::COL_PROGRESS20, ps::COL_PROGRESS40, ps::COL_PROGRESS60, ps::COL_PROGRESS80, 
	ps::COL_PROGRESS100, ps::COL_PROGRESS120,
};

static const char* color_names[] = {
	"black", "red", "green", "yellow", "blue", "magenta", "cyan", "white"
};

static const char* color_vars[ps::COL_MAX] = {
	0,
	"ui.color.progress0",
	"ui.color.progress20",
	"ui.color.progress40",
	"ui.color.progress60",
	"ui.color.progress80",
	"ui.color.progress100",
	"ui.color.progress120",
	"ui.color.complete",
	"ui.color.seeding",
	"ui.color.incomplete",
	"ui.color.leeching",
	"ui.color.alarm",
	"ui.color.title",
	"ui.color.footer",
	"ui.color.label",
	"ui.color.odd",
	"ui.color.even",
	"ui.color.info",
	"ui.color.focus",
};

namespace display {


static int get_colors() {
	return COLORS;
}


void split(std::vector<std::string>& words, const char* str, char delim = ' ') {
	do {
		const char* begin = str;
		while (*str && *str != delim) str++;
		words.push_back(std::string(begin, str));
	} while (*str++);
}


void ui_pyroscope_canvas_init();

void ui_pyroscope_colormap_init() {
	if (!get_colors()) {
		initscr();
		ui_pyroscope_canvas_init();
	}

    int bg_odd = -1;
    int bg_even = -1;

	for (int k = 1; k < ps::COL_MAX; k++) {
		init_pair(k, -1, -1);
		std::string col_def = rpc::call_command_string(color_vars[k]);
		if (col_def.empty()) continue;

		std::vector<std::string> words;
		split(words, col_def.c_str());

		short col[2] = {-1, -1};
		short col_idx = 0;
		short bright = 0;
		unsigned long attr = A_NORMAL;
		for (int i = 0; i < words.size(); i++) {
			if (words[i] == "bold") attr |= A_BOLD;
			else if (words[i] == "standout") attr |= A_STANDOUT;
			else if (words[i] == "underline") attr |= A_UNDERLINE;
			else if (words[i] == "reverse") attr |= A_REVERSE;
			else if (words[i] == "blink") attr |= A_BLINK;
			else if (words[i] == "dim") attr |= A_DIM;
			else if (words[i] == "on") { col_idx = 1; bright = 0; }
			else if (words[i] == "gray") col[col_idx] = bright ? 7 : 8; // bright gray is white
			else if (words[i] == "bright") bright = 8;
			else if (words[i].find_first_not_of("0123456789") == std::string::npos) {
			    short c; 
			    sscanf(words[i].c_str(), "%hd", &c);
				col[col_idx] = c;
			} else for (short c = 0; c < 8; c++) {
				if (words[i] == color_names[c]) {
					col[col_idx] = bright + c;
					break;
				}
			}
		}

		if (col[0] != -1 && col[0] >= get_colors() || col[1] != -1 && col[1] >= get_colors()) {
			char buf[33];
			sprintf(buf, "%d", get_colors());
			throw torrent::input_error(col_def + ": your terminal only supports " + buf + " colors.");
		}

		attr_map[k] = attr;
		init_pair(k, col[0], col[1]);
		if (k == ps::COL_EVEN) bg_even = col[1];
		if (k == ps::COL_ODD)  bg_odd  = col[1];
	}

	for (int k = 1; k < ps::COL_MAX; k++) {
		short fg, bg; 
		pair_content(k, &fg, &bg);
				
		attr_map[k + 1 * ps::COL_MAX] = attr_map[k] | attr_map[ps::COL_EVEN];
		attr_map[k + 2 * ps::COL_MAX] = attr_map[k] | attr_map[ps::COL_ODD];
		init_pair(k + 1 * ps::COL_MAX, fg, bg == -1 ? bg_even : bg);
		init_pair(k + 2 * ps::COL_MAX, fg, bg == -1 ? bg_odd  : bg);
	}
}


void ui_pyroscope_canvas_init() {
 	start_color();
	use_default_colors();
	ui_pyroscope_colormap_init();
}


void ui_pyroscope_download_list_redraw_item(Window* window, display::Canvas* canvas, core::View* view, int pos, Range& range) {
    int offset = (((range.first - view->begin_visible()) & 1) + 1) * ps::COL_MAX;

	pos -= 3;
	torrent::Download* item = (*range.first)->download();

	if (range.first == view->focus()) {
		for (int i = 0; i < 3; i++ ) {
			canvas->set_attr(0, pos+i, 1, attr_map[ps::COL_FOCUS], ps::COL_FOCUS);
		}
	}

	// show "X of Y"
	if (pos == 1 && canvas->width() > 16) {
		int item_idx = view->focus() - view->begin_visible();
		if (item_idx == view->size())
			canvas->print(canvas->width() - 16, 0, "[ none of %-5d]", view->size());
		else
			canvas->print(canvas->width() - 16, 0, "[%5d of %-5d]", item_idx + 1, view->size());
		canvas->set_attr(canvas->width() - 16, 0, -1, attr_map[ps::COL_TITLE], ps::COL_TITLE);
	}

	// download title color
	int title_col;
	unsigned long focus_attr = range.first == view->focus() ? attr_map[ps::COL_FOCUS] : 0;
	if ((*range.first)->is_done())
		title_col = (item->up_rate()->rate() ? ps::COL_SEEDING : ps::COL_COMPLETE) + offset;
	else
		title_col = (item->down_rate()->rate() ? ps::COL_LEECHING : ps::COL_INCOMPLETE) + offset;
	canvas->set_attr(2, pos, -1, attr_map[title_col] | focus_attr, title_col);

	// show label for tracker in focus
	torrent::TrackerList* tl = item->tracker_list();
	torrent::Tracker* tracker = tl->at(0);
	for (int trkidx = 0; trkidx < tl->size(); trkidx++) {
		torrent::Tracker* tracker = tl->at(trkidx);
	    if (tracker->is_usable() && tracker->type() == torrent::Tracker::TRACKER_HTTP &&
	    		tracker->scrape_complete() + tracker->scrape_incomplete() > 0) {
			break;
	    }
	}
	if (!tracker && tl->size()) tracker = tl->at(0);
	if (tracker && !tracker->url().empty()) {
		std::string url = tracker->url();
		int off = 0;

		// snip url to domain name
		if (url.compare(0, 7, "http://")  == 0) url = url.substr(7);
		if (url.compare(0, 8, "https://") == 0) url = url.substr(8);
		if (url.find('/') > 0) url = url.substr(0, url.find('/'));
		if (url.find(':') > 0) url = url.substr(0, url.find(':'));

		// remove some common cruft
		const char* domain_cruft[] = {
			"tracker", "1.", "2.", "001.", ".",
			"www.",
			0
		};
		for (const char** cruft = domain_cruft; *cruft; cruft++) {
		    int cruft_len = strlen(*cruft);
			if (url.compare(0,  cruft_len, *cruft) == 0) url = url.substr(cruft_len);
		}

		// shorten label if too long
		int len = url.length();
		if (len > TRACKER_LABEL_WIDTH) {
			url = "…" + url.substr(len - TRACKER_LABEL_WIDTH);
			len = TRACKER_LABEL_WIDTH + 1;
		}

		// print it right-justified and in braces
		int xpos = canvas->width() - len - 2;
		canvas->print(xpos, pos, "{%s}", url.c_str());
		canvas->set_attr(xpos + 1, pos, len, attr_map[ps::COL_INFO + offset] | focus_attr, ps::COL_INFO + offset);
		canvas->set_attr(xpos, pos, 1, (attr_map[ps::COL_INFO + offset] | focus_attr) ^ A_BOLD, ps::COL_INFO + offset);
		canvas->set_attr(canvas->width() - 1, pos, 1, (attr_map[ps::COL_INFO + offset] | focus_attr) ^ A_BOLD, ps::COL_INFO + offset);
	}

	// better handling for trail of line 2 (ratio etc.)
	int status_pos = 91;
	int ratio = rpc::call_command_value("d.get_ratio", rpc::make_target(*range.first)) / 10;

	if (status_pos < canvas->width()) {
		canvas->print(status_pos, pos+1, "R:%5d%% [%c%c] %-4.4s  ",
			ratio,
			rpc::call_command_string("d.get_tied_to_file", rpc::make_target(*range.first)).empty() ? ' ' : 'T',
			(rpc::call_command_value("d.get_ignore_commands", rpc::make_target(*range.first)) == 0) ? ' ' : 'I',
			(*range.first)->priority() == 2 ? "" :
				rpc::call_command_string("d.get_priority_str", rpc::make_target(*range.first)).c_str()
		);
		status_pos += 9 + 5 + 5;
	}

	if (status_pos < canvas->width()) {
		std::string item_status;

		if (!(*range.first)->bencode()->get_key("rtorrent").get_key_string("throttle_name").empty()) {
			//item_status += "T=";
			item_status += rpc::call_command_string("d.get_throttle_name", rpc::make_target(*range.first)) + ' ';
		}

		int chars_left = canvas->width() - status_pos - item_status.length();
		if (chars_left < 0) {
			item_status = item_status.substr(0, 1-chars_left) + "…";
		} else if (chars_left > 0) {
			item_status = std::string(chars_left, ' ') + item_status;
		}
		canvas->print(status_pos, pos+1, "%s", item_status.c_str());
	}

	//.........1.........2.........3.........4.........5.........6.........7.........8.........9.........0.........1
	//12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	// [CLOSED]     0,0 /   15,9 MB Rate:   0,0 /   0,0 KB Uploaded:     0,0 MB [ 0%] --d --:-- R:nnnnn% [TI]
	int label_pos[] = {19, 1, 28, 2, 31, 5, 43, 1, 51, 12, 72, 4, 79, 1, 91, 2, 100, 1, 103, 1};
	const char* labels[sizeof(label_pos) / sizeof(int) / 2] = {0, 0, " U/D:"};

	canvas->set_attr(2, pos+1, canvas->width() - 1, attr_map[ps::COL_INFO + offset], ps::COL_INFO + offset);
	for (int label_idx = 0; label_idx < sizeof(label_pos) / sizeof(int); label_idx += 2) {
		if (labels[label_idx/2]) canvas->print(label_pos[label_idx], pos+1, labels[label_idx/2]);
		canvas->set_attr(label_pos[label_idx], pos+1, label_pos[label_idx+1], attr_map[ps::COL_LABEL + offset], ps::COL_LABEL + offset);
	}

	int rcol = sizeof(ratio_col) / sizeof(*ratio_col) - 1;
	rcol = ratio_col[std::min(rcol, ratio * rcol / 120)];
	canvas->set_attr(93, pos+1, 6, attr_map[rcol + offset], rcol + offset);

	// up / down
	canvas->set_attr(36, pos+1, 6, attr_map[ps::COL_SEEDING + offset] | (item->up_rate()->rate() ? attr_map[ps::COL_FOCUS] : 0),
		(item->up_rate()->rate() ? ps::COL_SEEDING : ps::COL_LABEL) + offset);
	canvas->set_attr(44, pos+1, 6, attr_map[ps::COL_LEECHING + offset] | (item->down_rate()->rate() ? attr_map[ps::COL_FOCUS] : 0),
		(item->down_rate()->rate() ? ps::COL_LEECHING : ps::COL_LABEL) + offset);

	// mark alert messages
	if (!(*range.first)->message().empty() && (*range.first)->message().find("Tried all trackers") == std::string::npos) {
		canvas->set_attr(1, pos, 1, attr_map[ps::COL_ALARM + offset], ps::COL_ALARM + offset);
		canvas->set_attr(1, pos+1, 1, attr_map[ps::COL_ALARM + offset], ps::COL_ALARM + offset);
		canvas->set_attr(1, pos+2, -1, attr_map[ps::COL_ALARM + offset], ps::COL_ALARM + offset);
	}
}


void ui_pyroscope_download_list_redraw(Window* window, display::Canvas* canvas, core::View* view) {
	canvas->set_attr(0, 0, -1, attr_map[ps::COL_TITLE], ps::COL_TITLE);
}


void ui_pyroscope_statusbar_redraw(Window* window, display::Canvas* canvas) {
	canvas->set_attr(0, 0, -1, attr_map[ps::COL_FOOTER], ps::COL_FOOTER);
}


} // namespace


const torrent::Object rpc::CommandVariable::set_color_string(Command* rawCommand, cleaned_type target, const torrent::Object& rawArgs) {
	rpc::CommandVariable::set_string(rawCommand, target, rawArgs);
	display::ui_pyroscope_colormap_init();
}


void initialize_command_ui_pyroscope() {
#if defined(CMD2_ANY)
#else
	#define NEW_VARIABLE_STRING(key, defaultValue) \
		add_variable(key, key ".set", 0, \
			&rpc::CommandVariable::get_string, &rpc::CommandVariable::set_color_string, std::string(defaultValue));

	NEW_VARIABLE_STRING("ui.color.progress0", 	"red");
	NEW_VARIABLE_STRING("ui.color.progress20", 	"bold bright red");
	NEW_VARIABLE_STRING("ui.color.progress40", 	"bold bright magenta");
	NEW_VARIABLE_STRING("ui.color.progress60", 	"yellow");
	NEW_VARIABLE_STRING("ui.color.progress80", 	"bold bright yellow");
	NEW_VARIABLE_STRING("ui.color.progress100",	"green");
	NEW_VARIABLE_STRING("ui.color.progress120",	"bold bright green");
	NEW_VARIABLE_STRING("ui.color.complete", 	"bright green");
	NEW_VARIABLE_STRING("ui.color.seeding", 	"bold bright green");
	NEW_VARIABLE_STRING("ui.color.incomplete", 	"yellow");
	NEW_VARIABLE_STRING("ui.color.leeching", 	"bold bright yellow");
	NEW_VARIABLE_STRING("ui.color.alarm", 		"bold white on red");
	NEW_VARIABLE_STRING("ui.color.title", 		"bold bright white on blue");
	NEW_VARIABLE_STRING("ui.color.footer", 		"bold bright cyan on blue");
	NEW_VARIABLE_STRING("ui.color.label", 		"gray");
	NEW_VARIABLE_STRING("ui.color.odd", 		"");
	NEW_VARIABLE_STRING("ui.color.even", 		"");
	NEW_VARIABLE_STRING("ui.color.info", 		"white");
	NEW_VARIABLE_STRING("ui.color.focus", 		"reverse");

	ADD_COMMAND_VOID("system.colors.max",       rak::ptr_fun(&display::get_colors));
	ADD_COMMAND_VOID("system.colors.enabled",   rak::ptr_fun(&has_colors));
	ADD_COMMAND_VOID("system.colors.rgb",       rak::ptr_fun(&can_change_color));
#endif
}

