#! /usr/bin/env python
# Copyright (C) 2006 by Johannes Zellner, <johannes@zellner.org>
# modified by mac@calmar.ws to fit my output needs
# modified by crncosta@carloscosta.org to fit my output needs
# pyroscope.project@gmail.com added a final "tput init", and changed the output format

import os
import sys

def echo(msg):
    os.system('echo -n "' + str(msg) + '"')

def out(n):
    os.system("tput setab " + str(n) + "; echo -n " + ("\"% 4d\"" % n))
    os.system("tput setab 0")

if os.getenv("TERM") in ("xterm", "screen"):
    os.putenv("TERM", os.getenv("TERM") + "-256color")

try:
    # normal colors 1 - 16
    os.system("tput setaf 16")
    for n in range(8):
        out(n)
    echo("\n")
    for n in range(8, 16):
        out(n)

    echo("\n")
    echo("\n")

    y=16
    while y < 256:
        for z in range(0,18):
            out(y)
            y += 1
            if y >= 256: break

        echo("\n")

    echo("\n")
finally:
    os.system("tput init")

