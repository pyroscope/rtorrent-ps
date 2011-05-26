#! /bin/bash
#
# Build rTorrent including patches
#

export RT_MINOR=6
export LT_VERSION=0.12.$RT_MINOR; export RT_VERSION=0.8.$RT_MINOR;

export CARES_VERSION=1.7.3
export CURL_VERSION=7.21.1
export XMLRPC_REV=2122

# AUR Patches
_magnet_uri=0
_ipv6=0
_ip_filter=0
_friend=0
_bad_peer_handling=0
# 1 = canvas color patch / 2 = karabja mod patch
_interface=2
_show_idle_times=0
_trackerinfo=1
# 1 = tjwoosta vi keybindings / 2 = akston vi keybindings
_keybindings=0


#
# HERE BE DRAGONS!
#

# Keep rTorrent version, once it was built in this directory
test -d rtorrent-0.8.6 && { export LT_VERSION=0.12.6; export RT_VERSION=0.8.6; }
test -d rtorrent-0.8.7 && { export LT_VERSION=0.12.7; export RT_VERSION=0.8.7; }
test -d rtorrent-0.8.8 && { export LT_VERSION=0.12.8; export RT_VERSION=0.8.8; }

export INST_DIR="$HOME/lib/rtorrent-$RT_VERSION"
export CFLAGS="-I $INST_DIR/include"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-L$INST_DIR/lib"
export PKG_CONFIG_PATH="$INST_DIR/lib/pkgconfig"

XMLRPC_URL="https://xmlrpc-c.svn.sourceforge.net/svnroot/xmlrpc-c/advanced@$XMLRPC_REV"
TARBALLS=$(cat <<.
http://c-ares.haxx.se/c-ares-$CARES_VERSION.tar.gz
http://curl.haxx.se/download/curl-$CURL_VERSION.tar.gz
http://libtorrent.rakshasa.no/downloads/libtorrent-$LT_VERSION.tar.gz
http://libtorrent.rakshasa.no/downloads/rtorrent-$RT_VERSION.tar.gz
http://aur.archlinux.org/packages/rtorrent-extended/rtorrent-extended.tar.gz
.
)

set -e
set +x
export SRC_DIR=$(cd $(dirname $0) && pwd)
SUBDIRS="c-ares-*[0-9] curl-*[0-9] xmlrpc-c-advanced libtorrent-*[0-9] rtorrent-*[0-9]"
ESC=$(echo -en \\0033)
BOLD="$ESC[1m"
OFF="$ESC[0m"


#
# HELPERS
#
bold() {
    echo "$BOLD$1$OFF"
}

aur_patches() {
    #ex
    if [[ "${_magnet_uri}" = "1" || "${_ipv6}" = "1" ]]; then
        bold "ex_magnet_uri.patch"
        patch -uNp1 -i "${srcdir}/ex_magnet_uri.patch"
    fi
    if [[ "${_ipv6}" = "1" ]]; then
        bold "ex_ip6.patch"
        patch -uNp1 -i "${srcdir}/ex_ipv6.patch"
        _cfg_opts="--enable-ipv6"
    fi
    if [[ "${_ip_filter}" = "1" || "${_friend}" = "1" ]]; then
        bold "ex_ip_filter.patch"
        patch -uNp1 -i "${srcdir}/ex_ip_filter.patch"
    fi
    if [[ "${_friend}" = "1" ]]; then
        bold "ex_friend.patch"
        patch -uNp1 -i "${srcdir}/ex_friend.patch"
    fi
    if [[ "${_bad_peer_handling}" = "1" ]]; then
        bold "ex_bad_peer_handling.patch"
        patch -uNp1 -i "${srcdir}/ex_bad_peer_handling.patch"
    fi

    #ui
    if [[ "${_interface}" = "1" ]]; then
        bold "ui_canvas_color.patch"
        patch -uNp1 -i "${srcdir}/ui_canvas_color.patch"
    elif [[ "${_interface}" = "2" ]]; then
        bold "ui_karabaja_mod.patch"
        patch -uNp1 -i "${srcdir}/ui_karabaja_mod.patch"
    fi
    if [[ "${_show_idle_times}" = "1" ]]; then
        bold "ui_show_idle_times.patch"
        patch -uNp1 -i "${srcdir}/ui_show_idle_times.patch"
    fi
    if [[ "${_trackerinfo}" = "1" ]]; then
        bold "ui_trackerinfo.patch"
        patch -uNp1 -i "${srcdir}/ui_trackerinfo.patch"
    fi

    #kb
    if [[ "${_keybindings}" = "1" ]]; then
        bold "kb_vi_tjwoosta.patch"
        patch -uNp1 -i "${srcdir}/kb_vi_tjwoosta.patch"
    elif [[ "${_keybindings}" = "2" ]]; then
        bold "kb_vi_akston.patch"
        patch -uNp1 -i "${srcdir}/kb_vi_akston.patch"
    fi
}

symlink_binary() {
    binary="$INST_DIR/bin/rtorrent"
    flavour="$1"
    test -z "$flavour" || ln -f "$binary" "$binary$flavour"

    mkdir -p ~/bin
    ln -nfs "$binary$flavour" ~/bin/rtorrent-$RT_VERSION
    test -e ~/bin/rtorrent || ln -s rtorrent-$RT_VERSION ~/bin/rtorrent
}


#
# RULES
#
prep() { # Create directories
    mkdir -p $INST_DIR/{bin,include,lib,man,share}
    mkdir -p tarballs
}

