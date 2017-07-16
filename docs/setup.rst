Setup & Configuration
=====================

The main part of configuration regarding *rTorrent-PS* itself is already done,
if you followed  :ref:`DebianInstallFromSource` or used `pimp-my-box`_ for it.
If you used neither, look into what `make-rtorrent-config.sh`_ does,
in order to get all the features described in the :doc:`manual`.

This chapter provides some background on the standard configuration and how you can tweak it,
and contains hints on what you might need to do regarding
the runtime environment and your system setup.

You can skip to the :doc:`next chapter <manual>` to learn about
the special rTorrent-PS features and come back to this later,
provided everything looks ok to you when you first started *rTorrent-PS*
(especially if all special characters render correctly).

.. _pimp-my-box: https://github.com/pyroscope/pimp-my-box
.. _make-rtorrent-config.sh: https://github.com/pyroscope/pyrocore/blob/master/src/scripts/make-rtorrent-config.sh


Setting up your Terminal Emulator
---------------------------------

General Concerns
^^^^^^^^^^^^^^^^

There are two major obstacles for a proper display of the extended canvas,
and that is selecting the right font(s) and providing a terminal setup that
supports 256 or more colors.

Also consider these sources:

-  `color configuration <https://github.com/pyroscope/rtorrent-ps/blob/master/docs/RtorrentExtended.md#uicolortypesetcolor-def>`_
-  `tmux and 256 colors <https://github.com/pyroscope/rtorrent-ps/blob/master/docs/RtorrentExtendedCanvas.md#using-the-extended-canvas-with-tmux--screen-and-256-colors>`_
-  `(Windows) Terminal Setup <https://github.com/pyroscope/rtorrent-ps/blob/master/docs/RtorrentExtendedCanvas.md#setting-up-your-terminal>`_


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
      * Under ``Terminal`` check ``Use background colour to erase screen``.
      * In ``SSH › Data``, make sure to use ``putty-256color`` for the ``terminal`` setting.

#. Connect, and check the display.

   -- based on `feedback by @NoSubstitute`_, with help from `superuser.com`_ and `MSDN`_

.. seealso::

    `Font linking on Windows <https://github.com/chros73/rtorrent-ps_setup/wiki/Windows-8.1#font-linking-on-windows>`_
    and `Using KiTTY instead of PuTTY <https://github.com/chros73/rtorrent-ps_setup/wiki/Windows-8.1#connect-via-ssh>`_


.. _`Everson Mono`: http://www.evertype.com/emono/
.. _`DejaVu Sans Mono`: https://dejavu-fonts.github.io/Download.html
.. _superuser.com: http://superuser.com/questions/393834/how-to-configure-putty-to-display-these-characters/764855#764855
.. _MSDN: https://msdn.microsoft.com/en-us/goglobal/bb688134.aspx
.. _`feedback by @NoSubstitute`: https://github.com/pyroscope/rtorrent-ps/issues/8


.. _term-linux:

Terminal Setup on Linux
^^^^^^^^^^^^^^^^^^^^^^^

When you use ``gnome-terminal``, everything should work out of the box,
given you use the ``start`` script, which sets ``TERM`` correctly.
Also always call ``tmux`` with the ``-2u`` options.

If you use ``urxvt``, you have to provide fallback fonts as on *Windows*.
Add the following to your ``~/.Xresources``::

    URxvt*font: xft:DejaVu Sans Mono:style=regular:pixelsize=15,xft:Noto Sans Mono CJK JP:pixelsize=15,xft:FreeSerif

Note that *15pt* is a threshold for the font size,
below it ``urxvt`` thinks there's not enough space to render the glyphs.

Generally, to cope with problems like this or find other fonts that suit you better,
the ``ttfdump`` tool can help to check out fonts on the technical level.
Another helper is the ``gucharmap`` GUI tool, that allows you to explore your installed fonts visually.

    -- based on `feedback by @ymvunjq`_

.. _`feedback by @ymvunjq`: https://github.com/pyroscope/rtorrent-ps/issues/44
