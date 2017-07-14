# rTorrent-PS Change History

 * [2017-07-xx PS-1.1 “Design Your Canvas”](#2017-07-xx-ps-11-design-your-canvas)
 * [2017-03-12 PS-1.0 “First version-tagged release”](#2017-03-12-ps-10-first-version-tagged-release)


## 2017-07-xx PS-1.1 “Design Your Canvas”

* Docs: Moved to *Read the Docs* and using *Sphinx*
* UI: Added canvas customization (issue #60)
  * New `ui.column.render` multi-command
* Command: Added `ui.bind_key.verbose` flag (issue #55)
* Command: Added `d.multicall.filtered`
* Command: Added `string.contains` and `string.contains_i`
* Command: Added `value` conversion command
* Command: Added `convert.human_size` and `convert.magnitude`
* Command: Added `event.view.hide` and `event.view.show`
* Fix: Prevent filtering of ``started`` and ``stopped`` views [@chros73] (issue #36)
* Fix: `system.file.allocate.set=[0|1]` semantics [@chros73] (issue #41)
* Fix: `start` handles platforms using `RUNPATH` instead of `RPATH`
* Build: Improved git build process
* Build: `all` now really does it all, and added a few more actions
* Build: Allow installation of several concurrent patch versions
* Build: Apply patches for OpenSSL 1.1 (on platforms using it)
* Docker: Run `pkg2deb` for several Debian / Ubuntu LTS versions
* Docker: Run an EMPHEMERAL rTorrent-PS instance in a Stretch container

NOTE: Support for rTorrent versions before 0.9.6 and non-C++11 compilers will end soon!


## 2017-03-12 PS-1.0 “First version-tagged release”

* Improved build script
* `system.random = [[<lower>,] <upper>]` command
* UI: tracker alias mappings
  * `trackers.alias.set_key=«domain»,«alias»` and `trackers.alias.items=` commands
* New Arch AUR PKGBUILDs, and `pkg2pacman` action by @xsmile (#48)
* More flexible installation options  (#43)
* Easier manual setup with `make-rtorrent-config.sh` script
