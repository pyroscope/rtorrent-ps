rTorrent-PS
===========

Extended `rTorrent` distribution with UI enhancements, colorization, and some added features.

![Extended Canvas Screenshot](https://raw.githubusercontent.com/pyroscope/rtorrent-ps/master/images/rT-PS-094-2014-05-24-shadow.png)

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
  * interface additions:
    * easily customizable colors.
    * collapsed 1-line item display.
    * network bandwidth graph.
    * displaying the tracker domain for each item.
    * some more minor modifications to the download list view.

To get those, you just need to either follow the build instructions, or download and install a package from Bintray — assuming one is available for your platform.


For more details, see the [wiki page at Google code](https://code.google.com/p/pyroscope/wiki/RtorrentExtended).


## Installation

### General

See the [instructions on Google code](https://code.google.com/p/pyroscope/wiki/DebianInstallFromSource#rTorrent_installation),
for either package based installation, or building from source.

Also take note of the [pimp-my-box](https://github.com/pyroscope/pimp-my-box) project
that does it all (almost) automatically for Debian-type systems (and is the preferred way to install on those systems).
The automation is done using [Ansible](http://docs.ansible.com/),
which implies you can easily admin several systems with it, and also maintain them –
so it's not a one-shot installation bash script creating a setup that can never be changed again.

### Packages

* The build script is able to build a DEB package (living in `/opt/rtorrent`), pre-built ones for some Debian and Ubuntu versions can be found on [Bintray](https://bintray.com/pyroscope/rtorrent-ps).
* There is an AUR package [rtorrent-pyro-git](https://aur.archlinux.org/packages/rtorrent-pyro-git/) for Arch Linux.


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
For a few platforms (recent Debian and Ubuntu), you can find pre-built ones
at [Bintray](https://bintray.com/pyroscope/rtorrent-ps/rtorrent-ps).


## References

  * https://github.com/rakshasa/rtorrent
  * [rTorrent Community Wiki](http://community.rutorrent.org/)
