# rTorrent-PS Reference

# :bangbang: NOTE THIS PAGE STILL NEEDS TO BE UPDATED TO GITHUB LINKS ETC.

**Contents**

  * [Introduction](#introduction)
  * [Additional features in the standard configuration](#additional-features-in-the-standard-configuration)
  * [Command Extensions](#command-extensions)
    * [compare=order,command1=[,...]](#compareordercommand1)
    * [ui.bind_key=display,key,"command1=[,...]"](#uibind_keydisplaykeycommand1)
    * [view.collapsed.toggle=«VIEW NAME»](#viewcollapsedtoggleview-name)
    * [ui.color.«TYPE».set="«COLOR DEF»"](#uicolortypesetcolor-def)
    * [d.tracker_domain=](#dtracker_domain)
    * [ui.current_view= (merged into 0.9.7 )](#uicurrent_view-merged-into-097)
    * [log.messages=«path»](#logmessagespath)
    * [network.history.*=](#networkhistory)
    * [system.env=«name» (merged into 0.9.7 )](#systemenvname-merged-into-097)
    * [ui.status.throttle_up_name.set="«name»"](#uistatusthrottle_up_namesetname)
  * [Backports of git master fixes and features to 0.9.2](#backports-of-git-master-fixes-and-features-to-092)


<table border='0'><tr valign='middle'>
<td><img src='https://pyroscope.googlecode.com/svn/trunk/pyrocore/src/pyrocore/data/img/rt-logo.png' /></td>
<td width='30px'></td>
<td><br /><img src='http://i.imgur.com/hAdjM.gif' /></td>
<td width='10px'></td>
<td><wiki:gadget url="http://www.ohloh.net/p/346666/widgets/project_users.xml?style=red" height="100"  border="0" /></td>
<td align='center'><a href='http://youtu.be/Bv-oajBgsSU'><img src='http://i.imgur.com/5FPx5.png' /></a><br />  Demo Video</td>
</tr></table>


## Introduction

By installing the extended rTorrent distribution `rTorrent-PS`,
you'll get an alternative rTorrent executable with the following changes:

 1. self-contained install into any location of your choosing,
    including your home directory, offering the ability to run
     several versions at once (in different client instances).
 1. _rpath-linked_ to the major dependencies, so you can upgrade
    those independently from your OS distribution's versions.
 1. extended command set (exclusive PyroScope patches):

      * sort views by more than one value, and set the sort direction for each of these.
      * bind keys in the root display to any command, e.g. change the built-in views.
      * interface patches adding easily customizable colors, displaying the _tracker domain_, and some more minor modifications to the download list view.

 1. show number of registered downloads on the tracker info panel.

You just need to either follow the
[build instructions](https://github.com/pyroscope/pyroscope/blob/wiki/DebianInstallFromSource.md#build-rtorrent-and-core-dependencies-from-source),
or download and install a package from
[Bintray](https://bintray.com/pkg/show/general/pyroscope/rtorrent-ps/rtorrent-ps)
— assuming one is available for your platform.

![http://i.imgur.com/xVSmh.png](http://i.imgur.com/xVSmh.png)

The new stable rTorrent version **0.9.6** is built by default, but 0.8.9 and 0.8.6 are also supported (but not tested anymore) — also, not all patches are applied equally (depending on whether they're needed, or applicable at all).
Note that some of these patches are taken from the [AUR package](https://aur.archlinux.org/packages/rtorrent-extended/) provided for [Arch Linux](http://www.archlinux.org/). Also, there is now a [rtorrent-pyro](https://aur.archlinux.org/packages.php?ID=54763) AUR package (which is said to not really work, contact its maintainers with any problems, _not_ me).

➽ _Note that you need to read **all** of the following explanations of the user-interface related new commands to get the visual changes set up correctly, since this requires some special setup of your terminal on many machines!_


## Additional features in the standard configuration

If you followed the instructions in the
[Extending your ‘.rtorrent.rc’](https://pyrocore.readthedocs.org/en/latest/setup.html#extending-your-rtorrent-rc)
section of the ``pyrocore`` manual,
you will get the following additional features in your `rTorrent-PS` installation:

  1. the `t` key is bound to a `trackers` view that shows all items sorted by tracker and then by name.
  1. the `!` key is bound to a `messages` view, listing all items that currently have a non-empty message, sorted in order of the message text.
  1. the `^` key is bound to the `rtcontrol` search result view, so you can easily return to your last search.
  1. `*` toggles between the collapsed (as described on [Extended Canvas Explained](https://github.com/pyroscope/rtorrent-ps/blob/master/docs/RtorrentExtendedCanvas.md#extended-canvas-explained)) and the expanded display of the current view. <br /><br /> ![http://i.imgur.com/zbAT9.png](http://i.imgur.com/zbAT9.png)
  1. The `active` view is changed to include all incomplete items regardless of whether they have any traffic, and then groups the list into complete, incomplete, and queued items, in that order. Within each group, they're sorted by download and then upload speed.
  1. The commands `s=«keyword»`, `t=«tracker_alias»`, and `f=«filter_condition»` are pre-defined for searching using a Ctrl-X prompt.
  1. The `.` key toggles the membership in the `tagged` view for the item in focus,
     `:` shows the `tagged` view, and `T` clears that view (i.e. removes the tagged state on all items).
     This can be very useful to manually select a few items and then run `rtcontrol` on them,
     or alternatively use »`--to-view tagged`« to populate the `tagged` view,
     then deselect some items interactively with the »`.`« key, and finally mass-control the rest.
  1. You can use the `purge=` and `cull=` commands (on a Ctrl-X prompt) for deleting the current item and its (incomplete) data.

> ✪ _Do not forget to set the value of `pyro.extended` to 1!_


## Command Extensions

The following new commands are available.

### compare=order,command1=[,...]

Compares two items like ``less=`` or ``greater=``, but allows to compare
by several different sort criteria, and ascending or descending
order per given field.

The first parameter is a string of order
indicators, either ``aA+`` for ascending or ``dD-`` for descending.
The default, i.e. when there's more fields than indicators, is
ascending. Field types other than value or string are treated
as equal (or in other words, they're ignored).
If all fields are equal, then items are ordered in a random, but
stable fashion.

Configuration example:

```ini
# VIEW: Show active and incomplete torrents (in view #9) and update every 20 seconds
# Items are grouped into complete, incomplete, and queued, in that order.
# Within each group, they're sorted by upload and then download speed.
view_sort_current = active,"compare=----,d.is_open=,d.get_complete=,d.get_up_rate=,d.get_down_rate="
schedule = filter_active,12,20,"view_filter = active,\"or={d.get_up_rate=,d.get_down_rate=,not=$d.get_complete=}\" ;view_sort=active"
```


### ui.bind_key=display,key,"command1=[,...]"

:warning: | This currently can NOT be used immediately when ``rtorrent.rc`` is parsed, so it has to be scheduled once shortly after startup (see below example).
---: | :---

Binds the given key on a specified display to execute the commands when pressed.

  * ``display`` must be equal to ``download_list`` (currently, no other displays are supported).
  * ``key`` can be either a single character for normal keys,
    ``^`` plus a character for control keys,
    or a 4 digit octal key code.

Configuration example:

```ini
# VIEW: Bind view #7 to the "rtcontrol" result
schedule = bind_7,0,0,"ui.bind_key=download_list,7,ui.current_view.set=rtcontrol"
```


### view.collapsed.toggle=«VIEW NAME»

This command changes between the normal item display where each item takes up
three lines to a more condensed form where each item only takes up one line.
Note that each view has its own state, and that if the view name is empty,
the current view is toggled. You can set the default state in your configuration,
by adding a toggle command for each view you want collapsed after startup
(the default is expanded).

Also, you should bind the current view toggle to a key, like this:

```ini
schedule = bind_collapse,0,0,"ui.bind_key=download_list,*,view.collapsed.toggle="
```

Further explanations on what the columns show and what forms of abbreviations are used,
to get a display as compact as possible while still showing all the important stuff,
can be found on
[Extended Canvas Explained](https://github.com/pyroscope/rtorrent-ps/blob/master/docs/RtorrentExtendedCanvas.md#extended-canvas-explained).
That page also contains hints on **how to correctly setup your terminal**.


### ui.color.«TYPE».set="«COLOR DEF»"

These commands allow you to set colors for selected elements of the user interface,
in some cases depending on their status. You can either provide colors by specifying
the numerical index in the terminal's color table, or by name (for the first 16 colors).
The possible color names are "black", "red", "green", "yellow", "blue", "magenta",
"cyan", "gray", and "white"; you can use them for both text and background color,
in the form "«fg» on «bg»", and you can add "bright" in front of a color to select
a more luminous version. If you don't specify a color, the default of your terminal is used.

Also, these additional modifiers can be placed in the color definitions,
but it depends on the terminal you're using whether they have an effect:
"bold", "standout", "underline", "reverse", "blink", and "dim".

Here's a configuration example showing all the commands and their defaults:

```ini
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
```

Note that you might need to enable support for 256 colors in your terminal,
see <a href='http://askubuntu.com/questions/67/how-do-i-enable-full-color-support-in-terminal'>this article</a>
for a description. In a nutshell, you need to install the ``ncurses-term`` package
if you don't have it already, and also add these commands to your rTorrent start script:

```sh
if [ "$TERM" = "${TERM%-256color}" ]; then
    export TERM="$TERM-256color"
fi
```

Also consider the hints at the end of the
[Extended Canvas Explained](https://github.com/pyroscope/rtorrent-ps/blob/master/docs/RtorrentExtendedCanvas.md#extended-canvas-explained) page.

If everything worked so far, and you now want to find you own coloring theme,
the easiest way is to use a second shell and ``rtxmlrpc``. Try out some colors,
and add the combinations you like to your ``~/.rtorrent.rc``.

```ini
# For people liking candy stores...
rtxmlrpc ui.color.title.set "bold magenta on bright cyan"
```


The <a href='https://raw.githubusercontent.com/pyroscope/rtorrent-ps/master/term-256color.py'>term-256color</a>
script can help you with showing the colors your terminal supports,
an example output using Gnome's terminal looks like the following...

<img src='http://i.imgur.com/iu8nY.png' />


### d.tracker_domain=

Returns the (shortened) <i>tracker domain</i> of the given download item.
The chosen tracker is the first HTTP one with active peers (seeders or leechers),
or else the first one.


### ui.current_view= (merged into 0.9.7+)

Returns the currently selected view, the official release only has a setter.
Needed if you want to use ``-`` as a view name in ``rtcontrol``.


### log.messages=«path»

(Re-)opens a log file that contains the messages normally only visible on
the main panel and via the ``l`` key. Each line is prefixed with the
current date and time in ISO8601 format.
If an empty path is passed, the file is closed.


### network.history.*=

Commands to add network traffic charts to the bottom of the collapsed download display.
The commands added are ``network.history.depth[.set]=``,  ``network.history.sample=``,
``network.history.refresh=``, and ``network.history.auto_scale=``.
See the
[Extended Canvas Explained](https://github.com/pyroscope/rtorrent-ps/blob/master/docs/RtorrentExtendedCanvas.md#extended-canvas-explained)
page on how to use them.


### system.env=«name» (merged into 0.9.7+)

Returns the value of the given environment variable, or an empty string if it does not exist.

Configuration example:

```ini
session.path.set="$cat=\"$system.env=RTORRENT_HOME\",\"/.session\""
```


### ui.status.throttle_up_name.set="«name»"

Displays values of the given throttle.up in the first part of status bar.
Include the max limit of the throttle, the main upload rate and the upload rate of the throttle (in this order).

Original: ``[Throttle 500/1500 KB] [Rate: 441.6/981.3 KB]``

Modified: ``[Throttle 500 (200)/1500 KB] [Rate: 441.6 (190.0|51.6)/981.3 KB]``

This extra info isn't displayed in the following cases:

  * there isn't any throttle.up name as the config variable suggest or the given name is "NULL"
  * the throttle.up is not throttled (=0)
  * the global upload is not throttled (=0) (throttle.up won't be taken into account in this case)

Configuration example:

```ini
ui.status.throttle_up_name.set="slowup"
```

</dd>

</dl>


## Backports of git `master` fixes and features to 0.9.2
The following fixes and features of the development version are patched into the 0.9.2 version of rTorrent-PS:
  * [Wait for disowned HTTP requests to finish, to ensure stopped event gets sent to tracker on client shutdown](https://github.com/rakshasa/rtorrent/commit/b79dea94b2f537eda620ed48207369c076fcd11f).
  * Also, the broken announce interval handling is fixed.
