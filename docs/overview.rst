Overview
========

``rTorrent-PS`` is a `rTorrent`_ *distribution* (*not* a fork of it),
in form of a set of patches that **improve the user experience and stability**
of official ``rTorrent`` releases, and **releases new features more frequently**.
The :ref:`feature-list` below lists the major improvements and extensions.
Also see the `changelog`_ for a timeline of applied changes,
especially those since the last `official release`_.

.. figure:: https://raw.githubusercontent.com/pyroscope/rtorrent-ps/master/docs/_static/img/rT-PS-094-2014-05-24-shadow.png
   :align: center
   :alt: Extended Canvas Screenshot

Note that ``rTorrent-PS`` is *not* the same as the ``PyroScope``
`command line utilities <https://github.com/pyroscope/pyrocore#pyrocore>`_ (`pyrocore`),
and doesn't depend on them; the same is true the other way 'round.
It's just that both unsurprisingly have synergies if used together,
and some features *do* only work when both are present.

.. include:: include-contacts.rst

.. _`rTorrent`: https://github.com/rakshasa/rtorrent
.. _`changelog`: https://github.com/pyroscope/rtorrent-ps/blob/master/CHANGES.md
.. _`official release`: https://github.com/pyroscope/rtorrent-ps/releases


.. _feature-list:

Feature Overview
----------------

The main changes compared to vanilla `rTorrent`_ are these:

-  **self-contained installation** into any location of your choosing, including
   your home directory, offering the ability to **run several versions at once**
   (in different client instances).
-  **rpath-linked** to the major dependencies, so you can upgrade those
   independently from your OS distribution's versions.
-  **extended command set**:

   -  sort views by more than one value, and set the sort direction for
      each of these.
   -  (re-)bind keys in the downloads display to any command, e.g. change the
      built-in views.
   -  record and display network traffic.
   -  … and many more, see :ref:`commands` for details.

-  interface additions:

   -  easily **customizable colors**.
   -  **collapsed 1-line item display** with a condensed information presentation.
   -  almost **fully customizable downloads display** (selection of columns & adding new ones).
   -  **network bandwidth graph**.
   -  **displaying the tracker domain** for each item.
   -  some more minor modifications to the download list view.

To get those features, you just need to either follow the build instructions, or
download and install a package from Bintray — assuming one is available
for your platform. See the :doc:`install` on how to get your machine set up.


Supported Platforms
-------------------

The tested and officially supported platforms are `Debian` and any Debian-related Linux distro, specifically `Ubuntu`.
`Arch Linux` is supported via contributors, and `Fedore 26` has some limited support
– anything else vanilla rTorrent runs on will likely work too,
but in the end *you* have to fix any problems that might occur.
If you want better support for your platform, provide a *working* derivative of
``Dockerfile.Debian`` and necessary modifications to ``build.sh`` via a PR.

:ref:`DebianInstallFromSource` provides instructions to set up a working `rTorrent-PS` instance
in combination with ``pyrocore``, on Debian and most Debian-derived distros
— i.e. a manual way to do parts of what
`pimp-my-box <https://github.com/pyroscope/pimp-my-box>`_ does
automatically for you.
Another option for automatic setup of a similar system is the one by
`chros73 <https://github.com/chros73/rtorrent-ps_setup/wiki>`_.

To help out other users, you can add your own content with configuration tricks and the like to the
`project's wiki <https://github.com/pyroscope/rtorrent-ps/wiki#community-documentation>`_,
and show to the world you're awesome.

.. _`RtorrentExtended`: https://github.com/pyroscope/rtorrent-ps/blob/master/docs/RtorrentExtended.md
.. _`RtorrentExtendedCanvas`: https://github.com/pyroscope/rtorrent-ps/blob/master/docs/RtorrentExtendedCanvas.md


Launching a Demo in Docker
--------------------------

To try out `rTorrent-PS` without any headaches, and *if you have Docker 17.06+ installed*, you can use
the `launch-on-stretch.sh`_ script to run an *ephemeral* instance in a
*Debian Stretch* container, like this:

.. code-block:: bash

    git clone "https://github.com/pyroscope/rtorrent-ps.git" ~/src/rtorrent-ps
    ~/src/rtorrent-ps/docker/launch-on-stretch.sh

Detach from the process using ``Ctrl-P Ctrl-Q``,
and call ``reset`` to reset your terminal.

Reattach with ``docker attach rtps-on-stretch``,
then enter ``Ctrl-A r`` to refresh the ``tmux`` screen.

If you want to do that directly via SSH from a remote machine,
call ``ssh -t YOU@HOST "docker attach rtps-on-stretch"``
and then refresh with ``Ctrl-A r``.

Another use for such a container instance, besides taking a first look,
is trying out experimental configurations, without any impact on your main installation.

Incidentally, that script is also a condensed version of the :ref:`DebianInstallFromSource` instructions,
and can be used as a blue-print for your own ``Dockerfile``.


.. _`Bintray`: https://bintray.com/pyroscope/rtorrent-ps/rtorrent-ps
.. _launch-on-stretch.sh: https://github.com/pyroscope/rtorrent-ps/blob/master/docker/launch-on-stretch.sh
.. _README: https://github.com/pyroscope/rtorrent-ps#rtorrent-ps
