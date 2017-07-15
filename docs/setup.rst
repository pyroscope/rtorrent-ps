Setup & Configuration
=====================

The main part of configuration regarding *rTorrent-PS* itself is already done,
if you followed  :ref:`DebianInstallFromSource` or used `pimp-my-box`_ for it.

This chapter provides some background on the standard configuration and how you can tweak it,
and contains hints on what you might need to do regarding
the runtime environment and your system setup.

You can skip to the :doc:`next chapter <manual>` to learn about
the special rTorrent-PS features and come back to this later,
provided everything looks ok to you when you first started *rTorrent-PS*
(especially if all special characters render correctly).

.. _pimp-my-box: https://github.com/pyroscope/pimp-my-box


Setting up your Terminal Emulator
---------------------------------

General Concerns
^^^^^^^^^^^^^^^^

There are two major obstacles for a proper display of the extended canvas,
and that is selecting the right font(s) and providing a terminal setup that
supports 256 or more colors.


.. _term-win:

On Windows
^^^^^^^^^^

**TODO**

    -- based on `feedback by @NoSubstitute`_

.. _`feedback by @NoSubstitute`: https://github.com/pyroscope/rtorrent-ps/issues/8


.. _term-linux:

On Linux
^^^^^^^^

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
