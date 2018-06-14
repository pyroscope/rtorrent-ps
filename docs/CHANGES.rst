Change History
==============

.. contents:: List of Releases
   :local:


2018-07-xx v1.1 “Design Your Canvas”
------------------------------------

Read the related `pyrocore update to 0.6.x`_ instructions,
which will update configuration snippets in the ``rtorrent.d`` directories.
These are **required** to run the new version
– else you'll get visual defects at the very minimum,
but worse stuff might happen.

If you do not have a ``~/rtorrent/rtorrent.d`` directory,
then you just have to know yourself what to do
– the helper scripts can only handle standard situations and setups.

-  Docs: Much improved (moved to *Read the Docs* and using *Sphinx*)
-  UI: Added responsive canvas v2 with full customization (issue #60)

   - New ``ui.column.render`` multi-command
   - Added ``ui.column.hide`` and 3 related commands
   - Added 3 new ``convert.*`` commands
   - Added ``ui.color.custom1…9`` and ``ui.color.*.index`` commands
   - New default columns: ❢ ℞ ⋉ ≣
   - ‘Tagged’ indicator (⚑) now in its own column
   - Built-in views are collapsed by default now

-  UI: ``Info`` details panel is now active by default (not
   ``Peer list``)
-  UI: Made ``*`` key a built-in keyboard shortcut [@chros73]
-  Command: Added ``string.*`` command group (issue #59)
-  Command: Added ``math.*`` command group [@chros73] (issue #65)
-  Command: Added ``value`` conversion command
-  Command: Added ``array.at`` command (issue #60)
-  Command: Added ``d.custom.if_z`` and 2 other new ``d.custom.*``
   commands
-  Command: Added ``d.is_meta`` command [@chros73]
-  Command: Added ``system.has`` and 3 other related commands (issue
   #82)
-  Command: Added ``d.multicall.filtered``
-  Command: Added ``import.return`` private command
-  Command: Added ``throttle.names`` (issue #65)
-  Command: Added ``ui.bind_key.verbose`` flag (issue #55)
-  Command: Added ``event.view.hide`` and ``event.view.show`` events
-  Fix: Prevent filtering of ``started`` and ``stopped`` views
   [@chros73] (issue #36)
-  Fix: ``system.file.allocate.set=[0|1]`` semantics [@chros73] (issue
   #41)
-  Fix: ``log.messages`` – restored lost patch for message writing
   (issue #78)
-  Fix: ``start`` handles platforms using ``RUNPATH`` instead of
   ``RPATH``
-  Patch: ``catch`` command is silent when first command is ``false=``
-  Build: ``bootstrap`` script – switch to Python3 (issue #84)
-  Build: Improved git build process
-  Build: ``all`` now really does it all, and added a few more actions
-  Build: Allow installation of several concurrent patch versions
-  Build: Apply patches for OpenSSL 1.1 (on platforms using it)
-  Build: Added ``-std=c++0x`` option (needed for ``algorithm::median``
   patch)
-  Build: Fixed ``CXXFLAGS`` for GCC 6+
-  Build: Dropped *rTorrent* 0.8.x/0.9.2 support (issue #26)
-  Build: Fedora 26 support (if you use this: it's unmaintained, unless
   people open PRs)
-  Tasks: Added integration tests for commands –
   ``invoke test [-n ‹name›]`` (issue #84)
-  Tasks: New ``cmd_docs`` task to generate extension command index
-  Docker: Run ``pkg2deb`` for several Debian / Ubuntu LTS versions
-  Docker: Run an EMPHEMERAL rTorrent-PS instance in a Stretch container

**NOTE:** Support for rTorrent versions before 0.9.6 and non-C++11
compilers will end soon!


.. _`pyrocore update to 0.6.x`: https://pyrocore.readthedocs.io/en/latest/updating.html#upgrade-to-0-6-x


2017-03-12 v1.0 “First version-tagged release”
----------------------------------------------

-  Improved build script
-  ``system.random = [[<lower>,] <upper>]`` command
-  UI: tracker alias mappings

   - ``trackers.alias.set_key=«domain»,«alias»`` and
     ``trackers.alias.items=`` commands

-  New Arch AUR PKGBUILDs, and ``pkg2pacman`` action by @xsmile (#48)
-  More flexible installation options (#43)
-  Easier manual setup with ``make-rtorrent-config.sh`` script
