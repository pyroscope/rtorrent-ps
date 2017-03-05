# Extended Canvas Explained

**Contents**

  * [Columns in the Collapsed Display](#columns-in-the-collapsed-display)
  * [Adding Traffic Graphs](#adding-traffic-graphs)
  * [Setting Up Your Terminal](#setting-up-your-terminal)
  * [Using the extended canvas with tmux / screen and 256 colors](#using-the-extended-canvas-with-tmux--screen-and-256-colors)


## Columns in the Collapsed Display

The following is an explanation of the collapsed display of [rTorrent-PS](RtorrentExtended.md)
— remember that you need to bind a key to the `view.collapsed.toggle` command,
or set the default of a view by calling that command in the configuration,
else you won't ever see it.

![rt-ps-trackers-view](https://raw.githubusercontent.com/pyroscope/rtorrent-ps/master/docs/_static/img/rt-ps-trackers-view.png)

| **Column** | **Description** |
|:-----------|:----------------|
| ☢ | Item state (▹ = started, ╍ = paused, ▪ = stopped) |
| ☍ | Tied item? [⚯] |
| ⌘ | Command lock-out? (⚒ = heed commands, ◌ = ignore commands) |
| ✰ | Priority (✖ = off, ⇣ = low, nothing for normal, ⇡ = high) |
| ⣿ | Completion status (✔ = done; else up to 8 dots [⣿], i.e. 9 levels of 11% each); change to bar style using `ui.style.progress.set=2`, `0` is a _mostly_ ASCII one |
| ⚡ | Transfer direction indicator [⇅ ↡ ↟] |
| ☯ | Ratio (☹  plus color indication for < 1, ➀  — ➉ : >= the number, ⊛ : >= 11); change to a different set of number glyphs using `ui.style.ratio.set=2` (or `3`), `0` is a _mostly_ ASCII one |
| ⚑ | Message (♺ = Tracker cycle complete, i.e. "Tried all trackers"; ⚡ = establishing connection; ↯ = data transfer problem; ◔ = timeout; ¿? = unknown torrent / info hash; ⨂ = authorization problem (possibly temporary); ⚠ = other; ⚑ = on the `tagged` view) |
| ↺ | Number of completions from last scrape info |
| ⤴ | Number of seeds from last scrape info |
| ⤵ | Number of leeches from last scrape info |
| ∆ | Upload rate |
| ⌚ ≀∇ | Approximate time since completion (units are «”’hdwmy» from seconds to years); for incomplete items the download rate or, if there's no traffic, the time since the item was loaded |
| ✇ | Data size |
| Name | Name of the download item |
| Tracker Domain | Domain of the first HTTP tracker with seeds or leeches, or else the first one altogether |

The scrape info numbers are exact only for values below 100,
else they indicate the order of magnitude using roman numerals
(c = 10², m = 10³, X = 10⁴, C = 10⁵, M = 10⁶).

For the completion time display to work, you need the following in your `.rtorrent.rc`,
which you already do if you installed the [PyroScope CLI Tools](https://pyrocore.readthedocs.org/) correctly
(i.e. using the standard `.rtorrent.rc` include):

```
system.method.set_key = event.download.finished,time_stamp,"d.set_custom=tm_completed,$cat=$system.time= ;d.save_session="
```


## Adding Traffic Graphs

Add these lines to your configuration:

```ini
# Show traffic of the last hour
network.history.depth.set = 112
schedule = network_history_sampling,1,32, network.history.sample=
method.insert = network.history.auto_scale.toggle, simple|private, "branch=network.history.auto_scale=,\"network.history.auto_scale.set=0\",\"network.history.auto_scale.set=1\""
method.insert = network.history.auto_scale.ui_toggle, simple|private, "network.history.auto_scale.toggle= ;network.history.refresh="
branch=pyro.extended=,"schedule = bind_auto_scale,0,0,\"ui.bind_key=download_list,=,network.history.auto_scale.ui_toggle=\""
```

And you'll get this in your terminal:

![rt-ps-network-history](https://raw.githubusercontent.com/pyroscope/rtorrent-ps/master/docs/_static/img/rt-ps-network-history.png)

As you can see, you get the upper and lower bounds of traffic
within your configured time window, and each bar of the graph
represents an interval determined by the sampling schedule.
Pressing `=` toggles between a graph display with base line 0,
and a zoomed view that scales it to the current bounds.


## Setting Up Your Terminal

The font used in the above example is `Inconsolata`,
and whatever font you use in your terminal profile,
it of course has to support the characters used in the status columns.
Also, your terminal **must** be set to use UTF-8
(which nowadays usually is the default anyway),
that means `LANG` should be something like `en_US.UTF-8`,
and `LC_ALL` and `LC_CTYPE` should **not** bet set at all!
If you use a terminal multiplexer like most people do,
and the display doesn't look right, try `tmux -u` respectively
`screen -U` to force UTF-8 mode. Also make sure you have the
`locales` package installed on Debian-type systems.

On Windows using PuTTY (version 0.60), change the settings for font and character set as follows:

  * `DejaVu Sans Mono` in `Window / Appearance`
  * `UTF-8` in `Window / Translation`

Also see this [superuser Q&A](http://superuser.com/questions/393834/how-to-configure-putty-to-display-these-characters) for additional tips, you especially should try to use `Everson Mono` as a fallback font [as described here](http://superuser.com/a/764855).

Other fonts that were suggested are `Andale Mono`, and `GNU Unifont`.
You have to try out yourself what looks good to you and works
with your specific system and terminal emulator.

The following command lets you easily check whether your font supports all the necessary characters and your terminal is configured correctly:

```sh
python -c 'print u"\u22c5 \u22c5\u22c5 \u201d \u2019 \u266f \u2622 \u260d \u2318 \u2730 " \
    u"\u28ff \u26a1 \u262f \u2691 \u21ba \u2934 \u2935 \u2206 \u231a \u2240\u2207 \u2707 " \
    u"\u26a0\xa0\u25d4 \u26a1\xa0\u21af \xbf \u2a02 \u2716 \u21e3 \u21e1  \u2801 \u2809 " \
    u"\u280b \u281b \u281f \u283f \u287f \u28ff \u2639 \u2780 \u2781 \u2782 \u2783 \u2784 " \
    u"\u2785 \u2786 \u2787 \u2788 \u2789 \u25b9\xa0\u254d \u25aa \u26af \u2692 \u25cc " \
    u"\u21c5 \u21a1 \u219f \u229b \u267a ".encode("utf8")'
```


## Using the extended canvas with tmux / screen and 256 colors ##

To enable 256 colors, your terminal must obviously be able to support them at all
(i.e. have a `xterm-256color` terminfo entry, or similar). But even if that is the case,
you often need to give a little nudge to the terminal multiplexers;
namely start `tmux` with the `-2` switch (that forces 256 color mode),
or for `screen` start it with the terminal already set to 256 color mode
so it can sense the underlying terminal supports them,
i.e. use this in your startup script:

```sh
if [ "$TERM" = "${TERM%-256color}" ]; then
    export TERM="$TERM-256color"
fi
screen ...
```

Then, within the terminal multiplexer's environment,
you must **again** ensure the `TERM` variable is set to a 256 color terminfo entry,
i.e. repeat the above `if` construct in your `rtorrent` start script.
The reward for jumping through all those hoops is that you can then use
color gradients for ratio coloring, and much more appropriate pallid color
shades for backgrounds.

The following color settings work better than the default ones in a
256 color terminal (gnome-terminal), for me at least.
Your mileage (color table) may vary.
Having 256 colors means you have very dark shades of grey,
and that is used here to set the even / odd backgrounds.

```
ui.color.complete.set=41
ui.color.stopped.set=33

ui.color.footer.set="bright cyan on 20"
ui.color.even.set="on 234"
ui.color.odd.set="on 232"

ui.color.progress0.set=196
ui.color.progress20.set=202
ui.color.progress40.set=213
ui.color.progress60.set=214
ui.color.progress80.set=226
ui.color.progress100.set=41
ui.color.progress120.set="bold bright green"
```

| ![rt-ps-glyphs](https://raw.githubusercontent.com/pyroscope/rtorrent-ps/master/docs/_static/img/rt-ps-glyphs.png) |
|:----|
