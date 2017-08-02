#! /usr/bin/env bash
#
# Build rpath-linked rTorrent including patches and dependencies.
#
# Patches Explained
# -----------------
#
# In the 'extend' action, the release tarballs are unpacked and
# then all relevant patches are applied before compiling.
#
# The lt-ps/ps patches are feature additions, or bug fixes developed
# originally for rTorrent-PS, that change the core code.
#
# The backport patch file names can contain several version numbers,
# namely those versions they apply to.
#
# libtorrent patches:
#   * lt-ps-*_{0.13.N,all}.patch
#   * backport*_0.13.N_*.patch
#   * the 'LT_PATCHES' array (conditional patches)
#   * 'LT_BASE_PATCHES' also apply to vanilla builds
#   * note that all of these patches ALSO influence the vanilla version
#     at runtime (via dynamic linking)
#
# rtorrent patches:
#   * ps-*_{0.9.N,all}.patch
#   * backport*_0.9.N_*.patch
#   * the 'RT_PATCHES' array (conditional patches)
#   * 'RT_BASE_PATCHES' also apply to vanilla builds
#
# Original PyroScope patches (new commands and canvas):
#   * pyroscope.patch
#   * ui_pyroscope.patch
#
# Patches that contain neither a LT/RT version or 'all' are ones
# added dynamically in the build script (e.g. platform-specific ones).
#
# Note that patches are only tested for the current stable release,
# so older versions might get regressions over time (failing patches).

# Get git metadata
if test ! -d .git -a -f docker-env; then
    . docker-env
else
    git_stamp_iso="$(stat -c '%y' * | sed -re 's/(.+) (..):(..).+/\1-\2\3/' | sort -u | tail -n1)"
    git_id="$(git describe --long --tags --dirty="-$git_stamp_iso")"
    git_commits_since_release=$(sed -re 's/.+-([0-9]+)-g[0-9a-fA-F]{7}.*/\1/' <<<"$git_id")
fi
export RT_PS_REVISION="${git_id%%-$git_commits_since_release-g*}"
test "$git_commits_since_release" -eq 0 || \
    RT_PS_REVISION="${RT_PS_REVISION%.*}.$(( ${RT_PS_REVISION##*.} + 1 ))-dev"

# Version selection
export RT_MINOR=6
export LT_VERSION=0.13.$RT_MINOR; export RT_VERSION=0.9.$RT_MINOR;
export GIT_MINOR=$(( $RT_MINOR + 1 ))  # ensure git version has a bumped version number
export VERSION_EXTRAS=" $git_id"

# List of platforms to build DEBs for with "docker_all"
docker_distros=(
    debian:stretch
    ubuntu:xenial
    debian:jessie
    ubuntu:trusty
    debian:wheezy
    ubuntu:precise
)

# Debian-like deps, see below for other distros
BUILD_PKG_DEPS=( libncurses5-dev libncursesw5-dev libssl-dev zlib1g-dev libcppunit-dev locales )
test "$RT_VERSION" != "0.9.2" || BUILD_PKG_DEPS+=( libsigc++-2.0-dev )

# Fitting / tested dependency versions for major platforms
#export CARES_VERSION=1.10.0
#export CURL_VERSION=7.51.0 # 2016-11
#export XMLRPC_REV=2775     # Release 1.43.01 2015-10
export CARES_VERSION=1.13.0 # 2017-06
export CURL_VERSION=7.54.1  # 2017-06
export XMLRPC_REV=2917      # Release 1.48.00 2016-12-27
# WARNING: see rT issue #457 regarding curl configure options

# Extra options handling (set overridable defaults)
: ${PACKAGE_ROOT:=/opt/rtorrent}
: ${INSTALL_ROOT:=$HOME}
: ${INSTALL_DIR:=$INSTALL_ROOT/.local/rtorrent/$RT_VERSION-$RT_PS_REVISION}
: ${BIN_DIR:=$INSTALL_ROOT/bin}
: ${CURL_OPTS:=-sLS}
: ${MAKE_OPTS:=-j4}
: ${CFG_OPTS:=}
: ${CFG_OPTS_LT:=}
: ${CFG_OPTS_RT:=}
export PACKAGE_ROOT INSTALL_ROOT INSTALL_DIR BIN_DIR CURL_OPTS MAKE_OPTS CFG_OPTS CFG_OPTS_LT CFG_OPTS_RT

export SRC_DIR=$(cd $(dirname $0) && pwd)
LT_PATCHES=( )
RT_PATCHES=( )
LT_BASE_PATCHES=( $SRC_DIR/patches/lt-base-cppunit-pkgconfig.patch )
RT_BASE_PATCHES=( $SRC_DIR/patches/rt-base-cppunit-pkgconfig.patch )

