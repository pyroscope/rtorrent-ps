# Install rTorrent-PS and ‘pyrocore’ on Debian-type Systems

**Contents**

  * [Introduction](#introduction)
  * [Preparatory Steps](#preparatory-steps)
    * [Installing Build Dependencies](#installing-build-dependencies)
    * [Optional root Setup Steps](#optional-root-setup-steps)
  * [rTorrent Installation](#rtorrent-installation)
    * [rtorrent-ps Debian Packages](#rtorrent-ps-debian-packages)
    * [Build rtorrent and Core Dependencies From Source](#build-rtorrent-and-core-dependencies-from-source)
  * [PyroScope Installation](#pyroscope-installation)
  * [rTorrent Instance Setup](#rtorrent-instance-setup)
    * [rTorrent Startup Script](#rtorrent-startup-script)
    * [rTorrent Configuration](#rtorrent-configuration)
  * [PyroScope CLI Tools Configuration](#pyroscope-cli-tools-configuration)
  * [First Start and Testing](#first-start-and-testing)
    * [tmux Configuration](#tmux-configuration)
    * [Starting a tmux Session](#starting-a-tmux-session)


## Introduction

The following shows installation instructions for a working rTorrent
instance in combination with PyroScope **from scratch**,
on Debian and most Debian-derived distros.
Note that the [pimp-my-box](https://github.com/pyroscope/pimp-my-box) project
does all this automatically for you, and is the tested and maintained way
of installation — this page is a reference of the core installation steps
and not really maintained any more (if you run into problems, join the
freenode IRC channel for help).

While the package names and the use of `apt-get` are somewhat dependant on
Debian, the _Preparatory Steps_ commands which are executed under `root`
are similar for other distributions, and the compilation instructions should
work as-is on practically any Linux and (F)BSD. These instructions are explicitly
known to work on *Debian Jessie*, and *Ubuntu Trusty + Xenial*.

:book: | If you don't understand a word of what follows, hit [The Debian Administrator's Handbook](http://static.debian-handbook.info/browse/stable/short-remedial-course.html) so then you do.
---: | :---

Non-packaged software is installed exclusively into your normal user account,
i.e. this description works OK for non-root users as long as the required packages
are installed before-hand. The default install location is `~/.local/rtorrent/«version»`,
which means you can easily delete any installed software, and also run several versions concurrently.

For shared multi-user setups, this works fine also — compile and install to `/opt/rtorrent`
using `./build.sh install`, then provide access to all users by calling `chmod -R go+rX /opt/rtorrent`.
Perform the steps from *PyroScope Installation* onwards for each user repeatedly,
so they get their own instance.

:computer: | Most of the command blocks further below can be cut & pasted wholesale into a terminal. Note that `bash` _here documents_ (`... <<'EOF'`) **MUST** be pasted at once, up to and including the line having a single `EOF` on it.
---: | :---

:warning: | If you have an existing `/usr/local` installation of rTorrent, it is _very_ prudent to `make uninstall` that before compiling another version. In the same vein, remove any packages of `libtorrent` and `rtorrent` you have on your machine. The build instructions on this page then ensure that it is _no_ problem to have several versions concurrently on your machine.
---: | :---


## Preparatory Steps

### Installing Build Dependencies

First, you need to install a few **required** packages
— **and no, this is not optional in any way**.
These are the only steps that must be performed by the `root` user
(i.e. in a root shell, or by writing `sudo` before the actual command):

```sh
apt-get install tmux curl wget build-essential git locales \
    python-setuptools python-virtualenv python-dev \
    libssl-dev libncurses-dev libncursesw5-dev libcppunit-dev \
    autoconf automake libtool \
    libxml2-dev libxslt1-dev
```

Note that you can always show Debian's current build dependencies for rTorrent using this command:

```sh
echo $(apt-cache showsrc rtorrent libtorrent-dev | \
    grep Build-Depends: | cut -f2 -d: | tr ",)" " \\n" | cut -f1 -d"(")
```


### Optional `root` Setup Steps

If you're security-conscious, you can create a `rtorrent` user and
do all the following setup steps under that new account.
Doing that ensures that there is _no way_, on a properly maintained ∗nix system,
for the build and setup scripts to break either your machine or your normal user account.

```sh
groupadd rtorrent
useradd -g rtorrent -G rtorrent,users -c "rTorrent client" -s /bin/bash --create-home rtorrent
chmod 750 ~rtorrent
su - rtorrent -c "mkdir -p ~/bin"
```

In case you later want to use trackers with `https` announce URLs in combination with
rTorrent 0.8.6 (higher versions have `network.http.ssl_verify_peer.set=0` as an alternative),
this script is useful to easily add the needed certificates to the system:

```sh
cat >/usr/local/sbin/load-domain-certificate <<'EOF'
#! /bin/bash
if test -z "$1"; then
    echo "usage: $0 <domainname_or_url>"
    exit 1
fi
DOMAINNAME=$(sed -re 's%^(https://)?([^/]+)(.*)$%\2%' <<<$1)
set -x
openssl s_client -servername ${DOMAINNAME} -connect ${DOMAINNAME}:443 </dev/null | tee /tmp/${DOMAINNAME}.crt
openssl x509 -inform PEM -in /tmp/${DOMAINNAME}.crt -text -out /usr/share/ca-certificates/${DOMAINNAME}.crt
grep ${DOMAINNAME}.crt /etc/ca-certificates.conf >/dev/null || echo ${DOMAINNAME}.crt >>/etc/ca-certificates.conf
update-ca-certificates
ls -l /etc/ssl/certs | grep ${DOMAINNAME}
EOF
chmod a+x /usr/local/sbin/load-domain-certificate
```


## rTorrent Installation

### `rtorrent-ps` Debian Packages

For a limited set of platforms, there are packages available that contain pre-compiled
binaries (and only those, configuration must be provided on top).
You can download and install such a package from
[Bintray](https://bintray.com/pkg/show/general/pyroscope/rtorrent-ps/rtorrent-ps)
— assuming one is available for your platform.
It installs the [rTorrent-PS](https://github.com/pyroscope/rtorrent-ps)
binary including some libraries into `/opt/rtorrent`, the only thing you need to do
after installation is to symlink the executable into your path:

```sh
ln -s /opt/rtorrent/bin/rtorrent /usr/local/bin
```

Then skip the next section and continue with *PyroScope Installation*.

:bulb: | During rTorrent instance setup, do not forget to change the value of `pyro.extended` to 1 so the extended features are actually activated!
---: | :---


### Build `rtorrent` and Core Dependencies From Source

Get the [build script](https://raw.githubusercontent.com/pyroscope/rtorrent-ps/master/build.sh)
and call it with the `all` parameter as shown below; the script will then download, build, and install
all necessary components, storing temporary files in the current directory.
You can pass the `clean_all` parameter to remove those temporary files later on,
after everything works. Make sure you followed the *Preparatory Steps* in the section further up on this page.

:bangbang: | Be sure to select the version of rTorrent you want to compile, as determined by the settings at the start of the script. If you have no preference otherwise, stick to the default set in the script. Note that such a choice is sticky once you performed the `download` step, until you call `clean_all` again.
---: | :---

All installations go to `~/.local/rtorrent/«version»/`, and disturb neither any host setup
nor another version of rTorrent you've installed the same way.

```sh
# Run this in your NORMAL user account!
mkdir -p ~/src/; cd ~/src/
git clone https://github.com/pyroscope/rtorrent-ps.git
cd rtorrent-ps

# Use this if you have the resources, adapt for the number of cores
# and the amount of free memory you have available.
export MAKE_OPTS="-j4"

# check the VERSION SELECTION at the top of the script, and edit as needed,
# then call BOTH these commands…
nice time ./build.sh all  # build 'rtorrent-vanilla', and then ALSO…
nice time ./build.sh extend  # apply patches and build 'rtorrent-ps' ON TOP of that
```

This is what you'll get:

<table border='0'><tr valign='middle'>
<td><img src='https://raw.githubusercontent.com/pyroscope/rtorrent-ps/master/docs/_static/img/rt-ps-view-thumb.png' /></td>
<td width='50'></td>
<td align='center'><a href='http://youtu.be/Bv-oajBgsSU'><img src='https://raw.githubusercontent.com/pyroscope/rtorrent-ps/master/docs/_static/img/youtube-logo.png' /></a><br />rT-PS Demo Video</td>
</tr></table>

Note that the unpatched version is still available as `rtorrent-vanilla`,
and you can simply switch by changing the symlink in `~/bin`,
or by calling either version with its full path.
See
[RtorrentExtended ](https://github.com/pyroscope/rtorrent-ps/blob/master/docs/RtorrentExtended.md)
for more details on the changes applied.

:bulb: | If you use the configuration as outlined below, do not forget to change the value of `pyro.extended` to 1 in case you want to unlock the additional features of the extended version!
---: | :---


## PyroScope Installation

The installation of `pyrocore` is done from source, see its
[manual](https://pyrocore.readthedocs.org/en/latest/installation.html) for more details.

```sh
# Run this in your NORMAL user account!
mkdir -p ~/bin ~/lib
git clone "https://github.com/pyroscope/pyrocore.git" ~/lib/pyroscope

# Pass "/usr/bin/python2", or whatever else fits, to the script as its
# 1st argument, if the default of "/usr/bin/python" is not a suitable
# version.
~/lib/pyroscope/update-to-head.sh

# Check success
exec $SHELL -l; pyroadmin --version
```


## rTorrent Instance Setup

To be able to use several different instances of rTorrent (e.g. a second one
for experimental configuration changes), this setup doesn't use `~/.rtorrent.rc` at all,
but keeps everything in one place under the `~/rtorrent` directory.
If you change the assignment to `RT_HOME`, you can place it anywhere you like,
or create alternate instances with ease.

### rTorrent Startup Script

First, create the instance directories and a simple
[start script](https://github.com/pyroscope/pyrocore/blob/master/docs/examples/start.sh):

```sh
# Run this in your NORMAL user account!
export RT_HOME="${RT_HOME:-$HOME/rtorrent}"
mkdir -p $RT_HOME; cd $RT_HOME
mkdir -p .session log work done watch/{start,load,hdtv}
cp ~/lib/pyroscope/docs/examples/start.sh ./start
chmod a+x ./start
```

### rTorrent Configuration
Next, a not-so-simple
[rtorrent.rc](https://github.com/pyroscope/pyrocore/blob/master/docs/examples/rtorrent.rc)
is created.
It already provides everything needed to use all features of PyroScope
— you should check at least the ``rtorrent.d/20-host-var-settings.rc`` file
and adapt the values to your environment.

Note that built-in ``pyrocore`` settings are read from a
[provided include file](https://github.com/pyroscope/pyrocore/blob/master/src/pyrocore/data/config/rtorrent-pyro.rc)
that in turn loads snippets from the ``~/.pyroscope/rtorrent.d`` directory.
The same mechanism is used in the main ``rtorrent.rc`` file,
so you can easily add your own customizations in new ``rtorrent.d/*.rc`` files.

```sh
# Run this in your NORMAL user account!
export RT_HOME="${RT_HOME:-$HOME/rtorrent}"
~/lib/pyroscope/src/scripts/make-rtorrent-config.sh
```

:bulb: | In ``rtorrent.rc``, change the value of `pyro.extended` to 1 so the extended `rTorrent-PS` features are actually activated!
---: | :---


## PyroScope CLI Tools Configuration

This adds a minimal configuration, so that the defaults are taken from the installed software,
which makes later updates a lot easier.

```sh
# Run this in your NORMAL user account!
pyroadmin --create-config

cat >~/.pyroscope/config.ini <<EOF
# PyroScope configuration file
#
# For details, see https://pyrocore.readthedocs.org/en/latest/setup.html
#

[GLOBAL]
# Location of your rtorrent configuration
rtorrent_rc = ~/rtorrent/rtorrent.rc

[ANNOUNCE]
# Add alias names for announce URLs to this section; those aliases are used
# at many places, e.g. by the "mktor" tool and to shorten URLs to these aliases
EOF
```

<!-- -->

## First Start and Testing

### tmux Configuration
We spruce up `tmux` a bit using a
[custom configuration](https://github.com/pyroscope/pimp-my-box/blob/master/roles/rtorrent-ps/files/dotfiles/tmux.conf),
before we start it the first time. This makes it more homey for long-time `screen` users:

```sh
# Run this in your NORMAL user account!
cp --no-clobber ~/lib/pyroscope/docs/examples/tmux.conf ~/.tmux.conf
```

### Starting a tmux Session

You're now ready to start your rTorrent, so just do it:

```sh
# Run this in your NORMAL user account!
tmux -2u new -n rT-PS -s rtorrent "~/rtorrent/start; exec bash"
```

The `exec bash` keeps your `tmux` window open if rTorrent exits,
which allows you to actually read any error messages in case rTorrent ends _unexpectedly_.
You can of course add more elaborate start scripts,
like a cron watchdog or init.d scripts, see the rTorrent wiki for examples.

After that, test the XMLRPC connection by using this command:

```sh
# Open a new tmux terminal window by pressing "Ctrl-a" followed by "c", and then...
rtxmlrpc system.time_usec
```

Continue by reading the ['pyrocore' manual](https://pyrocore.readthedocs.org/)
to get acquainted with it.
