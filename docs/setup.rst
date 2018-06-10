Setup & Configuration
=====================

The main part of configuration regarding *rTorrent-PS* itself is already done,
if you followed  :ref:`DebianInstallFromSource` or used `pimp-my-box`_ for it.
If you used neither, look into what `make-rtorrent-config.sh`_ does (see also :ref:`make-rtorrent-config`),
in order to get all the features described in the :doc:`manual`.

This chapter provides some background on the standard configuration and how you can tweak it,
and contains hints on what you might need to do regarding
the runtime environment and your system setup.

You can skip to the :doc:`next chapter <manual>` to learn about
the special `rTorrent-PS` features and come back to this later,
provided everything looks ok to you when you first started `rTorrent-PS`
(especially that all special characters render correctly).

.. _pimp-my-box: https://github.com/pyroscope/pimp-my-box
.. _make-rtorrent-config.sh: https://github.com/pyroscope/pyrocore/blob/master/src/scripts/make-rtorrent-config.sh


.. _terminal-setup:

Setting up Your Terminal Emulator
---------------------------------

General Concerns
^^^^^^^^^^^^^^^^

There are two major obstacles for a proper display of the extended canvas,
and that is selecting the right font(s) and providing a terminal setup that
supports 256 or more colors.

Read the following sections on how to solve any problems you might encounter
within your environment.


Font Selection & Encoding Issues
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Whatever font you use in your terminal profile, it has to support the
characters used in the column headers and some of the displayed values,
else you're getting a degraded user experience.
Also, your terminal **must** be set to use UTF-8, which nowadays usually is the default anyway.

On `Linux`, that means ``LANG`` should be something like ``en_US.UTF-8``, and ``LC_ALL``
and ``LC_CTYPE`` should **not** bet set at all! If you use a terminal
multiplexer like most people do, and the display doesn't look right, try
``tmux -u`` respectively ``screen -U`` to force UTF-8 mode.

Also make sure you have the ``locales`` package installed on Debian-type systems,
and the ``en_US.UTF-8`` locale actually created. See :ref:`install-locale` for that.

The following command lets you easily check whether your font supports
the most important characters and your terminal is configured correctly:

.. code-block:: shell

    PYTHONIOENCODING=utf-8 python -c 'print(u"\u22c5 \u22c5\u22c5 \u201d \u2019 \u266f \u2622 " \
        u"\u260d \u2318 \u2730 \u28ff \u26a1 \u262f \u2691 \u21ba \u2934 \u2935 \u2206 \u231a " \
        u"\u2240\u2207 \u2707 \u26a0\xa0\u25d4 \u26a1\xa0\u21af \xbf \u2a02 \u2716 \u21e3 \u21e1 " \
        u"\u2801 \u2809 \u280b \u281b \u281f \u283f \u287f \u28ff \u2639 \u2780 \u2781 \u2782 " \
        u"\u2783 \u2784 \u2785 \u2786 \u2787 \u2788 \u2789 \u25b9\xa0\u254d \u25aa \u26af \u2692 " \
        u"\u25cc \u21c5 \u21a1 \u219f \u229b \u267a ")'

In case you have unsolvable problems with only a few specifc glyphs,
see :ref:`add-custom-columns` below on how to change them to ones working for you,
or even switch to plain ASCII.


.. _term-win:

Terminal Setup on Windows
^^^^^^^^^^^^^^^^^^^^^^^^^

To get full coverage of all Unicode glyphs used in the :ref:`extended canvas <extended-canvas>`,
the steps below show you how to use font linking to make ``Everson Mono`` complement ``DevaVu Sans Mono``
when used in ``PuTTY`` version 0.70 or higher.

#. Download and install the `DejaVu Sans Mono`_ and `Everson Mono`_ fonts.
#. Next, add or edit a multi-string value for your preferred font under this Windows registry key::

      HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\FontLink\SystemLink

   To do that start ``regedit`` and go to that folder. Any key there names a font for which
   fallback fonts are registered. So add/edit the ``DejaVu Sans Mono`` key, and add fallback
   font references as its value.

      * Right click ``SystemLink`` and select ``New``, then ``Multi String Value``.
      * Use ``DejaVu Sans Mono`` as the key's name.
      * Double-click the new key, and enter this as the value::

         Everson Mono.ttf,EversonMono