# Distro specifics
case $(echo -n "$(lsb_release -sic 2>/dev/null || echo NonLSB)" | tr ' \n' '-') in
    *-precise|*-trusty|*-utopic|*-wheezy)
        #export CARES_VERSION=1.10.0
        #export CURL_VERSION=7.51.0 # 2016-11
        #export XMLRPC_REV=2775 # Release 1.43.01 2015-10
        ;;
    *-jessie)
        #export CARES_VERSION=1.10.0
        #export CURL_VERSION=7.38.0
        #export XMLRPC_REV=2775 # Release 1.43.01 2015-10
        ;;
    *-vivid|*-wily|*-xenial|*-yakkety|*-zesty)
        #export CARES_VERSION=1.11.0 # 2016-02
        #export XMLRPC_REV=2775 # Release 1.43.01 2015-10
        ;;
    *-stretch)
        #export CARES_VERSION=1.13.0 # 2017-06
        #export CURL_VERSION=7.54.1 # 2017-06
        #export XMLRPC_REV=2775 # Release 1.43.01 2015-10
        LT_BASE_PATCHES+=( $SRC_DIR/patches/lt-open-ssl-1.1.patch )
        ;;
    Arch-*) # 0.9.[46] only!
        BUILD_PKG_DEPS=( ncurses openssl cppunit )
        source /etc/makepkg.conf 2>/dev/null
        MAKE_OPTS="${MAKEFLAGS}${MAKE_OPTS:+ }${MAKE_OPTS}"
        LT_BASE_PATCHES+=( $SRC_DIR/patches/lt-open-ssl-1.1.patch )
        ;;
    NonLSB)
        # Place tests for MacOSX etc. here
        BUILD_PKG_DEPS=( )
        echo
        echo "*** Build dependencies are NOT pre-checked on this platform! ***"
        echo
        ;;
esac

# Try this when you get configure errors regarding xmlrpc-c
# ... on a Intel PC type system with certain types of CPUs:
#export CFLAGS="$CFLAGS -march=i586"
export USE_CXXFLAGS=true
if command which dpkg-architecture >/dev/null && dpkg-architecture -earmhf; then
    GCC_TYPE="Raspbian"
elif command which gcc >/dev/null; then
    GCC_TYPE=$(gcc --version | head -n1 | tr -s '()' ' ' | cut -f2 -d' ')
    # Fix libtorrent bug with gcc version >= 6 and non-empty CXXFLAGS env var
    GCC_MAIN_VER=$(gcc --version | head -n1 | cut -d' ' -f4 | cut -d'.' -f1)
    test "${GCC_MAIN_VER:-0}" -ge 6 && export USE_CXXFLAGS=false || :
else
    GCC_TYPE=none
fi
case "$GCC_TYPE" in
    # Raspberry Pi 2 with one of
    #   gcc (Debian 4.6.3-14+rpi1) 4.6.3
    #   gcc (Raspbian 4.8.2-21~rpi3rpi1) 4.8.2
    Raspbian)
        if uname -a | grep 'armv7' >/dev/null; then
            export CFLAGS="$CFLAGS -march=armv7-a -mfpu=neon-vfpv4 -mfloat-abi=hard"
            export CFG_OPTS_LT="$CFG_OPTS_LT --disable-instrumentation"
        fi
        ;;
esac


#
# HERE BE DRAGONS!
#

# Fix people's broken systems
test "$(tr A-Z a-z <<<${LANG/*.})" = "utf-8" || export LANG=en_US.UTF-8
unset LC_ALL
export LC_ALL

# Select build tools (prefer 'g' variants if there)
command which gmake >/dev/null && export MAKE=gmake || export MAKE=make
command which glibtoolize >/dev/null && export LIBTOOLIZE=glibtoolize || export LIBTOOLIZE=libtoolize

# Platform magic
export SED_I="sed -i -e"
case "$(uname -s)" in
    FreeBSD)
        export CFLAGS="-pipe -O2 -pthread${CFLAGS:+ }${CFLAGS}"
        export LDFLAGS="-s -lpthread${LDFLAGS:+ }${LDFLAGS}"
        export SED_I="sed -i '' -e"
        ;;
    Linux)
        export CPPFLAGS="-pthread${CPPFLAGS:+ }${CPPFLAGS}"
        export LIBS="-lpthread${LIBS:+ }${LIBS}"
        ;;
esac

