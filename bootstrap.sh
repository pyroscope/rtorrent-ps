#! /usr/bin/env bash
#
# Set up project (Python3 tooling)
#
set -e

VENV_NAME="rtorrent-ps"

SCRIPTNAME="$0"
test "$SCRIPTNAME" != "-bash" -a "$SCRIPTNAME" != "-/bin/bash" || SCRIPTNAME="${BASH_SOURCE[0]}"

test -z "$1" || PYTHON="$1"

deactivate 2>/dev/null || true
test -n "$VENV_NAME" || VENV_NAME="$(basename $(builtin cd $(dirname "$SCRIPTNAME") && pwd))"
test -x ".venv/bin/python" || ${PYTHON:-python3} -m venv --prompt "$VENV_NAME" ".venv"
. ".venv/bin/activate"

for basepkg in pip setuptools wheel; do
    .venv/bin/pip install -U $basepkg
done

.venv/bin/pip install -r docs/requirements.txt
