User's Manual
=============

This chapter describes the additional features in *rTorrent-PS*,
and other differences to a vanilla *rTorrent* build.


.. _features-std-cfg:

Additional Features
-------------------

Using the right default configuration (more on that below),
you will get the following additional features in your `rTorrent-PS` installation:

#.  the ``t`` key is bound to a ``trackers`` view that shows all items
    sorted by tracker and then by name.
    See `Additional Views`_ for details.
#.  the ``!`` key is bound to a ``messages`` view, listing all items
    that currently have a non-empty message, sorted in order of the
    message text.
    See `Additional Views`_ for details.
#.  the ``^`` key is bound to the ``rtcontrol`` search result view, so
    you can easily return to your last search.
    See `Additional Views`_ for details.
#.  the ``?`` key is bound to the ``indemand`` view, which sorts all
    open items by their activity, with the most recently active on top.
    See `Additional Views`_ for details.
#.  ``Page ↑`` and ``Page ↓`` scroll by 50 items at a time (or whatever
    other value ``ui.focus.page_size`` has).
#.  ``Home`` / ``End`` jump to the first / last item in the current
    view.
#.  the ``~`` key rotates through all available color themes, or a
    user-selected subset. See `Color Themes`_ for details.
#.  the ``<`` and ``>`` keys rotate through all added category views
    (``pyro.category.add=‹name›``), with filtering based on the
    ruTorrent label (``custom_1=‹name›``). See `Category Views`_ for details.
#.  ``|`` reapplies the category filter and thus updates the current
    category view.
#.  the ``u`` key shows the uptime and some other essential data of your
    rTorrent instance.
#.  ``F2`` shows some important help resources (web links) in the
    console log.