# Keep rTorrent version, once it was built in this directory
test -d rtorrent-0.9.2 && { export LT_VERSION=0.13.2; export RT_VERSION=0.9.2; }
test -d rtorrent-0.9.4 && { export LT_VERSION=0.13.4; export RT_VERSION=0.9.4; }
test -d rtorrent-0.9.5 && { export LT_VERSION=0.13.5; export RT_VERSION=0.9.5; }
test -d rtorrent-0.9.6 && { export LT_VERSION=0.13.6; export RT_VERSION=0.9.6; }
BUILD_GIT=false


set_build_env() {
    export CPPFLAGS="-I $INSTALL_RELEASE_DIR/include${CPPFLAGS:+ }${CPPFLAGS}"
    export CXXFLAGS="$CFLAGS"
    export LDFLAGS="-L$INSTALL_RELEASE_DIR/lib${LDFLAGS:+ }${LDFLAGS}"
    export LDFLAGS="-Wl,-rpath,$INSTALL_RELEASE_DIR/lib ${LDFLAGS}"
    export LIBS="${LIBS}"
    export PKG_CONFIG_PATH="$INSTALL_RELEASE_DIR/lib/pkgconfig${PKG_CONFIG_PATH:+:}${PKG_CONFIG_PATH}"

    local git_tag=''
    if $BUILD_GIT; then
        git_tag=' [GIT]'

        CPPFLAGS="-I $INSTALL_DIR/include${CPPFLAGS:+ }${CPPFLAGS}"
        LDFLAGS="-L$INSTALL_DIR/lib${LDFLAGS:+ }${LDFLAGS}"
        PKG_CONFIG_PATH="$INSTALL_DIR/lib/pkgconfig${PKG_CONFIG_PATH:+:}${PKG_CONFIG_PATH}"
    fi

    echo "!!! Installing rTorrent$VERSION_EXTRAS v$RT_VERSION$git_tag into $INSTALL_DIR !!!"; echo

    printf "export CPPFLAGS=%q\n"           "${CPPFLAGS}"
    printf "export CXXFLAGS=%q # use=%s\n"  "${CXXFLAGS}" "${USE_CXXFLAGS}"
    printf "export LDFLAGS=%q\n"            "${LDFLAGS}"
    printf "export LIBS=%q\n"               "${LIBS}"
    printf "export PKG_CONFIG_PATH=%q\n"    "${PKG_CONFIG_PATH}"
}

SELF_URL=https://github.com/pyroscope/rtorrent-ps.git
XMLRPC_URL="http://svn.code.sf.net/p/xmlrpc-c/code/advanced@$XMLRPC_REV"
TARBALLS=(
"http://c-ares.haxx.se/download/c-ares-$CARES_VERSION.tar.gz"
"http://curl.haxx.se/download/curl-$CURL_VERSION.tar.gz"
)

XMLRPC_SVN=true
case $XMLRPC_REV in
    2917|2775|2626|2366)
        # XMLRPC_REV=2917; tar -cvz --exclude .svn -f xmlrpc-c-advanced-$XMLRPC_REV-src.tgz xmlrpc-c-advanced-$XMLRPC_REV
        TARBALLS+=( "https://bintray.com/artifact/download/pyroscope/rtorrent-ps/xmlrpc-c-advanced-$XMLRPC_REV-src.tgz" )
        XMLRPC_SVN=false
        ;;
esac

# Other sources:
#   http://rtorrent.net/downloads/
#   http://pkgs.fedoraproject.org/repo/pkgs/libtorrent/
#   http://pkgs.fedoraproject.org/repo/pkgs/rtorrent/
TARBALLS+=(
"https://bintray.com/artifact/download/pyroscope/rtorrent-ps/libtorrent-$LT_VERSION.tar.gz"
"https://bintray.com/artifact/download/pyroscope/rtorrent-ps/rtorrent-$RT_VERSION.tar.gz"
)

BUILD_CMD_DEPS=$(cat <<.
curl:curl
subversion:svn
build-essential:$MAKE
build-essential:g++
patch:patch
libtool:$LIBTOOLIZE
automake:aclocal
autoconf:autoconf
automake:automake
pkg-config:pkg-config
.
)

set -e
set +x
SUBDIRS="c-ares-*[0-9] curl-*[0-9] xmlrpc-c-advanced-$XMLRPC_REV libtorrent-*[0-9] rtorrent-*[0-9]"
ESC=$(echo -en \\0033)
BOLD="$ESC[1m"
OFF="$ESC[0m"

