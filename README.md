rTorrent-PS
===========

Extended `rTorrent` distribution with UI enhancements, colorization, and some added features.

![Extended Canvas Screenshot](https://raw.githubusercontent.com/pyroscope/rtorrent-ps/master/docs/_static/img/rT-PS-094-2014-05-24-shadow.png)

**Contents**

  * [Introduction](#introduction)
  * [Feature Overview](#feature-overview)
  * [Installation](#installation)
    * [General Installation Options](#general-installation-options)
    * [Installation Using Debian Packages](#installation-using-debian-packages)
    * [Homebrew Tap for Mac OSX](#homebrew-tap-for-mac-osx)
    * [Installation on Arch Linux](#installation-on-arch-linux)
  * [Building the Debian Package](#building-the-debian-package)
  * [References](#references)


## Introduction

`rTorrent-PS` is *not* the same as the `PyroScope`
[command line utilities](https://github.com/pyroscope/pyrocore#pyrocore),
and doesn't depend on them; the same is true the other way 'round.
It's just that both unsurprisingly have synergies if used together,
and some features *do* only work when both are present.

To get in contact and share your experiences with other users of `rTorrent-PS`,
join the [pyroscope-users](http://groups.google.com/group/pyroscope-users) mailing list
or the inofficial ``##rtorrent`` channel on ``irc.freenode.net``.


## Feature Overview

`rTorrent-PS` is a `rTorrent` distribution in form of a set of patches
that improve the user experience and stability of official `rTorrent` releases.

The main changes are these:

  * self-contained install into any location of your choosing, including your home directory, offering the ability to run several versions at once (in different client instances).
  * rpath-linked to the major dependencies, so you can upgrade those independently from your OS distribution's versions.
  * extended command set:
    * sort views by more than one value, and set the sort direction for each of these.
    * bind keys in the root display to any command, e.g. change the built-in views.
    * record network traffic.
  * interface additions:
    * easily customizable colors.
    * collapsed 1-line item display with condensed information.
    * network bandwidth graph.
    * displaying the tracker domain for each item.
    * some more minor modifications to the download list view.

To get those, you just need to either follow the build instructions, or download and install a package from Bintray
— assuming one is available for your platform.
See below for installation instructions — more detailed reference information can be found on the
[RtorrentExtended](https://github.com/pyroscope/rtorrent-ps/blob/master/docs/RtorrentExtended.md)
and
[RtorrentExtendedCanvas](https://github.com/pyroscope/rtorrent-ps/blob/master/docs/RtorrentExtendedCanvas.md)
pages.
[DebianInstallFromSource](https://github.com/pyroscope/rtorrent-ps/blob/master/docs/DebianInstallFromSource.md)
contains installation instructions for a working rTorrent instance in combination with `pyrocore`,
on Debian and most Debian-derived distros — i.e. a manual way to do parts of what
[pimp-my-box](https://github.com/pyroscope/pimp-my-box)
does automatically for you.


## Installation

### General Installation Options

See the
[instructions here](https://github.com/pyroscope/rtorrent-ps/blob/master/docs/DebianInstallFromSource.md#build-rtorrent-and-core-dependencies-from-source)
for building from source using the provided ``build.sh`` script,
which will install *rTorrent-PS* into ``~/lib/rtorrent-‹version›``.

:exclamation: | If you also install the [PyroScope command line utilities](https://github.com/pyroscope/pyrocore), do not forget to activate the extended features available together with *rTorrent-PS*, as mentioned in the [Configuration Guide](https://pyrocore.readthedocs.org/en/latest/setup.html#extending-your-rtorrent-rc).
----: | :----

Also take note of the [pimp-my-box](https://github.com/pyroscope/pimp-my-box) project
that does it all (almost) automatically for Debian-type systems (and is the preferred way to install on those systems).
The automation is done using [Ansible](http://docs.ansible.com/),
which implies you can easily admin several systems with it, and also maintain them –
so it's not a one-shot installation bash script creating a setup that can never be changed again.

### Installation Using Debian Packages

For a limited set of Debian-derived platforms, there are packages available that
contain pre-compiled binaries (and only those, no configuration or init scripts).
You can download and install such a package from
[Bintray](https://bintray.com/pyroscope/rtorrent-ps) —
assuming one is available for your platform.
The packages install the *rTorrent-PS* binary including some libraries into ``/opt/rtorrent``.

Example on Raspbian Jessie:

```sh
version="0.9.6-20160308-c7c8d31~jessie_armhf"
cd /tmp
curl -Lko rt-ps.deb "https://bintray.com/artifact/download/pyroscope/rtorrent-ps/rtorrent-ps_$version.deb"
dpkg -i rt-ps.deb
```

After installation, you must provide a configuration file (``~/.rtorrent.rc``),
and either use the absolute path to the binary to start it,
or link it into ``/usr/local`` like this:

```sh
ln -s /opt/rtorrent/bin/rtorrent /usr/local/bin
```

:information_source: | You can safely install the package and test it out in parallel to an existing installation, just use the absolute path `/opt/rtorrent/bin/rtorrent` to start rTorrent. Your data is in no way affected as long as you normally run a 0.9.x version.
----: | :----


### Homebrew Tap for Mac OSX

See the [homebrew-rtorrent-ps](https://github.com/pyroscope/homebrew-rtorrent-ps) repository
for instructions to build *rTorrent-PS* and related dependencies on Mac OSX.

### Installation on Arch Linux

There is an AUR package [rtorrent-pyro-git](https://aur.archlinux.org/packages/rtorrent-pyro-git/)
for Arch Linux. If you have problems installing it, contact *the maintainer* of the package.


## Building the Debian Package

A Debian package for easy installation is built using [fpm](https://github.com/jordansissel/fpm),
so you have to install that first on the build machine, if you don't have it yet:

```sh
apt-get install ruby ruby-dev
gem install fpm
fpm -h | grep fpm.version
```

Then you need to prepare the install target, as follows (we assume building under the `rtorrent` user here):

```sh
mkdir -p /opt/rtorrent
chmod 0755 /opt/rtorrent
chown -R rtorrent.rtorrent /opt/rtorrent
```

Then, the contents of the package are built by calling `./build.sh install`,
which will populate the `/opt/rtorrent` directory. When that is done, you can test
the resulting executable located at `/opt/rtorrent/bin/rtorrent`.

Finally, `./build.sh pkg2deb` creates the Debian package in `/tmp`.
The script expects the packager's name and email in the usual environment variables,
namely `DEBFULLNAME` and `DEBEMAIL`.
For a few platforms (recent Debian, Ubuntu, and Raspbian), you can find pre-built ones
at [Bintray](https://bintray.com/pyroscope/rtorrent-ps/rtorrent-ps).


## References

  * https://github.com/rakshasa/rtorrent
  * [rTorrent Community Wiki](http://community.rutorrent.org/)