#.  ``*`` toggles between the collapsed (as described on `Extended
    Canvas Explained`_) and the expanded display of the current view.
    |rt-ps-name-view|
#.  The ``active`` view is changed to include all incomplete items
    regardless of whether they have any traffic, and then groups the
    list into complete, incomplete, and queued items, in that order.
    Within each group, they're sorted by download and then upload speed.
#.  Some `canvas v2` columns are added in the `pimp-my-box` configuration –
    the selected throttle (⋉), a download's chunk size (≣),
    and the expected time of arrival (⌛⚪≋⚫) on the *active* and *leeching* displays only.
    The visibility of the chunk size column can be toggled using the ``_`` key.
#.  The commands ``s=«keyword»``, ``t=«tracker_alias»``, and
    ``f=«filter_condition»`` are pre-defined for searching using a
    Ctrl-X prompt.
#.  The ``.`` key toggles the membership in the ``tagged`` view for the
    item in focus, ``:`` shows the ``tagged`` view, and ``T`` clears
    that view (i.e. removes the tagged state on all items). This can be
    very useful to manually select a few items and then run
    ``rtcontrol`` on them, or alternatively use ``--to-view tagged`` to
    populate the ``tagged`` view, then deselect some items interactively
    with the ``.`` key, and finally mass-control the rest.
    See `Additional Views`_ for details.
#.  You can use the ``purge=`` and ``cull=`` commands (on a Ctrl-X
    prompt) for deleting the current item and its (incomplete) data.
#.  ``Ctrl-g`` shows the tags of an item (as managed by ``rtcontrol``);
    ``tag.add=‹tag›`` and ``tag.rm=‹tag›`` can be used to change the set
    of tags, both also show the new set of tags after changing them.
#.  Time-stamped log files with rotation, archival (compression), and pruning
    – with a setting for the number of days to keep logs in uncompressed form, or at all.
#.  Trackers are scraped regularly (active items relatively often,
    inactive items including closed ones seldomly), so that the display
    of downloads / seeders / leechers is not totally outdated.
    The ``&`` key can be used to manually scrape the item in focus.
#.  A watchdog for the ``pyrotorque`` daemon process (checks every 5 minutes,
    and starts it when missing *if* the `~/.pyroscope/run/pyrotorque` file exists).

With regards to using the ‘right’ configuration to get the above, you need
the ``*.rc.default`` files in the ``~/.pyroscope/rtorrent.d`` directory
provided by `pyrocore`.
`Standard Configuration Explained`_ has details on these.
Some more features are defined by the `pimp-my-box`_ configuration templates.

To get there, perform the :ref:`DebianInstallFromSource` as described in this manual,
or use the `pimp-my-box`_ project for an automatic remote installation.
The instructions in the `Extending your ‘.rtorrent.rc’`_ section of the `pyrocore` manual
only cover half of it, and you might miss some described features.




.. _Extending your ‘.rtorrent.rc’: https://pyrocore.readthedocs.org/en/latest/setup.html#extending-your-rtorrent-rc
.. _`Standard Configuration Explained`: https://pyrocore.readthedocs.io/en/latest/usage.html#std-config
.. _`Category Views`: https://pyrocore.readthedocs.io/en/latest/usage.html#category-views
.. _`Color Themes`: https://pyrocore.readthedocs.io/en/latest/usage.html#color-themes
.. _`Additional Views`: https://pyrocore.readthedocs.io/en/latest/usage.html#additional-views

.. |rt-ps-name-view| image:: _static/img/rt-ps-name-view.png


.. _extended-canvas:

Extended Canvas Explained
-------------------------

The following is an explanation of the collapsed display (canvas v2) of
`rTorrent-PS` — remember that you need to bind a key to the
``view.collapsed.toggle`` command, or set the default of a view by
`calling that command in the configuration`_, else you won't ever see it.

.. figure:: _static/img/rt-ps-trackers-view.png
   :align: center
   :alt: rTorrent-PS Trackers View

   rTorrent-PS Trackers View

The following is an overview of the column heading icons, and what the values and icons in it mean.
A **⍰** after the column title indicates a ‘sacrificial’ column, which disappear when the display
gets too narrow to display all the columns. When even that does not provide enough space,
columns are omitted beginning on the right side (*Name* is always included).

❢
    Message or alert indicator (♺ = Tracker cycle complete,
    i.e. "Tried all trackers"; ⚡ = establishing connection;
    ↯ = data transfer problem; ◔ = timeout; ¿? = unknown torrent /
    info hash; ⨂ = authorization problem (possibly temporary); ⚠ = other)
☢
    Item state (▹ = started, ╍ = paused, ▪ = stopped)
☍    **⍰**
    Tied item? [⚯]
⌘    **⍰**
    Command lock-out? (⚒ = heed commands, ◌ = ignore commands)
↺   **⍰**
    Number of completions from last scrape info
⤴     **⍰**
    Number of seeds from last scrape info
⤵     **⍰**
    Number of leeches from last scrape info
⚡    **⍰**
    Transfer direction indicator [⇅ ↡ ↟]
℞
    Number of connected peers
∆⋮⌛
    Upload rate, or when inactive, time the download took (only after completion).
∇⋮⌚
    Approximate time since completion (units are «”’hdwmy» from seconds to years);
    for incomplete items the download rate or, if there's no traffic,
    the time since the item was started or loaded
⌛⚪≋⚫ **⍰**
    Expected time of arrival – only shown on the *active* and *leeching* displays
⋉   **⍰**
    Throttle selected for this item (∞ is the special ``NULL`` throttle; ⓪…⑨ for
    `ruTorrent`'s ``thr_0…9`` channels)
Σ⇈  **⍰**
    Total sum of uploaded data
⣿
    Completion status (✔ = done; else up to 8 dots [⣿] and ❚, i.e. progress in 10% steps);
    the old ``ui.style.progress.set`` command is deprecated,
    see :ref:`add-custom-columns` for the new way to get
    a different set of glyphs or an ASCII version
☯
    Ratio (☹ plus color indication for < 1, ➀ — ➉ : >= the number, ⊛ : >= 11);
    the old ``ui.style.ratio.set`` command is deprecated,
    see :ref:`add-custom-columns` for the new way to get
    a different set of number glyphs or an ASCII version
✇
    Data size
≣   **⍰**
    Chunk size - this column can be toggled on / off using the ``_`` key
✰
    Priority (✖ = off, ⇣ = low, nothing for normal, ⇡ = high)
⚑
    A ⚑ indicates this item is on the ``tagged`` view
Name
    Name of the download item – either the name contained in the metafile,
    or else the value of the ``displayname`` custom field when set on an item
Tracker
    Domain of the first HTTP tracker with seeds or leeches,
    or else the first one altogether – note that your can define nicer
    aliases using the `trackers.alias.set_key`_ command in your configuration

For the various time displays to work, you need
the `pyrocore` `standard configuration for rtorrent.rc`_.

The scrape info and peer numbers are exact only for values below 100, else they
indicate the order of magnitude using roman numerals (c = 10², m = 10³,
X = 10⁴, C = 10⁵, M = 10⁶).
For up-to-date scrape info, you need the `Tracker Auto-Scraping`_ configuration from `pyrocore`.

.. _`standard configuration for rtorrent.rc`: https://pyrocore.readthedocs.io/en/latest/setup.html#extending-your-rtorrent-rc
.. _`Tracker Auto-Scraping`: https://github.com/pyroscope/pyrocore/blob/master/src/pyrocore/data/config/rtorrent.d/auto-scrape.rc#L1


.. _commands:

Command Extensions
------------------

The following new commands are available.
Note that the links point to the `Commands Reference`_ chapter in the *rTorrent Handbook*.

.. include:: include-commands.rst

.. _`Commands Reference`: https://rtorrent-docs.readthedocs.io/en/latest/cmd-ref.html


.. contents:: List of Commands
   :local:


compare=order,command1=[,...]
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Compares two items like ``less=`` or ``greater=``, but allows to compare
by several different sort criteria, and ascending or descending order
per given field.

The first parameter is a string of order indicators, either ``aA+`` for
ascending or ``dD-`` for descending. The default, i.e. when there's more
fields than indicators, is ascending. Field types other than value or
string are treated as equal (or in other words, they're ignored). If all
fields are equal, then items are ordered in a random, but stable
fashion.

Configuration example:

.. code-block:: ini

    # VIEW: Show active and incomplete torrents (in view #9) and update every 20 seconds
    # Items are grouped into complete, incomplete, and queued, in that order.
    # Within each group, they're sorted by upload and then download speed.
    view_sort_current = active,"compare=----,d.is_open=,d.get_complete=,d.get_up_rate=,d.get_down_rate="
    schedule = filter_active, 12, 20, \
        "view_filter = active,\"or={d.get_up_rate=,d.get_down_rate=,not=$d.get_complete=}\" ; \
         view_sort=active"


ui.bind\_key=display,key,"command1=[,...]"
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Binds the given key on a specified display to execute the commands when
pressed.

-  ``display`` must be equal to ``download_list`` (currently, no other
   displays are supported).
-  ``key`` can be either a single character for normal keys, ``^`` plus
   a character for control keys, or a 4 digit octal key code.

.. important::

    This currently can NOT be used immediately when ``rtorrent.rc`` is parsed,
    so it has to be scheduled once shortly after startup (see below example).

Configuration example:

.. code-block:: ini

    # VIEW: Bind view #7 to the "rtcontrol" result
    schedule = bind_7,0,0,"ui.bind_key=download_list,7,ui.current_view.set=rtcontrol"


view.collapsed.toggle=«VIEW NAME»
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This command changes between the normal item display where each item
takes up three lines to a more condensed form where each item only takes
up one line. Note that each view has its own state, and that if the view
name is empty, the current view is toggled. You can set the default
state in your configuration, by adding a toggle command for each view
you want collapsed after startup (the default is expanded).

Also, you should bind the current view toggle to a key, like this:

.. code-block:: ini

    schedule = bind_collapse,0,0,"ui.bind_key=download_list,*,view.collapsed.toggle="

Further explanations on what the columns show and what forms of
abbreviations are used, to get a display as compact as possible while
still showing all the important stuff, can be found on :ref:`extended-canvas`.
That section also contains hints on **how to correctly setup your terminal**.


ui.color.«TYPE».set="«COLOR DEF»"
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

These commands allow you to set colors for selected elements of the user
interface, in some cases depending on their status. You can either
provide colors by specifying the numerical index in the terminal's color
table, or by name (for the first 16 colors).

The possible color names
are "black", "red", "green", "yellow", "blue", "magenta", "cyan",
"gray", and "white"; you can use them for both text and background
color, in the form "«fg» on «bg»", and you can add "bright" in front of
a color to select a more luminous version. If you don't specify a color,
the default of your terminal is used.

Also, these additional modifiers can be placed in the color definitions,
but it depends on the terminal you're using whether they have an effect:
"bold", "standout", "underline", "reverse", "blink", and "dim".

Here's a configuration example showing all the commands and their
defaults:

.. code-block:: ini

    # UI/VIEW: Colors
    ui.color.alarm.set="bold white on red"
    ui.color.complete.set="bright green"
    ui.color.even.set=""
    ui.color.focus.set="reverse"
    ui.color.footer.set="bold bright cyan on blue"
    ui.color.incomplete.set="yellow"
    ui.color.info.set="white"
    ui.color.label.set="gray"
    ui.color.leeching.set="bold bright yellow"
    ui.color.odd.set=""
    ui.color.progress0.set="red"
    ui.color.progress20.set="bold bright red"
    ui.color.progress40.set="bold bright magenta"
    ui.color.progress60.set="yellow"
    ui.color.progress80.set="bold bright yellow"
    ui.color.progress100.set="green"
    ui.color.progress120.set="bold bright green"
    ui.color.queued.set="magenta"
    ui.color.seeding.set="bold bright green"
    ui.color.stopped.set="blue"
    ui.color.title.set="bold bright white on blue"

Note that you might need to enable support for 256 colors in your
terminal, see this article for a description. In a nutshell, you need to
install the ``ncurses-term`` package if you don't have it already, and
also add these commands to your rTorrent start script:

.. code-block:: shell

    if [ "$TERM" = "${TERM%-256color}" ]; then
        export TERM="$TERM-256color"
    fi

Also consider the hints at the end of the `Extended Canvas Explained`_
page.

If everything worked so far, and you now want to find you own coloring
theme, the easiest way is to use a second shell and ``rtxmlrpc``. Try
out some colors, and add the combinations you like to your
``~/.rtorrent.rc``.

.. code-block:: shell

    # For people liking candy stores...
    rtxmlrpc ui.color.title.set "bold magenta on bright cyan"

You can use the following code in a terminal to dump a color scheme:

.. code-block:: shell

    for i in $(rtxmlrpc system.listMethods | grep ui.color. | grep -v '\.set$'); do
        echo $i = $(rtxmlrpc -r $i | tr "'" '"') ;
    done

The term-256color script can help you with showing the colors your
terminal supports, an example output using Gnome's terminal looks like
the following...

.. figure:: _static/img/xterm-256-color.png
   :align: center
   :alt: xterm-256-color

   xterm-256-color


ui.current\_view= (merged into 0.9.7+)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Returns the currently selected view, the vanilla 0.9.6 release only has
a setter.

Needed if you want to use a hyphen ``-`` as a view name in ``rtcontrol``
to refer to the currently shown view. An example for that is passing
``-M-`` as an option, which performs in-place filtering of the current
view via ``rtcontrol``.

Another use-case for this command is if you want to rotate through a set
of views via XMLRPC.


log.messages=«path»
^^^^^^^^^^^^^^^^^^^

(Re-)opens a log file that contains the messages normally only visible
on the main panel and via the ``l`` key. Each line is prefixed with the
current date and time in ISO8601 format. If an empty path is passed, the
file is closed.


network.history.\*=
^^^^^^^^^^^^^^^^^^^

Commands to add network traffic charts to the bottom of the collapsed
download display. The commands added are
``network.history.depth[.set]=``, ``network.history.sample=``,
``network.history.refresh=``, and ``network.history.auto_scale=``.
See the :ref:`extended-canvas` on how to use them.


d.tracker\_domain=
^^^^^^^^^^^^^^^^^^

Returns the (shortened) tracker domain of the given download item. The
chosen tracker is the first HTTP one with active peers (seeders or
leechers), or else the first one.


trackers.alias.set\_key=«domain»,«alias»
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Sets an alias that replaces the given domain, when displayed on the
right of the collapsed canvas.

Configuration example:

.. code-block:: ini

    trackers.alias.set_key = bttracker.debian.org, Debian


trackers.alias.items=
^^^^^^^^^^^^^^^^^^^^^

Returns all the mappings in the form ``«domain»=«alias»`` as a list.

Note that domains that were not explicitly defined so far, but shown
previously, are also contained in the list, with an empty alias. So to
create a list for you to fill in the aliases, scroll through all your
items on ``main`` or ``trackers``, so you can dump the domains of all
loaded items.

Example that prints all the domains and their aliases as commands that
define them:

.. code-block:: shell

    rtxmlrpc trackers.alias.items \
        | sed -r -e 's/=/, "/' -e 's/^/trackers.alias.set_key = /' -e 's/$/"/' \
        | tee ~/rtorrent/rtorrent.d/tracker-aliases.rc

This also dumps them into the ``tracker-aliases.rc`` file to persist
your mappings, and also make them easily editable. To reload edited
alias definitions, use this:

.. code-block:: shell

    rtxmlrpc "try_import=,~/rtorrent/rtorrent.d/tracker-aliases.rc"


system.env=«name» (merged into 0.9.7+)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Returns the value of the given environment variable, or an empty string
if it does not exist.

Configuration example:

.. code-block:: ini

    session.path.set="$cat=\"$system.env=RTORRENT_HOME\",\"/.session\""


system.random=[[«lower»,]«upper»]
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Generate *uniformly* distributed random numbers in the range defined by
``lower``..``upper``.

The default range with no args is ``0`` … ``RAND_MAX``. Providing just
one argument sets an *exclusive* upper bound, and two arguments define
an *inclusive* range.

An example use-case is adding jitter to time values that you later check
with ``elapsed.greater``, to avoid load spikes and similar effects of
clustered time triggers.


value=«number»[,«base»]
^^^^^^^^^^^^^^^^^^^^^^^

Converts a given number with the given base (or 10 as the default) to an
integer value.

Examples:

.. code-block:: console

    $ rtxmlrpc --repr value '' 1b 16
    27
    $ rtxmlrpc --repr value '' 1b
    ERROR    While calling value('', '1b'): <Fault -503: 'Junk at end of number: 1b'>


string.contains[\_i]=«haystack»,«needle»[,…]
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Checks if a given string contains any of the strings following it. The
variant with ``_i`` is case-ignoring, but *only* works for pure ASCII
needles.

Example:

.. code-block:: shell

    rtxmlrpc d.multicall.filtered '' '' 'string.contains_i=(d.name),x264.aac' d.hash= d.name=


d.multicall.filtered=«viewname»,«condition»,«command»[,…]
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Iterates over all items of a view (or ``default`` if the view name is
empty), just like ``d.multicall2``, but only calls the given commands if
``condition`` is true for an item.

See directly above for an example.


.. _Bintray: https://bintray.com/pkg/show/general/pyroscope/rtorrent-ps/rtorrent-ps
.. _installation options: https://github.com/pyroscope/rtorrent-ps#installation
.. _Arch Linux: http://www.archlinux.org/
.. _`rtxmlrpc`: https://pyrocore.readthedocs.io/en/latest/usage.html#rtxmlrpc
.. _`pyroadmin`: https://pyrocore.readthedocs.io/en/latest/references.html#pyroadmin
.. _`pimp-my-box`: https://github.com/pyroscope/pimp-my-box/
.. _`~/rtorrent/rtorrent.d/05-rt-ps-columns.rc`: https://github.com/pyroscope/pimp-my-box/blob/master/roles/rtorrent-ps/templates/rtorrent/rtorrent.d/05-rt-ps-columns.rc#L1
.. _`rTorrent Scripting`: https://rtorrent-docs.readthedocs.io/en/latest/scripting.html#


.. end of "manual.rst"