echo "${BOLD}Environment for building rTorrent$VERSION_EXTRAS $RT_VERSION/$LT_VERSION$OFF"
printf 'export PACKAGE_ROOT=%q\n'   "$PACKAGE_ROOT"
printf 'export INSTALL_ROOT=%q\n'   "$INSTALL_ROOT"
printf 'export INSTALL_DIR=%q\n'    "$INSTALL_DIR"
printf 'export BIN_DIR=%q\n'        "$BIN_DIR"
printf 'export CURL_OPTS=%q\n'      "$CURL_OPTS"
printf 'export MAKE_OPTS=%q\n'      "$MAKE_OPTS"
printf 'export CFG_OPTS=%q\n'       "$CFG_OPTS"
printf 'export CFG_OPTS_LT=%q\n'    "$CFG_OPTS_LT"
printf 'export CFG_OPTS_RT=%q\n'    "$CFG_OPTS_RT"
echo


#
# HELPERS
#
bold() {
    echo "$BOLD$1$OFF"
}

fail() {
    bold "$@"
    exit 1
}

check_deps() {
    for dep in $BUILD_CMD_DEPS; do
        pkg=${dep%%:*}
        cmd=${dep##*:}
        if which $cmd >/dev/null; then :; else
            echo "You don't have the '$cmd' command available, you likely need to:"
            bold "    sudo apt-get install $pkg"
            exit 1
        fi
    done

    local have_dep=''
    local installer=''

    if which dpkg >/dev/null; then
        have_dep='dpkg -l'
        installer='apt-get install'
    elif which pacman >/dev/null; then
        have_dep='pacman -Q'
        installer='pacman -S'
    fi

    if test -n "$installer"; then
        for dep in "${BUILD_PKG_DEPS[@]}"; do
            if ! $have_dep "$dep" >/dev/null; then
                echo "You don't have the '$dep' package installed, you likely need to:"
                bold "    sudo $installer $dep"
                exit 1
            fi
        done
    fi
}

symlink_binary() {
    binary="$INSTALL_DIR/bin/rtorrent"
    flavour="$1"
    test -z "$flavour" || ln -f "$binary" "$binary$flavour"

    mkdir -p "$BIN_DIR"
    ln -nfs "$binary$flavour" "$BIN_DIR"/rtorrent-$RT_VERSION-$RT_PS_REVISION
    test -e "$BIN_DIR"/rtorrent || ln -nfs rtorrent-$RT_VERSION-$RT_PS_REVISION "$BIN_DIR"/rtorrent
}


#
# RULES
#
prep() {
    # Create directories
    check_deps

    # Properly bump version, even if upstream doesn't
    RT_RELEASE_VERSION="$RT_VERSION"
    INSTALL_RELEASE_DIR="${INSTALL_DIR}"
    if $BUILD_GIT; then
        RT_VERSION="${RT_RELEASE_VERSION/%.$RT_MINOR/.$GIT_MINOR}"
        INSTALL_DIR="${INSTALL_RELEASE_DIR//$RT_RELEASE_VERSION/$RT_VERSION}"

        mkdir -p $INSTALL_DIR/{bin,include,lib,man,share}
    fi

    mkdir -p $INSTALL_RELEASE_DIR/{bin,include,lib,man,share}
    mkdir -p tarballs
}

download() { # Download and unpack sources
    if test ! -d .git -a ! -d patches; then
        git clone $SELF_URL tarballs/self
        rm tarballs/self/build.sh
        mv tarballs/self/* tarballs/self/.git .
    fi

    if $XMLRPC_SVN; then
        test -d xmlrpc-c-advanced-$XMLRPC_REV || ( echo "Getting xmlrpc-c r$XMLRPC_REV" && \
            svn -q checkout "$XMLRPC_URL" xmlrpc-c-advanced-$XMLRPC_REV )
    fi
    for url in "${TARBALLS[@]}"; do
        url_base=${url##*/}
        tarball_dir=${url_base%.tar.gz}
        tarball_dir=${tarball_dir%-src.tgz}
        test -f tarballs/${url_base} || ( echo "Getting $url_base" && command cd tarballs && curl -O $CURL_OPTS $url )
        test -d $tarball_dir || ( echo "Unpacking ${url_base}" && tar xfz tarballs/${url_base} )
        test -d $tarball_dir || fail "Tarball ${url_base} could not be unpacked"
    done

    touch tarballs/DONE
}

automagic() {
    aclocal
    rm -f ltmain.sh scripts/{libtool,lt*}.m4
    $LIBTOOLIZE --automake --force --copy
    aclocal
    autoconf
    automake --add-missing
    ./autogen.sh
}

