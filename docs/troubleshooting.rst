Trouble-Shooting Guide
======================

Reporting Problems
------------------

If you have any trouble during *rtorrent-ps* installation and configuration,
join the `pyroscope-users`_ mailing list or the inofficial ``##rtorrent`` channel on
``irc.freenode.net``. IRC will generally provide a faster resolution.

If you are sure there is a bug, then `open an issue`_ on *GitHub*.
Report any problems that are clearly rooted in the *rTorrent* core
to the `upstream issue tracker`_.

Make sure that nobody else reported the same problem before you,
there is a `search box`_ you can use (after the **Filters** button).
Please note that the *GitHub* issue tracker is not a support platform,
use the mailing list or IRC for that.

.. note::

    Please **describe your problem clearly**, and provide any pertinent
    information.
    What are the **version numbers** of software and OS?
    What did you do?
    What was the **unexpected result**?
    If things worked and ‘suddenly’ broke, **what did you change**?

    **On IRC, don't ask if somebody is there, just describe your problem**.
    Eventually, someone will notice you – IRC is a global medium, and
    people *do* live in different time zones than you.

    Put up any logs on `0bin <http://0bin.net/>`_ or any other pastebin
    service, and **make sure you removed any personal information** you
    don't want to be publically known. Copy the pastebin link into IRC
    or into your post.

.. _`pyroscope-users`: http://groups.google.com/group/pyroscope-users
.. _`open an issue`: https://github.com/pyroscope/rtorrent-ps/issues
.. _`search box`: https://help.github.com/articles/searching-issues/
.. _`upstream issue tracker`: https://github.com/rakshasa/rtorrent/issues


Common Problems & Solutions
---------------------------

Please `open an issue`_ on *GitHub* if you think that you have a problem that happens a lot,
or you know several other people have the same problem,
and **it's not already mentioned below**.


.. _columns-invalid-key:

Error in option file: …/05-rt-ps-columns.rc:…: Invalid key
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

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
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

See the :doc:`setup` chapter for detailed help on proper terminal setup.

If all else fails or you're in a rush, you can switch to the 8-color theme
by calling the ``echo`` command as shown and then start *rTorrent-PS* again:

.. code-block:: shell

    echo default-8 >~/.pyroscope/color-schemes/.current
    ~/rtorrent/start

If you don't use the standard configuration (where theme support comes from),
then add the ``ui.color.*`` commands from this `configuration snippet`_ to ``rtorrent.rc``,
which does the same thing.

.. _`configuration snippet`: https://github.com/pyroscope/pyrocore/blob/master/src/pyrocore/data/config/color-schemes/default-8.rc


.. _ldd-runpath:

Startup Failure: ‘libxmlrpc_*.so cannot open shared object file’
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

On newer systems, ``RPATH`` is replaced by ``RUNPATH`` with consequences
regarding the search path for *transitive* library dependencies (like that of
``libxmlrpc`` to the other ``libxmlrpc_*`` libraries).
In the end, those transitive dependencies cannot be resolved without some
extra config.

The solution is to use the provided `start script`_, which explicitly sets
``LD_LIBRARY_PATH`` from any ``RPATH`` or ``RUNPATH`` found in the executable.
Or if you use a systemd unit, use an ``Environment`` directive to set the
library path, e.g. ``Environment=LD_LIBRARY_PATH=/opt/rtorrent/lib``.

.. _start script: https://github.com/pyroscope/pyrocore/blob/master/docs/examples/start.sh
