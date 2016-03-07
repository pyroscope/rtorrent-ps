

# Introduction #

The following shows installation instructions for a working rTorrent instance in combination with PyroScope **from scratch**, on Debian Server 6.0 (Squeeze). While the package names and the use of `aptitude` are somewhat dependant on (that version of) Debian, the "_Preparatory steps_" commands which are executed under `root` are similar for other distributions, and the compilation instructions should work as-is on practically any Linux and (F)BSD. These instructions are explicitly known to work on Ubuntu Lucid and Precise.

> ✪ **If you don't understand a word of what follows, hit [The Debian Administrator's Handbook](http://static.debian-handbook.info/browse/stable/short-remedial-course.html) so then you do.**

Non-packaged software is installed exclusively into your normal user account, i.e. this description works OK for non-root users as long as the required packages are installed before-hand. The default install location is `~/lib/rtorrent-«version»`, which means you can easily delete any installed software, and also run several versions concurrently.

For shared multi-user setups, this works fine also — just add a "rtorrent" user or similar, compile and install under it, then provide access to the other users (e.g. by adding them to the "rtorrent" group). Perform the steps from "rTorrent configuration" onwards for each user repeatedly, so they get their own instance. Call "`ln -nfs ~rtorrent/bin/rtorrent ~/bin`" to link to the central software installation (different users can have different versions and flavours active, just by changing the link target).

Most of the command blocks further below can be cut & pasted wholesale into a terminal. Note that `bash` _here documents_ (`... <<'EOF'`) **MUST** be pasted at once, up to and including the line having a single `EOF` on it.

> ⚠ **If you have an existing `/usr/local` installation of rTorrent, it is _very_ prudent to `make uninstall` that before compiling another version. In the same vein, remove any packages of `libtorrent` and `rtorrent` you have on your machine. The build instructions on this page then ensure that it is _no_ problem to have several versions concurrently on your machine.**


# Preparatory steps #
## Installing build dependencies ##
First, you need to install a few **required** packages — **and no, this is not optional in any way**.
These are the only steps that must be performed by the `root` user (i.e. in a root shell, or by writing `sudo` before the actual command):
```
aptitude install tmux wget build-essential subversion git \
    python-setuptools python-virtualenv python-dev \
    libsigc++-2.0-dev libssl-dev \
    libncurses-dev libncursesw5-dev locales libcppunit-dev \
    autoconf automake libtool \
    libxml2-dev libxslt1-dev
```

Note that you can always show Debian's current build dependencies for rTorrent using the command
```
echo $(apt-cache showsrc rtorrent libtorrent-dev | grep Build-Depends: | cut -f2 -d: | tr ",)" " \\n" | cut -f1 -d"(")
```


## Optional `root` setup steps ##
If you're security-conscious, you can create a `rtorrent` user and do all the following setup steps under that new account. Doing that ensures that there is _no way_, on a properly maintained ∗nix system, for the build and setup scripts to break either your machine or your normal user account.
```
groupadd rtorrent
useradd -g rtorrent -G rtorrent,users -c "rTorrent client" -s /bin/bash --create-home rtorrent
chmod 750 ~rtorrent
su - rtorrent -c "mkdir -p ~/bin"
```

In case you later want to use trackers with `https` announce URLs in combination with rTorrent 0.8.6 (higher versions have `network.http.ssl_verify_peer.set=0`), this script is useful to easily add the needed certificates to the system:
```
cat >/usr/local/sbin/load-domain-certificate <<'EOF'
#! /bin/bash
if test -z "$1"; then
    echo "usage: $0 <domainname_or_url>"
    exit 1
fi
DOMAINNAME=$(sed -re 's%^(https://)?([^/]+)(.*)$%\2%' <<<$1)
set -x
openssl s_client -connect ${DOMAINNAME}:443 </dev/null | tee /tmp/${DOMAINNAME}.crt
openssl x509 -inform PEM -in /tmp/${DOMAINNAME}.crt -text -out /usr/share/ca-certificates/${DOMAINNAME}.crt
grep ${DOMAINNAME}.crt /etc/ca-certificates.conf >/dev/null || echo ${DOMAINNAME}.crt >>/etc/ca-certificates.conf
update-ca-certificates
ls -l /etc/ssl/certs | grep ${DOMAINNAME}
EOF
chmod a+x /usr/local/sbin/load-domain-certificate
```


# rTorrent installation #

## `rtorrent-ps` Debian packages ##

For a limited set of platforms, there are packages available that contain pre-compiled binaries (and only those). You can download and install such a package from [Bintray](https://bintray.com/pkg/show/general/pyroscope/rtorrent-ps/rtorrent-ps) — assuming one is available for your platform. It installs the [rTorrent-PS](RtorrentExtended.md) binary including some libraries into `/opt/rtorrent`, the only thing you need to do after installation is to symlink the executable into your path:

```
ln -s /opt/rtorrent/bin/rtorrent /usr/local/bin
```

Then skip the next section and continue with “PyroScope installation”.

> ✪ _During rTorrent instance setup, do not forget to change the value of `pyro.extended` to 1 so the extended features are actually activated!_


## Build `rtorrent` and core dependencies from source ##

Get the [build script](https://raw.githubusercontent.com/pyroscope/rtorrent-ps/master/build.sh) as shown below and call it with the `all` parameter; the script will then download, build, and install all necessary components, storing temporary files in the current directory. You can pass the `clean_all` parameter to remove those temporary files later on, after everything works. Make sure you followed the "Preparatory steps" in the section further up on this page.

All installations go to `~/lib/rtorrent-«version»/`, and disturb neither any host setup nor another version of rTorrent you've installed the same way.

**⚠ Be sure to select the version of rTorrent you want to compile, as determined by the settings at the start of the script. If you have no preference otherwise, stick to the stable 0.9.2 release, which is the default. Note that such a choice is sticky once you performed the `download` step, until you call `clean_all` again.**

```
# Run this in your NORMAL user account!
mkdir -p ~/src/; cd ~/src/
git clone https://github.com/pyroscope/rtorrent-ps.git
cd rtorrent-ps

# check the VERSION SELECTION at the top of the script, and edit as needed, then...
./build.sh all
```

If you want an extended version with some stability fixes and extension patches applied, call this command **in addition**:
```
./build.sh extend # "in addition" means AFTER the commands further above
```

<table border='0'><tr valign='middle'>
<td><img src='http://i.imgur.com/xCd8z.png' /></td>
<td width='50'></td>
<td align='center'><a href='http://youtu.be/Bv-oajBgsSU'><img src='http://i.imgur.com/5FPx5.png' /></a><br />rT-PS Demo Video</td>
</tr></table>

Note that the unpatched version is still available as `rtorrent-vanilla`, and you can simply switch by changing the symlink in `~/bin`, or by calling either version with its full path. See RtorrentExtended for more details on the changes applied.

> ✪ _If you use the configuration as outlined below, do not forget to change the value of `pyro.extended` to 1 in case you built the extended version, to unlock the additional features!_


# PyroScope installation #
The installation of `pyrocore` is done from source, see InstallFromSource for more details.
```
# Run this in your NORMAL user account!
mkdir -p ~/bin ~/lib
svn checkout http://pyroscope.googlecode.com/svn/trunk/ ~/lib/pyroscope
~/lib/pyroscope/update-to-head.sh
```

Make sure `~/bin` is on your `PATH`, and if not, close and then reopen your shell. Check again, and if it's still not in there, [fix your broken `.bashrc`](http://linux.about.com/od/linux101/l/blnewbie3_1_4.htm).


# rTorrent instance setup #
To be able to use several different instances of rTorrent (e.g. a second one for experimental configuration changes), this setup doesn't use `~/.rtorrent.rc` at all, but keeps everything in one place under the `~/rtorrent` directory. If you change the assignment to `RT_HOME`, you can place it anywhere you like, or create alternate instances with ease.

## rTorrent startup script ##

First, create the instance directories and a simple [start script](http://pyroscope.googlecode.com/svn/trunk/pyrocore/docs/examples/start.sh):
```
# Run this in your NORMAL user account!
export RT_HOME="${RT_HOME:-$HOME/rtorrent}"
mkdir -p $RT_HOME/{.session,work,done,log,watch/start,watch/load}
cd $RT_HOME
cp ~/lib/pyroscope/pyrocore/docs/examples/start.sh ./start
chmod a+x ./start
```

## rTorrent configuration ##

Next, a not-so-simple [rtorrent.rc](http://pyroscope.googlecode.com/svn/trunk/pyrocore/docs/examples/rtorrent.rc) is created, it already contains everything needed to use all features of PyroScope — you should check at least the first section and adapt the values to your environment. Note that most of the settings specific to PyroScope are read from a [provided include file](http://pyroscope.googlecode.com/svn/trunk/pyrocore/src/pyrocore/data/config/rtorrent-0.8.6.rc).

```
# Run this in your NORMAL user account!
export RT_HOME="${RT_HOME:-$HOME/rtorrent}"
sed -e "s:RT_HOME:$RT_HOME:" <~/lib/pyroscope/pyrocore/docs/examples/rtorrent.rc >$RT_HOME/rtorrent.rc
```

![http://i.imgur.com/TnR4Rts.gif](http://i.imgur.com/TnR4Rts.gif)  
<font color='#f22' face='Impact,Verdana,sans' size='4'>Also, if you compiled rTorrent version <b>0.9.2</b> (which is the default) or <b>0.8.9</b>, you <b>MUST <a href='RtXmlRpcMigration.md'>run the migration script</a></b> on the configuration now!</font>
```
# Run this in your NORMAL user account!
export RT_HOME="${RT_HOME:-$HOME/rtorrent}"
bash ~/lib/pyroscope/pyrocore/src/scripts/migrate_rtorrent_rc.sh $RT_HOME/rtorrent.rc
```
That converts it from the old 0.8.6 syntax to the new one.

> ✪ Change the value of `pyro.extended` to 1 so the extended `rTorrent-PS` features are actually activated, in case you plan to use that!


# PyroScope configuration #
This adds a minimal configuration, so that the defaults are taken from the installed software, which makes later updates a lot easier.
```
# Run this in your NORMAL user account!
pyroadmin --create-config

cat >~/.pyroscope/config.ini <<EOF
# PyroScope configuration file
#
# For details, see http://code.google.com/p/pyroscope/wiki/UserConfiguration
#

[GLOBAL]
# Location of your rtorrent configuration
rtorrent_rc = ~/rtorrent/rtorrent.rc

[ANNOUNCE]
# Add alias names for announce URLs to this section; those aliases are used
# at many places, e.g. by the "mktor" tool and to shorten URLs to these aliases
EOF
```


# First start and testing #

## tmux Configuration ##

We spruce up `tmux` a bit using a [custom configuration](http://pyroscope.googlecode.com/svn/trunk/pyrocore/docs/examples/tmux.conf), before we start it the first time. This makes it more homey for long-time `screen` users:
```
# Run this in your NORMAL user account!
cp --no-clobber ~/lib/pyroscope/pyrocore/docs/examples/tmux.conf ~/.tmux.conf
```

## Starting a tmux Session ##

You're now ready to start your rTorrent, so just do it:
```
# Run this in your NORMAL user account!
tmux -2u new -n rT-PS -s rtorrent "~/rtorrent/start; exec bash"
```
The `exec bash` keeps your `tmux` window open if rTorrent exits, which allows you to actually read any error messages in case rTorrent ends _unexpectedly_.

You can of course add more elaborate start scripts, like a cron watchdog or init.d scripts, see the rTorrent wiki for examples.
After that, test the XMLRPC connection by using this command:
```
# Open a new tmux terminal window by pressing "Ctrl-a" and then "c"
rtxmlrpc system.time_usec
```

Continue by reading the UserConfiguration and the RtControlExamples pages.