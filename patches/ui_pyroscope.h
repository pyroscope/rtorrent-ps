#ifndef UI_PYROSCOPE_H
#define UI_PYROSCOPE_H

namespace ps {

#define COL_SYS_BASE 90

enum ColorKind {
    COL_DEFAULT,
    COL_CUSTOM1,
    COL_CUSTOM2,
    COL_CUSTOM3,
    COL_CUSTOM4,
    COL_CUSTOM5,
    COL_CUSTOM6,
    COL_CUSTOM7,
    COL_CUSTOM8,
    COL_CUSTOM9,
    COL_PROGRESS0, // 10
    COL_PROGRESS20,
    COL_PROGRESS40,
    COL_PROGRESS60,
    COL_PROGRESS80,
    COL_PROGRESS100,
    COL_PROGRESS120,
    COL_TITLE,
    COL_FOOTER,
    COL_FOCUS,
    COL_LABEL, // 20
    COL_INFO,
    COL_ALARM,
    COL_COMPLETE,
    COL_SEEDING,
    COL_STOPPED,
    COL_QUEUED,
    COL_INCOMPLETE,
    COL_LEECHING,
    COL_ODD,
    COL_EVEN,
    COL_MAX,

    COL_TRAFFIC = COL_SYS_BASE,
    COL_PRIO,
    COL_SYS_MAX
};

} // namespace

extern void add_capability(const char* name); // defined in command_pyroscope.cc

#endif
