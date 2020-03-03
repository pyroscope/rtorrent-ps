Setup & Configuration
=====================

The main part of configuration regarding *rTorrent-PS* itself is already done,
if you followed  :ref:`DebianInstallFromSource` or used `pimp-my-box`_ for it.
If you used neither, look into what `make-rtorrent-config.sh`_ does (see also :ref:`make-rtorrent-config`),
in order to get all the features described in the :doc:`manual`,
which in large part rely on those standard configuration snippets.

This chapter contains hints on what you might need to do regarding
the runtime environment and your system setup.

You can skip to the :doc:`next chapter <manual>` to learn about
the special `rTorrent-PS` features and come back to this later,
provided everything looks OK to you when you first started `rTorrent-PS`
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
and ``LC_CTYPE`` should **not** be set at all! If you use a terminal
multiplexer like most people do, and the display doesn't look right, try
``tmux -u`` or ``screen -U`` to force UTF-8 mode.

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

In case you have unsolvable problems with only a few specific glyphs,
see :ref:`add-custom-columns` below on how to change them to ones working for you,
or even switch them to plain ASCII.


.. _term-win:

Terminal Setup on Windows
^^^^^^^^^^^^^^^^^^^^^^^^^

To get full coverage of all Unicode glyphs used in the :ref:`extended canvas <extended-canvas>`,
the steps below show you how to use font linking to make ``Everson Mono`` complement ``DejaVu Sans Mono``
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

The `term-256color.py`_ script can help you with showing the colors your
terminal supports, an example output using Gnome's terminal looks like
the following...

.. figure:: _static/img/xterm-256-color.png
   :align: center
   :alt: xterm-256-color

   Output of **term-256-color.py**

.. _`term-256color.py`: https://github.com/pyroscope/rtorrent-ps/blob/master/term-256color.py

.. _`rTorrent Scripting`: https://rtorrent-docs.readthedocs.io/en/latest/scripting.html#
.. _`~/rtorrent/rtorrent.d/05-rt-ps-columns-v2.rc.include`: https://github.com/pyroscope/pimp-my-box/blob/master/roles/rtorrent-ps/templates/rtorrent/rtorrent.d/05-rt-ps-columns-v2.rc.include#L5


.. _trouble-shooting:

Trouble-Shooting Guide
----------------------

Reporting Problems
^^^^^^^^^^^^^^^^^^

If you have any trouble during *rTorrent-PS* installation and configuration,
or using any of the commands from the documentation,
join the `rtorrent-community`_ channel `rtorrent-ps`_ on Gitter.
You can also ask questions on platforms like `Reddit`_ or `Stack Exchange`_.

.. image:: https://raw.githubusercontent.com/pyroscope/pyrocore/master/docs/_static/img/help.png
    :align: left

If you are sure there is a bug, then `open an issue`_ on *GitHub*.
Report any problems that are clearly rooted in the *rTorrent* core
to the `upstream issue tracker`_.

Make sure that nobody else reported the same problem before you,
there is a `search box`_ you can use (after the **Filters** button).
Please note that the *GitHub* issue tracker is not a support platform,
use the Gitter channel or Reddit for any questions, as mentioned above.

And ESR's golden oldie `How To Ask Questions The Smart Way`_ is still a most valuable resource, too.

.. note::

    Please **describe your problem clearly**, and provide any pertinent
    information.
    What are the **version numbers** of software and OS?
    What did you do?
    What was the **unexpected result**?
    If things worked and ‘suddenly’ broke, **what did you change**?

    **In the chat, don't ask if somebody is there, just describe your problem**.
    Eventually, someone will notice you – people *do* live in different time zones than you.

    Put up any logs on `0bin <http://0bin.net/>`_ or any other pastebin
    service, and **make sure you removed any personal information** you
    don't want to be publically known. Copy the pastebin link into the
    chat window.


The following helps with querying your system environment, e.g. the
version of Python and your OS.

.. _`rtorrent-community`: https://gitter.im/rtorrent-community/
.. _`rtorrent-ps`: https://gitter.im/rtorrent-community/rtorrent-ps
.. _`pyroscope-users`: http://groups.google.com/group/pyroscope-users
.. _`open an issue`: https://github.com/pyroscope/rtorrent-ps/issues
.. _`search box`: https://help.github.com/articles/searching-issues/
.. _`upstream issue tracker`: https://github.com/rakshasa/rtorrent/issues
.. _`How To Ask Questions The Smart Way`: http://www.catb.org/~esr/faqs/smart-questions.html
.. _`Reddit`: https://www.reddit.com/r/rtorrent/
.. _`Stack Exchange`: https://unix.stackexchange.com/


