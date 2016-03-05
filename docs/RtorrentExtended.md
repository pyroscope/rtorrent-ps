# rTorrent-PS Reference

# :bangbang: NOTE THIS PAGE STILL NEEDS TO BE UPDATED TO GITHUB LINKS ETC.

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


## Command extensions
The following new commands are available.

<dl>
<dt>
<h2><code>compare=order,command1=[,...]</code></h2>
</dt>
<dd>
Compares two items like <code>less=</code> or <code>greater=</code>, but allows to compare<br>
by several different sort criteria, and ascending or descending<br>
order per given field.<br>
<br>
The first parameter is a string of order<br>
indicators, either <code>aA+</code> for ascending or <code>dD-</code> for descending.<br>
The default, i.e. when there's more fields than indicators, is<br>
ascending. Field types other than value or string are treated<br>
as equal (or in other words, they're ignored).<br>
If all fields are equal, then items are ordered in a random, but<br>
stable fashion.<br>

Configuration example:

```ini
# VIEW: Show active and incomplete torrents (in view #9) and update every 20 seconds
# Items are grouped into complete, incomplete, and queued, in that order.
# Within each group, they're sorted by upload and then download speed.
view_sort_current = active,"compare=----,d.is_open=,d.get_complete=,d.get_up_rate=,d.get_down_rate="
schedule = filter_active,12,20,"view_filter = active,\"or={d.get_up_rate=,d.get_down_rate=,not=$d.get_complete=}\" ;view_sort=active"
```

</dd>

<dt>
<h2><code>ui.bind_key=display,key,"command1=[,...]"</code></h2>
</dt>
<dd>
<br /> <b>⚠ WARNING: This currently can NOT be used immediately when <code>rtorrent.rc</code> is parsed, so it has to be scheduled once shortly after startup (see below example).</b>

Binds the given key on a specified display to execute the commands when pressed.<br>
<br>
<ul><li><code>display</code> must be equal to <code>download_list</code> (currently, no other displays are supported).<br>
</li><li><code>key</code> can be either a single character for normal keys, or <code>^</code> plus a character for control keys.</li></ul>

Configuration example:

```ini
# VIEW: Bind view #7 to the "rtcontrol" result
schedule = bind_7,0,0,"ui.bind_key=download_list,7,ui.current_view.set=rtcontrol"
```

</dd>

<dt>
<h2><code>view.collapsed.toggle=«VIEW NAME»</code></h2>
</dt>
<dd>
This command changes between the normal item display where each item takes up three lines to a more condensed form where each item only takes up one line. Note that each view has its own state, and that if the view name is empty, the current view is toggled. You can set the default state in your configuration, by adding a toggle command for each view you want collapsed after startup (the default is expanded).<br>
<br>
Also, you should bind the current view toggle to a key, like this:<br>
<pre><code>schedule = bind_collapse,0,0,"ui.bind_key=download_list,*,view.collapsed.toggle="<br>
</code></pre>

Further explanations on what the columns show and what forms of abbreviations are used, to get a display as compact as possible while still showing all the important stuff, can be found on RtorrentExtendedCanvas. That page also contains hints on <b>how to correctly setup your terminal</b>.<br>
<br>
</dd>

<dt>
<h2><code>ui.color.«TYPE».set="«COLOR DEF»"</code></h2>
</dt>
<dd>
These commands allow you to set colors for selected elements of the user interface, in some cases depending on their status. You can either provide colors by specifying the numerical index in the terminal's color table, or by name (for the first 16 colors). The possible color names are "black", "red", "green", "yellow", "blue", "magenta", "cyan", "gray", and "white"; you can use them for both text and background color, in the form "«fg» on «bg»", and you can add "bright" in front of a color to select a more luminous version. If you don't specify a color, the default of your terminal is used.<br>
<br>
Also, these additional modifiers can be placed in the color definitions, but it depends on the terminal you're using whether they have an effect: "bold", "standout", "underline", "reverse", "blink", and "dim".<br>
<br>
Here's a configuration example showing all the commands and their defaults:<br>
<br>
<pre><code># UI/VIEW: Colors<br>
ui.color.alarm.set="bold white on red"<br>
ui.color.complete.set="bright green"<br>
ui.color.even.set=""<br>
ui.color.focus.set="reverse"<br>
ui.color.footer.set="bold bright cyan on blue"<br>
ui.color.incomplete.set="yellow"<br>
ui.color.info.set="white"<br>
ui.color.label.set="gray"<br>
ui.color.leeching.set="bold bright yellow"<br>
ui.color.odd.set=""<br>
ui.color.progress0.set="red"<br>
ui.color.progress20.set="bold bright red"<br>
ui.color.progress40.set="bold bright magenta"<br>
ui.color.progress60.set="yellow"<br>
ui.color.progress80.set="bold bright yellow"<br>
ui.color.progress100.set="green"<br>
ui.color.progress120.set="bold bright green"<br>
ui.color.queued.set="magenta"<br>
ui.color.seeding.set="bold bright green"<br>
ui.color.stopped.set="blue"<br>
ui.color.title.set="bold bright white on blue"<br>
</code></pre>

Note that you might need to enable support for 256 colors in your terminal, see <a href='http://askubuntu.com/questions/67/how-do-i-enable-full-color-support-in-terminal'>this article</a> for a description. In a nutshell, you need to install the <code>ncurses-term</code> package if you don't have it already, and also add these commands to your rTorrent start script:<br>
<br>
<pre><code>if [ "$TERM" = "${TERM%-256color}" ]; then<br>
    export TERM="$TERM-256color"<br>
fi<br>
</code></pre>

Also consider the hints at the end of the RtorrentExtendedCanvas page.<br>
<br>
If everything worked so far, and you now want to find you own coloring theme, the easiest way is to use a second shell and <code>rtxmlrpc</code>. Try out some colors, and add the combinations you like to your <code>~/.rtorrent.rc</code>.<br>
<br>
<pre><code># For people liking candy stores...<br>
rtxmlrpc ui.color.title.set "bold magenta on bright cyan"<br>
</code></pre>


The <a href='https://raw.githubusercontent.com/pyroscope/rtorrent-ps/master/term-256color.py'>term-256color</a> script can help you with showing the colors your terminal supports, an example output using Gnome's terminal looks like the following...<br>
<br>
<img src='http://i.imgur.com/iu8nY.png' />
</dd>

<dt>
<h2><code>d.tracker_domain=</code></h2>
</dt>
<dd>
Returns the (shortened) <i>tracker domain</i> of the given download item. The chosen tracker is the first HTTP one with active peers (seeders or leechers), or else the first one.<br>
</dd>

<dt>
<h2><code>ui.current_view=</code></h2>
</dt>
<dd>
Returns the currently selected view, the official release only has a setter. Needed if you want to use »<code>-</code>« as a view name in <code>rtcontrol</code>.<br>
</dd>

<dt>
<h2><code>log.messages=«path»</code> (0.8.9+ only)</h2>
</dt>
<dd>
(Re-)opens a log file that contains the messages normally only visible on the main panel and via the <code>l</code> key. Each line is prefixed with the current date and time in ISO8601 format.<br>
If an empty path is passed, the file is closed.<br>
</dd>

<dt>
<h2><code>network.history.*=</code> (0.8.9+ only)</h2>
</dt>
<dd>
Commands to add network traffic charts to the bottom of the collapsed download display.<br>
The commands added are <code>network.history.depth[.set]=</code>,  <code>network.history.sample=</code>,  <code>network.history.refresh=</code>, and <code>network.history.auto_scale=</code>.<br>
See the RtorrentExtendedCanvas page on how to use them.<br>
</dd>

<dt>
<h2><code>system.env=«name»</code></h2>
</dt>
<dd>
Returns the value of the given environment variable, or an empty string if it does not exist.

Configuration example:

```ini
session.path.set="$cat=\"$system.env=RTORRENT_HOME\",\"/.session\""
```

</dd>

</dl>


## Backports of 0.8.8 features to 0.8.6
The following features of newer versions are patched into the 0.8.6 version of rTorrent-PS:
  * [Changeset #1206](http://libtorrent.rakshasa.no/changeset/1206): `network.http.ssl_verify_peer.set` used to disable checking of self-signed SSL certificates.

## Backports of git `master` fixes and features to 0.8.9
The following fixes and features of the development version are patched into the 0.8.9 version of rTorrent-PS:

  * a fix in libtorrent for a problem located in the epoll event handling code (#1246).
  * fixed check of the XML-RPC task queue length (#1246).
  * a possible busy loop when trying to interrupt the main loop (#1263).
  * `log.execute` is fixed, and stays open.
  * no more zombies with `execute.*.bg`.
  * backports of these new commands: `d.chunks_seen`, `t.is_usable`, and `t.is_busy`.


## Backports of git `master` fixes and features to 0.9.2
The following fixes and features of the development version are patched into the 0.9.2 version of rTorrent-PS:
  * [Wait for disowned HTTP requests to finish, to ensure stopped event gets sent to tracker on client shutdown](https://github.com/rakshasa/rtorrent/commit/b79dea94b2f537eda620ed48207369c076fcd11f).
  * Also, the broken announce interval handling is fixed.
