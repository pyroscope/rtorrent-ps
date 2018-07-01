Change History
==============

.. contents:: List of Releases
   :local:


2018-07-01 v1.1 “Design Your Canvas”
------------------------------------

This release adds the new fully customizable and responsive *canvas v2*,
and many new configuration and XMLRPC commands plus a few fixes
– see below for a full list of changes.
It comes with complete documentation hosted on *Read the Docs* and built with *Sphinx*.
Binary builds for *Debian* and *Ubuntu* are available as DEB packages on *Bintray*.

Note that *rTorrent-PS* is based on the *stable* release of *rTorrent*,
and that is still version 0.9.6 at the time of this release.
Many of the features and commands in version 0.9.7 are originally developed in
or otherwise back-ported to this project anyway.

Read the related `pyrocore update to 0.6.x`_ instructions,
which will update configuration snippets in the ``rtorrent.d`` directories.
If you used those snippets before, their update is **required** to run the new version
– else you'll get visual defects at the very minimum,
but worse stuff might happen.

If you do not have a ``~/rtorrent/rtorrent.d`` directory created by the helper scripts,
then you just have to know yourself what to do (i.e. browse through ``git`` diffs)
– those scripts can only handle standard situations and setups.


-  Docs: Much improved (moved to *Read the Docs* and using *Sphinx*)
-  UI: Added responsive *canvas v2* with full customization (issue #60)

   - New ``ui.column.render`` multi-command
   - Added ``ui.column.hide`` and related commands
   - Added 3 new ``convert.*`` commands
   - Added ``ui.color.custom1…9`` and ``ui.color.*.index`` commands
   - New default columns: ❢ ℞ ⋉ ≣
   - New alert indicators for “tracker down” and “DNS problems”
   - ‘Tagged’ indicator (⚑) now in its own column
   - Built-in views are collapsed by default now

-  UI: ``Info`` details panel is now active by default (not ``Peer list``)
-  UI: Made ``*`` key a built-in keyboard shortcut [@chros73]
-  UI: Key to toggle sacrificial columns manually (bound to ``/``)
-  Command: Added ``string.*`` command group (issue #59)
-  Command: Added ``math.*`` command group [@chros73] (issue #65)
-  Command: Added ``value`` conversion command
-  Command: Added ``array.at`` command (issue #60)
-  Command: Added ``d.custom.if_z`` and more ``d.custom.*`` commands (issue #101)
-  Command: Added ``d.is_meta`` command [@chros73]
-  Command: Added ``d.tracker_alias`` command (issue #97)
-  Command: Added ``d.multicall.filtered``
-  Command: Added ``system.has`` and 3 other related commands (issue #82)
-  Command: Added ``system.client_version.as_value`` command
-  Command: Added ``do`` command (issue #98)
-  Command: Added ``import.return`` private command
-  Command: Added ``throttle.names`` (issue #65)
-  Command: Added ``ui.bind_key.verbose`` flag (issue #55)
-  Command: Added ``event.view.hide`` and ``event.view.show`` events
-  Fix: Prevent filtering of ``started`` and ``stopped`` views [@chros73] (issue #36)
-  Fix: ``system.file.allocate.set=[0|1]`` semantics [@chros73] (issue #41)
-  Fix: ``log.messages`` – restored lost patch for message writing (issue #78)
-  Fix: Properly close XMLRPC log, i.e. only *once* (issue #94)
-  Fix: ``start`` handles platforms that use ``RUNPATH`` instead of ``RPATH``
-  Patch: ``catch`` command is silent when first command is ``false=``
-  Build: ``bootstrap`` script – switch to Python3 (issue #84)
-  Build: Improved git build process
-  Build: ``all`` now really does it all, and added a few more actions
-  Build: Allow installation of several concurrent patch versions
-  Build: Apply patches for OpenSSL 1.1 (on platforms using it)
-  Build: Added ``-std=c++11|0x`` option (needed for ``algorithm::median`` patch)
-  Build: Fixed ``CXXFLAGS`` for GCC 6+
-  Build: Dropped *rTorrent* 0.8.x/0.9.2 support (issue #26)
-  Build: Fedora 26 support (if you use this: it's unmaintained, unless people open PRs)
-  Tasks: Added integration tests for commands – ``invoke test [-n ‹name›]`` (issue #84)
-  Tasks: New ``cmd_docs`` task to generate extension command index
-  Docker: Run ``pkg2deb`` for several Debian / Ubuntu LTS versions
-  Docker: Run an *EPHEMERAL* rTorrent-PS instance in a `Debian Stretch` container

**NOTE:** Support for `rTorrent` versions before 0.9.6 and non-C++11
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
