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

#include <ctime>
#include <rak/functional.h>
#include <rak/functional_fun.h>
#include <sigc++/adaptors/bind.h>

#include "core/manager.h"
#include "core/view_manager.h"
#include "ui/root.h"
#include "ui/download_list.h"
#include "rpc/command_slot.h"
#include "rpc/command_variable.h"
#include "rpc/parse.h"

#include "globals.h"
#include "control.h"
#include "command_helpers.h"


/*  @DOC
    compare=order,command1=[,...]
    
        Compares two items like less= or greater=, but allows to compare
        by several different sort criteria, and ascending or descending
        order per given field. The first parameter is a string of order
        indicators, either `aA+` for ascending or `dD-` for descending. 
        The default, i.e. when there's more fields than indicators, is
        ascending. Field types other than value or string are treated
        as equal (or in other words, they're ignored).
        
        If all fields are equal, then items are ordered in a random, but
        stable fashion.

        Config example::
            # VIEW: Show active and incomplete torrents (in view #9) and update every 20 seconds
            #       Items are grouped into complete, incomplete, and queued, in that order.
            #       Within each group, they're sorted by upload and then download speed.
            view_sort_current = active,"compare=----,d.is_open=,d.get_complete=,d.get_up_rate=,d.get_down_rate="
            schedule = filter_active,12,20,"view_filter = active,\"or={d.get_up_rate=,d.get_down_rate=,not=$d.get_complete=}\" ;view_sort=active"
*/
torrent::Object apply_compare(rpc::target_type target, const torrent::Object& rawArgs) {
    const torrent::Object::list_type& args = rawArgs.as_list();

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

void initialize_command_pyroscope() {
    ADD_ANY_LIST("compare", rak::ptr_fn(&apply_compare));
}