#. After closing ``regedit``, logout from Windows and back in again to activate the font link,
   but a full reboot is safer (hey, it's Windows, you should be used to it).
#. Start ``PuTTY`` and select ``Change settings`` from the menu.

      * In ``Window › Appearance`` select ``DejaVu Sans Mono``.
      * Set ``UTF-8`` in ``Window / Translation``
      * Under ``Terminal`` check ``Use background colour to erase screen``.
      * In ``SSH › Data``, make sure to use ``putty-256color`` for the ``terminal`` setting.

#. Connect, and check the display.

Other fonts that were suggested are ``Andale Mono``, and
``GNU Unifont``. You have to try out yourself what looks good to you and
works with your specific system and terminal emulator.
Read `more about fallback fonts`_ on `superuser.com`.


.. epigraph::

   -- based on `feedback by @NoSubstitute`_, with help from `superuser.com`_ and `MSDN`_

.. seealso::

    `Font linking on Windows <https://github.com/chros73/rtorrent-ps_setup/wiki/Windows-8.1#font-linking-on-windows>`_
    and `Using KiTTY instead of PuTTY <https://github.com/chros73/rtorrent-ps_setup/wiki/Windows-8.1#connect-via-ssh>`_


.. _`more about fallback fonts`: http://superuser.com/a/764855
.. _`Everson Mono`: http://www.evertype.com/emono/
.. _`DejaVu Sans Mono`: https://dejavu-fonts.github.io/Download.html
.. _superuser.com: http://superuser.com/questions/393834/how-to-configure-putty-to-display-these-characters/764855#764855
.. _superuser Q&A: http://superuser.com/questions/393834/how-to-configure-putty-to-display-these-characters
.. _MSDN: https://msdn.microsoft.com/en-us/goglobal/bb688134.aspx
.. _`feedback by @NoSubstitute`: https://github.com/pyroscope/rtorrent-ps/issues/8


.. _term-linux:

Terminal Setup on Linux
^^^^^^^^^^^^^^^^^^^^^^^

When you use ``gnome-terminal``, everything should work out of the box,
given you use the ``start`` script, which sets ``TERM`` and ``LANG`` correctly.
Also always call ``tmux`` with the ``-2u`` options.

If you use ``urxvt``, you have to provide fallback fonts as on *Windows*.
Add the following to your ``~/.Xresources``::

    URxvt*font: xft:DejaVu Sans Mono:style=regular:pixelsize=15,xft:Noto Sans Mono CJK JP:pixelsize=15,xft:FreeSerif

Note that *15pt* is a threshold for the font size,
below it ``urxvt`` thinks there's not enough space to render the glyphs.

Generally, to cope with problems like this or find other fonts that suit you better,
the ``ttfdump`` tool can help to check out fonts on the technical level.
Another helper is the ``gucharmap`` GUI tool, that allows you to explore your installed fonts visually.

.. epigraph::

    -- based on `feedback by @ymvunjq`_

.. _`feedback by @ymvunjq`: https://github.com/pyroscope/rtorrent-ps/issues/44


.. _color-schemes:

Color Scheme Configuration
--------------------------

This section describes how you can change all the colors in `rTorrent-PS` to your liking.
Note that there are `existing color schemes`_ provided by the `pyrocore` configuration,
and you can rotate through them using the ``~`` key thanks to `rtorrent.d/theming.rc`_.

You can copy one of the provided color scheme ``*.rc.default`` files in ``~/.pyroscope/color-schemes/``
to a new ``‹mytheme›.rc`` file.
Details about how to specify colors and so on are in the sub-sections that follow.

.. contents:: Color Configuration Details
   :local:

And here are some visuals of the default schemes…

|color-scheme-default|   |color-scheme-happy-pastel|

|color-scheme-solarized-blue|   |color-scheme-solarized-yellow|

.. _`existing color schemes`: https://github.com/pyroscope/pyrocore/tree/master/src/pyrocore/data/config/color-schemes
.. _`rtorrent.d/theming.rc`: https://github.com/pyroscope/pyrocore/blob/master/src/pyrocore/data/config/rtorrent.d/theming.rc#L1

.. |color-scheme-default| image:: _static/img/color-scheme-default.png
    :width: 320px
.. |color-scheme-happy-pastel| image:: _static/img/color-scheme-happy-pastel.png
    :width: 320px
.. |color-scheme-solarized-blue| image:: _static/img/color-scheme-solarized-blue.png
    :width: 320px
.. |color-scheme-solarized-yellow| image:: _static/img/color-scheme-solarized-yellow.png
    :width: 320px


.. _canvas-256-colors:

Supporting 256 or More Colors
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Having 256 colors available means you can select very dark shades of
grey, and that can be used for subtle even / odd line backgrounds
in the collapsed canvas of `rTorrent-PS`.

To enable 256 colors, your terminal must obviously be able to support
them at all (i.e. have a ``xterm-256color`` terminfo entry, or similar).
But even if that is the case, you often need to give a little nudge to
the terminal multiplexers; namely start ``tmux`` with the ``-2`` switch
(that forces 256 color mode), or for ``screen`` start it with the
terminal already set to 256 color mode so it can sense the underlying
terminal supports them, i.e. use this in your startup script:

.. code-block:: shell

    if [ "$TERM" = "${TERM%-256color}" ]; then
        export TERM="$TERM-256color"
    fi
    tmux ...

Then, within the terminal multiplexer's environment, you must **again**
ensure the terminal is set to a 256 color terminfo entry.
See the `.tmux.conf by @chros73`_ for possible solutions for any tmux-related problems.

The reward for jumping through all those hoops is that you can then use
color gradients for ratio coloring, and much more appropriate pallid
color shades for backgrounds.


.. _PyroScope CLI Tools: https://pyrocore.readthedocs.org/
.. _`.tmux.conf by @chros73`: https://github.com/chros73/rtorrent-ps-ch_setup/blob/master/ubuntu-14.04/home/chros73/.tmux.conf#L1


Showing a Terminal's Palette
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The ``term-256color.py`` script can help you with showing the colors your
terminal supports, an example output using Gnome's terminal looks like
the following...

.. figure:: _static/img/xterm-256-color.png
   :align: center
   :alt: xterm-256-color

   Output of **term-256-color.py**


Working With Color Schemes
^^^^^^^^^^^^^^^^^^^^^^^^^^

If your terminal works as intended,
you now might want to find you own coloring theme.
The easiest way is to use a second shell and ``rtxmlrpc``. Try
out some colors, and add the combinations you like to your
``~/.rtorrent.rc``.

.. code-block:: shell

    # For people liking candy stores...
    rtxmlrpc ui.color.title.set "bold magenta on bright cyan"

You can use the following code in a terminal to dump a full color scheme from the running client:

.. code-block:: shell

    for i in $(rtxmlrpc system.listMethods | egrep '^ui.color.[^.]+$'); do
        echo $i = $(rtxmlrpc -r $i | tr "'" '"') ;
    done


Adding Your Own Color Schemes
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Color schemes are lists of ``ui.color.‹color name›.set`` commands in your configuration,
or in a  ``*.rc[.default]`` file in the ``~/.pyroscope/color-schemes/`` directory.
If you want to use scheme rotation at all (via the ``~`` key),
put your own schemes into extra ``color-schemes/*.rc`` files and not the main configuration.

The set of color names is predetermined and refers to the *meaning* of the color,
i.e. where it is used on the canvas. ``footer`` and ``alarm`` are obvious examples.

Here's a configuration example showing all the commands and their defaults:

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

See the `ui.color.* command reference`_ for details on these and related commands.


The following color settings work better than the default ones in a 256
color terminal (gnome-terminal), for me at least. Your mileage (color
table) may vary. Having 256 colors means you have very dark shades of
grey, and that is used here to set the even / odd backgrounds.

.. code-block:: ini

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

|rt-ps-glyphs|

.. |rt-ps-glyphs| image:: _static/img/rt-ps-glyphs.png


Note that you might need to enable support for 256 colors in your
terminal, see :ref:`canvas-256-colors` for a description. In a nutshell, you need to
install the ``ncurses-term`` package if you don't have it already, and
also add these commands to your `rTorrent` start script:

.. code-block:: shell

    if [ "$TERM" = "${TERM%-256color}" ]; then
        export TERM="$TERM-256color"
    fi


.. _`ui.color.* command reference`: https://rtorrent-docs.readthedocs.io/en/latest/cmd-ref.html#term-ui-color-custom1-9


Customizing the Display Layout
------------------------------

Canvas v2 Overview
^^^^^^^^^^^^^^^^^^

The main display with the downloads list is flexible and
can be configured to your will, in `rTorrent-PS 1.1` and up.
This is also known as *canvas v2*.

Use the following `rtxmlrpc`_ command to check if you have a version
that can do this:

.. code-block:: console

    $ rtxmlrpc "system.has=,canvas_v2"
    1
    # The '1' means you have canvas v2 on board;
    # a '0' or "Method 'system.has' not defined" means you don't.


The only fixed parts are the position indicator at the very left of the display,
and the combined name / tracker column on the right.
The latter takes all the space left by other columns.


Inspecting Your Display
^^^^^^^^^^^^^^^^^^^^^^^

To list the columns you have in your setup, call  `rtxmlrpc`_ like so:

.. code-block:: console

    $ rtxmlrpc method.get=,ui.column.render | sed -re 's/ /␣/g' | sort
    100:3C95/2:❢␣␣
    110:2C92/2:☢␣
    120:?2:☍␣
    130:?2:⌘␣
    400:?3C23/3:␣↺␣
    410:?3C24/3:␣⤴␣
    420:?3C14/3:␣⤵␣
    500:?2:⚡␣
    510:3C28/3:℞␣␣
    520:6C96/6:∆⋮␣⌛␣␣
    530:6C90/6:∇⋮␣⌚␣␣
    800:3:⋉␣
    900:?5C24/3C21/2:␣Σ⇈␣␣
    910:2C94/2:⣿␣
    920:3C93/3:☯␣␣
    930:5C15/3C21/2:␣✇␣␣␣
    970:2C91/2:✰␣
    980:2C16/2:⚑␣

The important thing here are the numbers in front,
which define the sort order of columns from left to right.
They also allow to address a specific column,
which becomes important in a moment.

All these are built-in defaults, except the throttle indicator ``⋉`` with index 800,
which is defined in `~/rtorrent/rtorrent.d/05-rt-ps-columns-v2.rc.include`_ of `pimp-my-box`_.

.. important::

    You **MUST** update your `pimp-my-box`_ configuration
    if you used that to set up your system.
    Otherwise you'll get duplicate columns.

To show the full column definitions with their code, call `pyroadmin`_:

.. code-block:: console

    $ pyroadmin --dump-rc | grep -A1 ui.column.render | egrep '^(method.set_key|    )'
    method.set_key = ui.column.render, "100:3C95/2:❢  ", \
        ((array.at, {"  ", "♺ ", "⚠ ", "◔ ", "⚡ ", "↯ ", "¿?", "⨂ "}, ((d.message.alert)) ))
    method.set_key = ui.column.render, "110:2C92/2:☢ ", \
        ((string.map, ((cat, ((d.is_open)), ((d.is_active)) )), {00, "▪ "}, …, {11, "▹ "}))
    …
    method.set_key = ui.column.render, "980:2C16/2:⚑ ", \
        ((array.at, {"  ", "⚑ "}, ((d.views.has, tagged)) ))


Column Layout Definitions
^^^^^^^^^^^^^^^^^^^^^^^^^

The keys of the ``ui.column.render`` multi-command must follow a defined format,
namely ``‹index›:〈?〉‹width›〈‹color definition›〉:‹title›``.
There are three fields, separated by colons.
The parts in ``〈…〉`` are optional.

``‹index›`` was already mentioned, used for sorting and addressing columns.

The second field can start with a ``?`` to tag this column as ‘sacrificial’,
i.e. optional in the face of too narrow terminals.
``‹width›`` is a column's width in characters.
The ``‹color definition›`` determines what terminal attributes are used to render these characters,
and is a sequence of ``C‹color index›/‹length›`` elements.

Finally, ``‹title›`` is used for the column's heading.
Make sure to end it with a space to leave room for wide Unicode glyphs,
and always make it as long as the column width.


To get a color index table, try this command:

.. code-block:: shell

    rtxmlrpc system.has.private_methods \
        | egrep '^ui.color.*index$' \
        | xargs -I+ rtxmlrpc -i 'print="+ = ",(+)'

Since the ``ui.color.*index`` commands are private, the output must go to the `rTorrent` console.
This is what you'll see (timestamps removed):

.. code-block:: ini

    ui.color.alarm.index = 22
    ui.color.complete.index = 23
    ui.color.custom1.index = 1
    ui.color.custom2.index = 2
    ui.color.custom3.index = 3
    ui.color.custom4.index = 4
    ui.color.custom5.index = 5
    ui.color.custom6.index = 6
    ui.color.custom7.index = 7
    ui.color.custom8.index = 8
    ui.color.custom9.index = 9
    ui.color.even.index = 30
    ui.color.focus.index = 19
    ui.color.footer.index = 18
    ui.color.incomplete.index = 27
    ui.color.info.index = 21
    ui.color.label.index = 20
    ui.color.leeching.index = 28
    ui.color.odd.index = 29
    ui.color.progress0.index = 10
    ui.color.progress20.index = 11
    ui.color.progress40.index = 12
    ui.color.progress60.index = 13
    ui.color.progress80.index = 14
    ui.color.progress100.index = 15
    ui.color.progress120.index = 16
    ui.color.queued.index = 26
    ui.color.seeding.index = 24
    ui.color.stopped.index = 25
    ui.color.title.index = 17

There are also columns with *dynamic* color schemes, using a color index ≥ 90,
which map to a ‘normal’ color index depending on an item's attributes.
An example is ``3C95/2`` for the alert column,
which changes to red (``ui.color.alarm``) if there is an active alert.

This is a list of the dynamic color schemes:

    * 90: ``DOWN_TIME`` – Download (∇ *leeching*) or time display (⌚ *info* + *seeding*/*incomplete*)
    * 91: ``PRIO`` – A color for ✰, depending on ``d.priority``: *progress0*, *progress60*, *info*, *progress120*
    * 92: ``STATE`` – A color for ☢, depending on ``d.is_open`` (*progress0* if not) and ``d.is_active`` (*progress80* or *progress100*)
    * 93: ``RATIO`` – A *progress* color for ☯ from 0 to 120
    * 94: ``PROGRESS`` – A *progress* color from 0 to 100 for the ⣿ column
    * 95: ``ALERT`` – For ❢, *info* or *alarm* depending on alert state
    * 96: ``UP_TIME`` – Upload (∆ *seeding*) or time display (⌛ *info* + *seeding*/*incomplete*)

The mixed ``DOWN_TIME`` and ``UP_TIME`` schemes must span the full width of the column,
and can only be used with *one* color definition in the column key (anything after them is ignored).


.. _add-custom-columns:

Defining Your Own Columns
^^^^^^^^^^^^^^^^^^^^^^^^^

.. image:: _static/img/rt-ps-canvas_v2-ascii-ratio.png
    :align: right
    :alt: Canvas v2 ASCII Ratio Column

This example shows how to replace the ratio column (920)
with a pure ASCII version. You can see the result on the right.

Place this code in your custom configuration,
e.g. in the ``_rtlocal.rc`` file (when using `pimp-my-box`_).

.. code-block:: ini

    # Hide default column
    ui.column.hide = 920

    # Add ASCII ratio in percent
    # (1..99 for incomplete; 1c = 1.0; 1m = 10.0; …)
    method.set_key = ui.column.render, "922:3C93/3:R% ", \
        ((string.replace, ((convert.magnitude, ((math.div, ((d.ratio)), 10)) )), \
                          {"⋅", "."} ))

To construct a column definition like this,
you need to understand `rTorrent Scripting`_ first
– more so than what's sufficient for writing simple configurations.

Looking at the original column definition often helps, e.g. to grab a few snippets for your own version:

.. code-block:: ini

    $ pyroadmin --dump-rc | egrep -A1 '"920:.+"'
    method.set_key = ui.column.render, "920:3C93/3:☯  ", \
        ((string.substr, "☹ ➀ ➁ ➂ ➃ ➄ ➅ ➆ ➇ ➈ ➉ ", \
                         ((math.mul, 2, ((math.div, ((d.ratio)), 1000)) )), 2, "⊛ "))

Also, try to understand how all the other column definitions work,
you can learn a few tricks that are typical for column rendering.

.. image:: _static/img/rt-ps-canvas_v2-chunk-size.png
    :align: right
    :alt: Canvas v2 Chunk Size Column

Especially if you want to display additional values in the same format as an existing column,
you just have to swap the command accessing the displayed item's data.
Here's a chunk size column, all you need to do is
replace ``d.size_bytes`` in the code of column 930 with ``d.chunk_size``,
and give it a new index and heading.

.. code-block:: ini

    ui.color.custom9.set = "bright blue"
    method.set_key = ui.column.render, "935:5C9/3C21/2: ≣   ", \
        ((convert.human_size, ((d.chunk_size)) ))

That example also shows how to use a custom color.


Disabling Columns
^^^^^^^^^^^^^^^^^

The ``ui.column.show`` and ``ui.column.hide`` commands provide the means to
easily change the visibility of columns, without touching their definition.
They both take a list of column keys as their arguments, as either strings or values.

The following example shows column ♯42 only on the *active* and *leeching* views,

.. code-block:: ini

    method.set_key = event.view.show, ~column_42_toggle, \
        "branch = \"string.contains=$ui.current_view=, active, leeching\", \
            ui.column.show=42, ui.column.hide=42"
    ui.column.hide = 42

The ``ui.column.is_hidden`` and ``ui.column.hidden.list`` commands can be used to query the visibility of columns,
the first one takes a single column key as its argument.

.. code-block:: console

    $ rtxmlrpc --repr ui.column.is_hidden '' 42
    1
    $ rtxmlrpc --repr ui.column.hidden.list
    [42]

A practical use of ``ui.column.is_hidden`` is to toggle a column.
This code does so for ♯935, and binds the toggle to the ``_`` key.

.. code-block:: ini

    method.insert = pmb._toggle_chunk_size, simple|private, \
        "branch = ui.column.is_hidden=935, ui.column.show=935, ui.column.hide=935 ; \
         ui.current_view.set = (ui.current_view)"
    pyro.bind_key = toggle_chunk_size, _, "pmb._toggle_chunk_size="

The ``ui.current_view.set = (ui.current_view)`` part forces a redraw of the canvas,
giving you instant feedback.


Adding Traffic Graphs
^^^^^^^^^^^^^^^^^^^^^

Add these lines to your configuration:

.. code-block:: ini

    # Show traffic of the last hour
    network.history.depth.set = 112
    schedule = network_history_sampling,1,32, network.history.sample=
    method.insert = network.history.auto_scale.toggle, simple|private, \
        "branch=network.history.auto_scale=, \
            \"network.history.auto_scale.set=0\", \
            \"network.history.auto_scale.set=1\""
    method.insert = network.history.auto_scale.ui_toggle, simple|private, \
        "network.history.auto_scale.toggle= ;network.history.refresh="
    branch=pyro.extended=,"schedule = bind_auto_scale,0,0, \
        \"ui.bind_key=download_list,=,network.history.auto_scale.ui_toggle=\""

And you'll get this in your terminal:

.. figure:: _static/img/rt-ps-network-history.png
   :align: center
   :alt: rTorrent-PS Network History

   rTorrent-PS Network History

As you can see, you get the upper and lower bounds of traffic within
your configured time window, and each bar of the graph represents an
interval determined by the sampling schedule. Pressing ``=`` toggles
between a graph display with base line 0, and a zoomed view that scales
it to the current bounds.


.. _`rTorrent Scripting`: https://rtorrent-docs.readthedocs.io/en/latest/scripting.html#
.. _`rtxmlrpc`: https://pyrocore.readthedocs.io/en/latest/usage.html#rtxmlrpc
.. _`pyroadmin`: https://pyrocore.readthedocs.io/en/latest/references.html#pyroadmin
.. _`~/rtorrent/rtorrent.d/05-rt-ps-columns-v2.rc.include`: https://github.com/pyroscope/pimp-my-box/blob/master/roles/rtorrent-ps/templates/rtorrent/rtorrent.d/05-rt-ps-columns-v2.rc.include#L5
