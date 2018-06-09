# -*- coding: utf-8 -*-
#
# Project Tasks
#
from __future__ import print_function, unicode_literals

import os
import re
import time
import glob
import shutil
import subprocess

from invoke import task

SPHINX_AUTOBUILD_PORT = 8340


def watchdog_pid(ctx):
    """Get watchdog PID via ``netstat``."""
    result = ctx.run('netstat -tulpn 2>/dev/null | grep 127.0.0.1:{:d}'
                     .format(SPHINX_AUTOBUILD_PORT), warn=True, pty=False)
    pid = result.stdout.strip()
    pid = pid.split()[-1] if pid else None
    pid = pid.split('/', 1)[0] if pid and pid != '-' else None

    return pid


@task
def docs(ctx):
    """Start watchdog to build the Sphinx docs."""
    build_dir = 'docs/_build'
    index_html = build_dir + '/html/index.html'

    stop(ctx)
    if os.path.exists(build_dir):
        shutil.rmtree(build_dir)

    print("\n*** Generating HTML doc ***\n")
    ctx.run('builtin cd docs'
            ' && . {pwd}/.pyvenv/*/bin/activate'
            ' && nohup {pwd}/docs/Makefile SPHINXBUILD="sphinx-autobuild -p {port:d}'
            '          -i \'.*\' -i \'*.log\' -i \'*.png\' -i \'*.txt\'" html >autobuild.log 2>&1 &'
            .format(port=SPHINX_AUTOBUILD_PORT, pwd=os.getcwd()), pty=False)

    for i in range(25):
        time.sleep(2.5)
        pid = watchdog_pid(ctx)
        if pid:
            ctx.run("touch docs/index.rst")
            ctx.run('ps {}'.format(pid), pty=False)
            url = 'http://localhost:{port:d}/'.format(port=SPHINX_AUTOBUILD_PORT)
            print("\n*** Open '{}' in your browser...".format(url))
            break


@task
def stop(ctx):
    "Stop Sphinx watchdog"
    print("\n*** Stopping watchdog ***\n")
    for i in range(4):
        pid = watchdog_pid(ctx)
        if not pid:
            break
        else:
            if not i:
                ctx.run('ps {}'.format(pid), pty=False)
            ctx.run('kill {}'.format(pid), pty=False)
            time.sleep(.5)


@task(
    help={
        'name': "name of a specific group of tests to run",
    },
)
def test(ctx, name=''):
    """Run command integration tests."""
    test_dir = 'tests/commands'
    failures = 0

    if name:
        assert os.path.exists(os.path.join(test_dir, name + '.txt')), \
               "Named test file does not exist!"

    for test_file in glob.glob(os.path.join(test_dir, name + '.txt' if name else '*.txt')):
        print("--- Running tests in '{}'...".format(test_file))

        with open(test_file, 'r') as handle:
            cmd, output = None, None
            for line in handle:
                line = line.strip()
                if not line or line.startswith('#'):
                    continue

                if line.startswith('$'):
                    cmd = line[1:].strip()
                    output = subprocess.check_output(cmd + '; echo RC=$?; exit 0',
                                                     shell=True, stderr=subprocess.STDOUT)
                    output = output.decode('utf-8')
                elif all(x.strip() in output for x in line.split('…')):
                    print('.', end='', flush=True)
                else:
                    failures += 1
                    print('\nFAIL: »{l}« not found in output of »{cmd}«\n{d}\n{o}\n{d}\n'
                          .format(l=line, cmd=cmd, o=output.rstrip(), d='~'*78))
        print('\n')

    print('\n☹ ☹ ☹  {} TEST(S) FAILED. ☹ ☹ ☹ '.format(failures) if failures else '\n☺ ☺ ☺  ALL OK. ☺ ☺ ☺ ')


@task
def cmd_docs(ctx):
    """Generated customc command docs – invoke cmd_docs >docs/include-commands.rst"""
    output = subprocess.check_output(
        "egrep -nH '^    CMD2?_' patches/ui_pyroscope.cc patches/command_pyroscope.cc"
        " | cut -f2 -d'\"' | sort ; exit 0", shell=True, stderr=subprocess.STDOUT)

    url = 'https://rtorrent-docs.readthedocs.io/en/latest/cmd-ref.html'
    commands = ['ui.color.alarm…title', 'ui.color.*.index',  'ui.color.*.set', 'ui.column.render']
    commands.extend(output.decode('ascii').splitlines())
    commands.sort()

    print('.. ' + cmd_docs.__doc__)
    print('')

    for group in ('math.*', 'string.*', 'convert.*', 'system.*', 'd.*', 'network.*', 'ui.*', ''):
        group_commands = []
        for idx, name in reversed(list(enumerate(commands))):
            if name.startswith(group.rstrip('*')):
                group_commands.insert(0, name)
                del commands[idx]

        print('.. rubric:: `{}` Commands'.format(group or 'Other'))
        print('')
        print('.. hlist::')
        print('   :columns: 3')
        print('')
        for name in group_commands:
            print('   * `{}`_'.format(name))

        print('')

        for name in group_commands:
            slug = re.sub(r'[^a-z0-9]+', '-', name)
            print('.. _`{name}`: {url}#term-{slug}'.format(name=name, slug=slug, url=url)
                  .replace('ui-color-alarm-title', 'ui-color-custom1-9')
                  .replace('ui-color-index', 'ui-color-custom1-9')
                  .replace('ui-color-set', 'ui-color-custom1-9')
            )

        print('')
        print('')

    assert not commands, "Not all commands added!"
