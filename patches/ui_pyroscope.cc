#include "ui_pyroscope.h"

#include "config.h"
#include "globals.h"

//#include <rak/functional.h>
//#include <rak/functional_fun.h>
//#include <sigc++/adaptors/bind.h>

#include "rpc/command_variable.h"

#include "command_helpers.h"


//static const color_map[ps::COL_MAX];


void initialize_command_ui_pyroscope() {
#if defined(CMD2_ANY)
#else
#define NEW_VARIABLE_STRING(key, defaultValue) \
add_variable(key, key ".set", 0, &rpc::CommandVariable::get_string, &rpc::CommandVariable::set_string, std::string(defaultValue));

	NEW_VARIABLE_STRING("ui.color.complete", 	"green on black");
	NEW_VARIABLE_STRING("ui.color.active",		"blue on black");
	NEW_VARIABLE_STRING("ui.color.alarm", 		"bold white on red");
#endif
}