Providing Diagnostic Information
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Python Diagnostics
""""""""""""""""""

Execute the following command to be able to provide some information on
your Python installation:

.. code-block:: shell

    deactivate 2>/dev/null; /usr/bin/virtualenv --version; python <<'.'
    import sys, os, time, pprint
    pprint.pprint(dict(
        version=sys.version,
        prefix=sys.prefix,
        os_uc_names=os.path.supports_unicode_filenames,
        enc_def=sys.getdefaultencoding(),
        maxuchr=sys.maxunicode,
        enc_fs=sys.getfilesystemencoding(),
        tz=time.tzname,
        lang=os.getenv("LANG"),
        term=os.getenv("TERM"),
        sh=os.getenv("SHELL"),
    ))
    .

If ``enc_fs`` is **not** ``UTF-8``, then call
``dpkg-reconfigure locales`` (on Debian type systems) and choose a
proper locale (you might also need ``locale-gen en_US.UTF-8``), and make
sure ``LANG`` is set to ``en_US.UTF-8`` (or another locale with UTF-8
encoding).


OS Diagnostics
""""""""""""""

Similarly, execute this in a shell prompt:

.. code-block:: shell

    uname -a; echo $(lsb_release -as 2>/dev/null); grep name /proc/cpuinfo | uniq -c; \
    free -m | head -n2; uptime; \
    strings $(which rtorrent) | grep "client version"; \
    ldd $(which rtorrent) | egrep "lib(torrent|curses|curl|xmlrpc.so|cares|ssl|crypto)"; \
    ps auxw | egrep "USER|/rtorrent" | grep -v grep


Common Problems & Solutions
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Please `open an issue`_ on *GitHub* if you think that you have a problem that happens a lot,
or you know several other people have the same problem,
and **it's not already mentioned below**.


.. _columns-invalid-key:

Error in option file: …/05-rt-ps-columns.rc:…: Invalid key
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

You combined a brand-new `pimp-my-box` configuration with an older version of `rTorrent-PS`.


.. rubric:: Solution ♯1 (preferred)

Update to a recent build `rTorrent-PS`.

Also make sure your ``~/rtorrent/rtorrent.rc`` is the `newest one`_ with the line…

.. code-block:: ini

    method.insert = pyro.extended, const|value, (system.has, rtorrent-ps)

This auto-detects the presence of `rTorrent-PS`, but only works with builds from June 2018 onwards.


.. rubric:: Solution ♯2

Replace this line in ``~/rtorrent/rtorrent.rc``…

.. code-block:: ini

    method.insert = pyro.extended, const|value, (system.has, rtorrent-ps)

with that one…

.. code-block:: ini

    method.insert = pyro.extended, const|value, 1


.. _`newest one`: https://github.com/pyroscope/pimp-my-box/blob/master/roles/rtorrent-ps/templates/rtorrent/rtorrent.rc#L1


.. _term-8colors:

Startup Failure: ‘your terminal only supports 8 colors’
"""""""""""""""""""""""""""""""""""""""""""""""""""""""

See :ref:`terminal-setup` for detailed help on proper terminal setup.

If all else fails or you're in a rush, you can switch to the 8-color theme
by calling the ``echo`` command as shown and then start *rTorrent-PS* again:

.. code-block:: shell

    echo default-8 >~/.pyroscope/color-schemes/.current
    ~/rtorrent/start

If you don't use the standard configuration (where theme support comes from),
then add the ``ui.color.*`` commands from this `configuration snippet`_ to ``rtorrent.rc``,
which does the same thing.

.. _`configuration snippet`: https://github.com/pyroscope/pyrocore/blob/master/src/pyrocore/data/config/color-schemes/default-8.rc#L1


.. _ldd-runpath:

Startup Failure: ‘libxmlrpc_*.so cannot open shared object file’
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

On newer systems, ``RPATH`` is replaced by ``RUNPATH`` with consequences
regarding the search path for *transitive* library dependencies (like that of
``libxmlrpc`` to the other ``libxmlrpc_*`` libraries).
In the end, those transitive dependencies cannot be resolved without some
extra config.

The solution is to use the provided `start script`_, which explicitly sets
``LD_LIBRARY_PATH`` from any ``RPATH`` or ``RUNPATH`` found in the executable.
Or if you use a systemd unit, use an ``Environment`` directive to set the
library path, e.g. ``Environment=LD_LIBRARY_PATH=/opt/rtorrent/lib``.

.. _start script: https://github.com/pyroscope/pyrocore/blob/master/docs/examples/start.sh#L1-L4