build_deps() {
    # Build direct dependencies
    test -e $SRC_DIR/tarballs/DONE || fail "You need to '$0 download' first!"

    ( cd c-ares-$CARES_VERSION && ./configure && $MAKE $MAKE_OPTS && $MAKE DESTDIR=$INSTALL_DIR prefix= install )
    $SED_I s:/usr/local:$INSTALL_DIR: $INSTALL_DIR/lib/pkgconfig/*.pc $INSTALL_DIR/lib/*.la
    ( cd curl-$CURL_VERSION && ./configure --enable-ares && $MAKE $MAKE_OPTS && $MAKE DESTDIR=$INSTALL_DIR prefix= install )
    $SED_I s:/usr/local:$INSTALL_DIR: $INSTALL_DIR/lib/pkgconfig/*.pc $INSTALL_DIR/lib/*.la
    ( cd xmlrpc-c-advanced-$XMLRPC_REV \
        && ./configure --prefix=$INSTALL_DIR --with-libwww-ssl \
            --disable-wininet-client --disable-curl-client --disable-libwww-client --disable-abyss-server --disable-cgi-server \
        && $MAKE $MAKE_OPTS && $MAKE install )
    $SED_I s:/usr/local:$INSTALL_DIR: \
        -re 's:^NEED_WL_RPATH=.+$:NEED_WL_RPATH="yes":' \
        $INSTALL_DIR/bin/xmlrpc-c-config
    touch $INSTALL_DIR/lib/DEPS-DONE
}

core_unpack() { # Unpack original LT/RT source
    test -f "$INSTALL_DIR/lib/DEPS-DONE" || fail "You need to '$0 deps' first!"

    tar xfz tarballs/libtorrent-$LT_VERSION.tar.gz
    tar xfz tarballs/rtorrent-$RT_VERSION.tar.gz

    # Patch libtorrent (vanilla)
    pushd libtorrent-$LT_VERSION
    for corepatch in "${LT_BASE_PATCHES[@]}"; do
        test ! -e "$corepatch" || { bold "$(basename $corepatch)"; patch -uNp1 -i "$corepatch"; }
    done
    popd

    # Patch rTorrent (vanilla)
    pushd rtorrent-$RT_VERSION
    for corepatch in "${RT_BASE_PATCHES[@]}"; do
        test ! -e "$corepatch" || { bold "$(basename $corepatch)"; patch -uNp1 -i "$corepatch"; }
    done
    popd
}

build() { # Build and install all components
    test -f "$INSTALL_DIR/lib/DEPS-DONE" || fail "You need to '$0 deps' first!"

    ( set +x ; $USE_CXXFLAGS || unset CXXFLAGS; cd libtorrent-$LT_VERSION && automagic && \
        ./configure $CFG_OPTS $CFG_OPTS_LT && $MAKE clean && $MAKE $MAKE_OPTS && $MAKE prefix=$INSTALL_DIR install )
    $SED_I s:/usr/local:$INSTALL_DIR: $INSTALL_DIR/lib/pkgconfig/*.pc $INSTALL_DIR/lib/*.la
    ( set +x ; $USE_CXXFLAGS || unset CXXFLAGS; cd rtorrent-$RT_VERSION && automagic && \
        ./configure $CFG_OPTS $CFG_OPTS_RT --with-xmlrpc-c=$INSTALL_DIR/bin/xmlrpc-c-config && \
        $MAKE clean && $MAKE $MAKE_OPTS && $MAKE prefix=$INSTALL_DIR install )
}

build_git() { # Build and install libtorrent and rtorrent from git checkouts
    # Start script should contain:
    #
    #   BIN="$HOME/src/rakshasa-rtorrent/src/"; LD_PRELOAD=$HOME/lib/rtorrent/0.9.7-PS-1.0-dev/lib/libtorrent.so.19 \
    #   ${BIN}rtorrent -n -o import=$PWD/rtorrent.rc

    local lt_src="../rakshasa-libtorrent"; test -d "$lt_src" || lt_src="../libtorrent"
    local rt_src="../rakshasa-rtorrent"; test -d "$rt_src" || rt_src="../rtorrent"

    test -f "$INSTALL_DIR/lib/DEPS-DONE" || fail "You need to '$0 deps' first!"

    # TODO: ++ LIBTORRENT_CURRENT=19
    $SED_I 's/^AC_INIT(libtorrent, '${LT_VERSION}'/AC_INIT(libtorrent, '${LT_VERSION%.*}.$GIT_MINOR'/' "$lt_src/configure.ac"
    $SED_I 's/^AC_INIT(rtorrent, '$RT_RELEASE_VERSION'/AC_INIT(rtorrent, '$RT_VERSION'/' "$rt_src/configure.ac"

    echo; echo "*** Entering $lt_src"
    ( set +x ; $USE_CXXFLAGS || unset CXXFLAGS; cd "$lt_src" && automagic && \
        ./configure $CFG_OPTS $CFG_OPTS_LT && $MAKE clean && $MAKE $MAKE_OPTS && $MAKE prefix=$INSTALL_DIR install )
    $SED_I s:/usr/local:$INSTALL_DIR: $INSTALL_DIR/lib/pkgconfig/*.pc $INSTALL_DIR/lib/*.la

    echo; echo "*** Entering $rt_src"
    ( set +x ; $USE_CXXFLAGS || unset CXXFLAGS; cd "$rt_src" && automagic && \
        ./configure $CFG_OPTS $CFG_OPTS_RT --with-xmlrpc-c=$INSTALL_RELEASE_DIR/bin/xmlrpc-c-config && \
        $MAKE clean && $MAKE $MAKE_OPTS && $MAKE prefix=$INSTALL_DIR install )
}

extend() { # Rebuild and install libtorrent and rTorrent with patches applied
    test -f "$INSTALL_DIR/lib/DEPS-DONE" || fail "You need to '$0 deps' first!"
    core_unpack

    # Version handling
    RT_HEX_VERSION=$(printf "0x%02X%02X%02X" ${RT_VERSION//./ })
    $SED_I "s:\\(AC_DEFINE(HAVE_CONFIG_H.*\\):\1  AC_DEFINE(RT_HEX_VERSION, $RT_HEX_VERSION, for CPP if checks):" rtorrent-$RT_VERSION/configure.ac
    grep "AC_DEFINE.*API_VERSION" rtorrent-$RT_VERSION/configure.ac >/dev/null || \
        $SED_I "s:\\(AC_DEFINE(HAVE_CONFIG_H.*\\):\1  AC_DEFINE(API_VERSION, 0, api version):" rtorrent-$RT_VERSION/configure.ac

    # Patch libtorrent
    pushd libtorrent-$LT_VERSION

    for corepatch in $SRC_DIR/patches/lt-ps-*_{${LT_VERSION},all}.patch "${LT_PATCHES[@]}"; do
        test ! -e "$corepatch" || { bold "$(basename $corepatch)"; patch -uNp1 -i "$corepatch"; }
    done

    for backport in $SRC_DIR/patches/backport*_${LT_VERSION}_*.patch; do
        test ! -e "$backport" || { bold "$(basename $backport)"; patch -uNp1 -i "$backport"; }
    done

    popd
    bold "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

    # Patch rTorrent
    pushd rtorrent-$RT_VERSION

    for corepatch in $SRC_DIR/patches/ps-*_{${RT_VERSION},all}.patch "${RT_PATCHES[@]}"; do
        test ! -e "$corepatch" || { bold "$(basename $corepatch)"; patch -uNp1 -i "$corepatch"; }
    done

    for backport in $SRC_DIR/patches/backport*_${RT_VERSION}_*.patch; do
        test ! -e "$backport" || { bold "$(basename $backport)"; patch -uNp1 -i "$backport"; }
    done

    bold "pyroscope.patch"
    patch -uNp1 -i "$SRC_DIR/patches/pyroscope.patch"
    for i in "$SRC_DIR"/patches/*.{cc,h}; do
        ln -nfs $i src
    done

    bold "ui_pyroscope.patch"
    patch -uNp1 -i "${SRC_DIR}/patches/ui_pyroscope.patch"

    $SED_I 's/rTorrent \" VERSION/rTorrent'"$VERSION_EXTRAS"' " VERSION/' src/ui/download_list.cc
    popd
    bold "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

    # Build it (note that libtorrent patches ALSO influence the "vanilla" version)
    build
}

clean() { # Clean up generated files
    for i in $SUBDIRS; do
        ( cd $i && $MAKE clean )
    done
}

clean_all() { # Remove all downloads and created files
    rm tarballs/*{.tar.gz,.tgz} tarballs/DONE >/dev/null 2>&1 || :
    for i in $SUBDIRS; do
        test ! -d $i || rm -rf $i >/dev/null
    done
}

check() { # Print some diagnostic success indicators
    for i in "$BIN_DIR"/rtorrent{,-*}; do
        echo $i "->" $(readlink $i) | sed -e "s:$HOME:~:g"
    done

    # This first selects the rpath dependencies, and then filters out libs found in the install dirs.
    # If anything is left, we have an external dependency that sneaked in.
    echo
    echo -n "Check that static linking worked: "
    libs=$(ldd "$BIN_DIR"/rtorrent-$RT_VERSION-$RT_PS_REVISION | egrep "lib(cares|curl|xmlrpc|torrent)")
    if test "$(echo "$libs" | egrep -v "($INSTALL_DIR|$INSTALL_RELEASE_DIR)" | wc -l)" -eq 0; then
        echo OK; echo
    else
        echo FAIL; echo; echo "Suspicious library paths are:"
        echo "$libs" | egrep -v "($INSTALL_DIR|$INSTALL_RELEASE_DIR)" || :
        echo
    fi
    echo "Dependency library paths:"
    echo "$libs" | sed -e "s:$HOME:~:g"
}

install() { # Install to $PACKAGE_ROOT
    export INSTALL_DIR="$PACKAGE_ROOT"
    test -d "$INSTALL_DIR"/. || mkdir -p "$INSTALL_DIR"/
    rm -rf "$INSTALL_DIR"/* || :
    test "$(echo /opt/rtorrent/*)" = "/opt/rtorrent/*" || fail "Could not clean install dir '$INSTALL_DIR'"
    cat >"$INSTALL_DIR"/version-info.sh <<.
RT_PS_VERSION=$RT_VERSION-$RT_PS_REVISION
RT_PS_REVISION=$RT_PS_REVISION
RT_PS_RT_VERSION=$RT_VERSION
RT_PS_LT_VERSION=$LT_VERSION
RT_PS_CARES_VERSION=$CARES_VERSION
RT_PS_CURL_VERSION=$CURL_VERSION
RT_PS_XMLRPC_REV=$XMLRPC_REV
.
    clean_all; prep; download;
    set_build_env; build_deps; extend
    #check
}

package_prep() # make $PACKAGE_ROOT lean and mean
{
    test -n "$DEBFULLNAME" || fail "You MUST set DEBFULLNAME in your environment"
    test -n "$DEBEMAIL" || fail "You MUST set DEBEMAIL in your environment"

    DIST_DIR=/tmp/rt-ps-dist
    rm -rf "$DIST_DIR" || :
    mkdir -p "$DIST_DIR"

    rm -rf "$PACKAGE_ROOT/"{lib/*.a,lib/*.la,lib/pkgconfig,share/man,man,share,include} || :
    rm -f "$PACKAGE_ROOT/bin/"{curl,*-config} || :
    chmod -R a+rX "$PACKAGE_ROOT/"

    . "$PACKAGE_ROOT"/version-info.sh
}

call_fpm() {
    fpm -s dir -n "${fpm_pkg_name:-rtorrent-ps}" \
        -v "$RT_PS_RT_VERSION" --iteration "$fpm_iteration" \
        -m "\"$DEBFULLNAME\" <$DEBEMAIL>" \
        --license "$fpm_license" --vendor "https://github.com/rakshasa" \
        --description "Patched and extended ncurses BitTorrent client" \
        --url "https://github.com/pyroscope/rtorrent-ps#rtorrent-ps" \
        "$@" -C "$PACKAGE_ROOT/." --prefix "$PACKAGE_ROOT" '.'

    chmod a+rX .
    chmod a+r  *".$fpm_pkg_ext"
}

pkg2deb() { # Package current $PACKAGE_ROOT installation for APT [needs fpm]
    # You need to:
    #   aptitude install ruby ruby-dev
    #   gem install fpm
    #   which fpm || ln -s $(ls -1 /var/lib/gems/*/bin/fpm | tail -1) /usr/local/bin

    package_prep

    fpm_pkg_ext="deb"
    fpm_iteration="${VERSION_EXTRAS# }~"$(lsb_release -cs)
    fpm_license="GPL v2"
    deps=$(ldd "$PACKAGE_ROOT"/bin/rtorrent | cut -f2 -d'>' | cut -f2 -d' ' | egrep '^/lib/|^/usr/lib/' \
        | sed -r -e 's:^/lib.+:&\n/usr&:' | xargs -n1 dpkg 2>/dev/null -S \
        | cut -f1 -d: | sort -u | xargs -n1 echo '-d')

    ( cd "$DIST_DIR" && call_fpm -t deb --category "net" $deps )

    dpkg-deb -c       "$DIST_DIR"/*".$fpm_pkg_ext"
    echo "~~~" $(find "$DIST_DIR"/*".$fpm_pkg_ext")
    dpkg-deb -I       "$DIST_DIR"/*".$fpm_pkg_ext"
}

pkg2pacman() { # Package current $PACKAGE_ROOT installation for PACMAN [needs fpm]
    # You need to install fpm from the AUR
    package_prep

    fpm_pkg_ext="tar.xz"
    fpm_iteration="${RT_PS_REVISION//-/.}"
    fpm_license="GPL2"

    ( cd "$DIST_DIR" && call_fpm -t pacman )

    pacman -Qp --info "$DIST_DIR"/*".$fpm_pkg_ext"
    echo "~~~" $(find "$DIST_DIR"/*".$fpm_pkg_ext")
    pacman -Qp --list "$DIST_DIR"/*".$fpm_pkg_ext"
}

build_everything() {
    # Go through all build steps
    set_build_env
    ${NODEPS:-false} || build_deps

    core_unpack
    build
    symlink_binary -vanilla
    check

    rt_binary="$SRC_DIR/rtorrent-$RT_RELEASE_VERSION/src/rtorrent"
    test -e "$rt_binary" || fail "Something went wrong! ($rt_binary not found)"

    extend
    symlink_binary -extended
    check
}

docker_deb() { # Build Debian packages via Docker
    local distro_code DISTRO_NAME DISTRO_CODENAME DOCKER_TAG
    #DISTRO_NAME=debian ; DISTRO_CODENAME=stretch
    #DISTRO_NAME=ubuntu ; DISTRO_CODENAME=xenial
    distro_code="${1:-debian:stretch}"; test "$#" -eq 0 || shift
    DISTRO_NAME=${distro_code%%:*}
    DISTRO_CODENAME=${distro_code#*:}
    DOCKER_TAG=rtps-deb-$DISTRO_CODENAME

    mkdir -p tmp-docker
    set \
        | egrep '^(git_[_a-z]+|[_A-Z]+_OPTS|[_A-Z]+_ROOT|CFG_[_A-Z]+)' \
        | sed -re 's/^/export /' >tmp-docker/docker-env
    ln -f Dockerfile.Debian tmp-docker/Dockerfile

    docker build -t $DOCKER_TAG -f tmp-docker/Dockerfile \
                 --build-arg DISTRO=$DISTRO_NAME \
                 --build-arg CODENAME=$DISTRO_CODENAME \
                 "$@" .
    docker run --rm -u $(id -u):$(id -g) --userns host -v "$PWD:/pwd" $DOCKER_TAG \
               bash -c "cp /tmp/rt-ps-dist/rtorrent-ps_*.deb /pwd"
}

#
# MAIN
#
cd "$SRC_DIR"
while test -n "$1"; do
    action="$1"; shift
    case "$action" in
        all)        prep; download; build_everything ;;
        clean)      clean ;;
        clean_all)  clean_all ;;
        download)   prep; download ;;
        env)        prep; set +x; set_build_env echo '"' ;;
        build)      prep; build_everything ;;
        deps)       prep; set_build_env; build_deps ;;
        git|build_git)
                    BUILD_GIT=true
                    prep
                    set_build_env
                    build_git
                    symlink_binary -git
                    check
                    ;;
        vanilla)    prep
                    set_build_env
                    core_unpack
                    build
                    symlink_binary -vanilla
                    check
                    ;;
        extend)     prep
                    set_build_env
                    extend
                    symlink_binary -extended
                    check
                    ;;
        check)      check
                    ;;
        install)    install
                    ;;
        pkg2deb)    pkg2deb
                    ;;
        pkg2pacman) pkg2pacman
                    ;;
        docker_deb) docker_deb "$@"
                    break
                    ;;
        docker_all) for distro in "${docker_distros[@]}"; do
                        docker_deb "$distro" "$@" \
                            || echo -e "\n\n*** WARNING: $distro does not build ***\n\n"
                    done
                    ls -lrt *.deb
                    break
                    ;;
        *)
            echo >&2 "${BOLD}Usage: $0 (all | clean | clean_all | download | build | check | extend)$OFF"
            echo >&2 "Build rTorrent$VERSION_EXTRAS $RT_VERSION/$LT_VERSION into $(sed -e s:$HOME/:~/: <<<$INSTALL_DIR)"
            echo >&2
            echo >&2 "Custom environment variables:"
            echo >&2 "    CURL_OPTS=\"${CURL_OPTS}\" (e.g. --insecure)"
            echo >&2 "    MAKE_OPTS=\"${MAKE_OPTS}\""
            echo >&2 "    CFG_OPTS=\"${CFG_OPTS}\" (e.g. --enable-debug --enable-extra-debug)"
            echo >&2 "    CFG_OPTS_LT=\"${CFG_OPTS_LT}\" (e.g. --disable-instrumentation for MIPS, PowerPC, ARM)"
            # MIPS | PowerPC | ARM users, read https://github.com/rakshasa/rtorrent/issues/156
            echo >&2 "    CFG_OPTS_RT=\"${CFG_OPTS_RT}\""
            echo >&2
            echo >&2 "Build actions:"
            grep "() { #" $0 | grep -v grep | sort | sed -e "s:^:  :" -e "s:() { #:  @:" | while read i; do
                echo "   " $(eval "echo $i") | tr @ \\t
            done
            exit 1
            ;;
    esac
done
