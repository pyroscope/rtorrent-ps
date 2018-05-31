#! /usr/bin/env bash
#
# Set up project (Python3 tooling)
#
set -e

VENV_NAME="rtorrent-ps"

SCRIPTNAME="$0"
test "$SCRIPTNAME" != "-bash" -a "$SCRIPTNAME" != "-/bin/bash" || SCRIPTNAME="${BASH_SOURCE[0]}"

test ! -x "$1" || VIRTUALENV="$1"

deactivate 2>/dev/null || true
test -n "$VENV_NAME" || VENV_NAME="$(basename $(builtin cd $(dirname "$SCRIPTNAME") && pwd))"
test -x ".pyvenv/$VENV_NAME/bin/python" || ${PYVENV:-/usr/bin/pyvenv} ".pyvenv/$VENV_NAME"
. ".pyvenv/$VENV_NAME/bin/activate"

for basepkg in pip setuptools wheel; do
    pip install -U $basepkg
done

pip install -r docs/requirements.txt
