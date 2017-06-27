#
# Run an EMPHEMERAL rTorrent-PS instance in a Stretch container
#
#   git clone "https://github.com/pyroscope/rtorrent-ps.git" ~/src/rtorrent-ps
#   ~/src/rtorrent-ps/docker/launch-stretch.sh
#

case "$1" in
run)
    # Install basics
    apt update -qq
    apt-get install -y apt-transport-https lsb-release locales less \
        git tmux curl wget \
        python-setuptools python-virtualenv python-dev
    echo "en_US.UTF-8 UTF-8" >/etc/locale.gen
    locale-gen

    # Install rT-PS
    echo >/etc/apt/sources.list.d/rtps.list \
         "deb [trusted=yes] https://dl.bintray.com/pyroscope/rtorrent-ps /"
    apt update -qq
    apt install -y rtorrent-ps=0.9.6-PS-1.1-dev~stretch
    ln -s /opt/rtorrent/bin/rtorrent /usr/local/bin
    rtorrent -h | head -n1

    # Create rtorrent user, and become rtorrent
    groupadd rtorrent
    useradd -g rtorrent -G rtorrent,users -c "rTorrent client" -s /bin/bash --create-home rtorrent
    chmod 750 ~rtorrent
    su - rtorrent -c "mkdir -p ~/bin"
    su - rtorrent -c "bash /srv/launch-rtorrent.sh"
    ;;
*)
    docker run -v $(command cd i$(dirname "$0") && pwd):/srv -it \
               --name rtps debian:stretch bash /srv/launch-stretch.sh run
    ;;
esac
