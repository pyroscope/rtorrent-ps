# Install pyrocore
mkdir -p ~/bin ~/.local
git clone "https://github.com/pyroscope/pyrocore.git" ~/.local/pyroscope
$_/update-to-head.sh
~/bin/pyroadmin --version

# Create rtorrent instance
export RT_HOME="${RT_HOME:-$HOME/rtorrent}"
mkdir -p $RT_HOME; cd $RT_HOME
mkdir -p .session log work done watch/{start,load,hdtv}
cp ~/.local/pyroscope/docs/examples/start.sh ./start
chmod a+x ./start
~/.local/pyroscope/src/scripts/make-rtorrent-config.sh
sed -i -re 's/(method.*pyro.extended.*)0/\11/' ~/rtorrent/rtorrent.rc
echo >>~/rtorrent/rtorrent.d/.rcignore "disable-control-q.rc"

# Create pyrocore config
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

# Start tmux session
cp --no-clobber ~/.local/pyroscope/docs/examples/tmux.conf ~/.tmux.conf
tmux -2u new -n rT-PS -s rtorrent "~/rtorrent/start; exec bash"