download() { # Download & unpack sources
    test -d xmlrpc-c-advanced-$XMLRPC_REV || ( echo "Getting xmlrpc-c r$XMLRPC_REV" && \
        svn -q checkout "$XMLRPC_URL" xmlrpc-c-advanced-$XMLRPC_REV )
    for url in $TARBALLS; do
        url_base=${url##*/}
        test -f tarballs/${url_base} || ( echo "Getting $url_base" && cd tarballs && wget -q $url )
        test -d ${url_base%.tar.gz} || ( echo "Unpacking ${url_base}" && tar xfz tarballs/${url_base} )
    done
}

build() { # Build and install all components
    ( cd c-ares-$CARES_VERSION && ./configure && make && make prefix=$INST_DIR install )
    sed -ie s:/usr/local:$INST_DIR: $INST_DIR/lib/pkgconfig/*.pc $INST_DIR/lib/*.la
    ( cd curl-$CURL_VERSION && ./configure --enable-ares && make && make prefix=$INST_DIR install )
    sed -ie s:/usr/local:$INST_DIR: $INST_DIR/lib/pkgconfig/*.pc $INST_DIR/lib/*.la 
    ( cd xmlrpc-c-advanced-$XMLRPC_REV && ./configure --with-libwww-ssl && make && make install PREFIX=$INST_DIR )
    sed -ie s:/usr/local:$INST_DIR: $INST_DIR/bin/xmlrpc-c-config
    ( cd libtorrent-$LT_VERSION && ./configure && make && make prefix=$INST_DIR install )
    sed -ie s:/usr/local:$INST_DIR: $INST_DIR/lib/pkgconfig/*.pc $INST_DIR/lib/*.la 
    ( cd rtorrent-$RT_VERSION && ./configure --with-xmlrpc-c=$INST_DIR/bin/xmlrpc-c-config && make && make prefix=$INST_DIR install )

    symlink_binary -vanilla
}

extend() { # Rebuild and install rTorrent with patches applied
    # Based on https://aur.archlinux.org/packages/rtorrent-extended/
    
    # Unpack original source
    tar xfz tarballs/rtorrent-$RT_VERSION.tar.gz

    # Version guards
    [[ $RT_VERSION == 0.8.6 ]] || { _interface=0; bold "Interface patches disabled"; }

    # Patch it
    pushd rtorrent-$RT_VERSION
    srcdir=$SRC_DIR/rtorrent-extended
    aur_patches

    #echo "fix_ncurses_5.8.patch"
    #patch -uNp1 -i "${srcdir}/fix_ncurses_5.8.patch"

    bold "pyroscope.patch"
    patch -uNp1 -i "$SRC_DIR/patches/pyroscope.patch"
    for i in "$SRC_DIR"/patches/*.cc; do
        ln -nfs $i src
    done

    # http://libtorrent.rakshasa.no/ticket/2411
    # svn diff -r1184:1186 svn://rakshasa.no/libtorrent/trunk/  >patches/fix_2411_threading.patch
    # svn diff -r1187:1188 svn://rakshasa.no/libtorrent/trunk/ >>patches/fix_2411_threading.patch
    [[ RT_VERSION != 0.8.7 ]] || patch -uNp1 -i "$SRC_DIR/patches/fix_2411_threading.patch"

    sed -i 's/rTorrent \" VERSION/rTorrent-PS " VERSION/' src/ui/download_list.cc
    popd
    bold "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

    # Build it
    ( set +x ; cd rtorrent-$RT_VERSION && rm -f ltmain.sh scripts/{libtool,lt*}.m4 && \
        libtoolize --automake --force --copy && aclocal && autoconf && automake && ./autogen.sh && \
        ./configure --with-xmlrpc-c=$INST_DIR/bin/xmlrpc-c-config >/dev/null && \
        make clean && \
        make && \
        make prefix=$INST_DIR install \
    )
    symlink_binary -extended
}

clean() { # Clean up generated files
    for i in $SUBDIRS; do
        ( cd $i && make clean )
    done
}

clean_all() { # Remove all downloads and created files
    rm *.tar.gz >/dev/null || :
    for i in $SUBDIRS; do
        test ! -d $i || rm -rf $i >/dev/null
    done
}

check() { # Print some diagnostic success indicators
    for i in ~/bin/rtorrent{,-$RT_VERSION}; do
        echo $i "->" $(readlink $i) | sed -e "s:$HOME:~:g"
    done
    echo
    echo -n "Check that static linking worked: "
    libs=$(ldd ~/bin/rtorrent-$RT_VERSION | egrep "lib(cares|curl|xmlrpc|torrent)")
    test -n $(echo "$libs" | grep -v "$INST_DIR") && echo OK || echo FAIL
    echo "$libs" | sed -e "s:$HOME:~:g"
}


#
# MAIN
#
cd "$SRC_DIR"
case "$1" in
    all)        prep; download; build; check ;;
    clean)      clean ;;
    clean_all)  clean_all ;; 
    download)   prep; download ;;
    build)      prep; build; check ;;
    extend)     extend; check ;;
    check)      check ;;
    *)
        echo >&2 "Usage: $0 (all | clean | clean_all | download | build | check | extend )"
        echo >&2 "Build rTorrent $RT_VERSION/$LT_VERSION into $(sed -e s:$HOME/:~/: <<<$INST_DIR)"
        echo >&2 
        grep "() { #" $0 | grep -v grep | sort | sed -e "s:^:  :" -e "s:() { #:  @:" | tr @ \\t
        exit 1
        ;;
esac

