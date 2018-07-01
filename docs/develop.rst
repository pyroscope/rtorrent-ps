Development Guide
=================

This chapter contains some explanations of the project structure and
activities related to development of the project.


.. _invoke-test:

Running Integration Tests
-------------------------

The ``tasks.py`` script defines a ``test`` task for `invoke`,
which runs tests located in the ``tests/commands/*.txt`` files.

These test scripts are edited console logs of shell calls,
and the test runner executes any line starting with a ``$``.
It then checks that any line following the command is contained
in its output. The return code is checked via a ``RC=n`` line.

Any line starting with ``#`` is a comment.

The lines asserting output can contain ``…`` to mark omissions
– any whitespace around it is ignored.
That means that ``foo … bar`` checks that *both* ``foo`` and ``bar``
are contained somewhere in the command's output.

Here's the sample output you want to have (no failures):

.. code-block:: console

    $ invoke test
    --- Running tests in 'tests/commands/array.txt'...
    .......

    --- Running tests in 'tests/commands/misc.txt'...
    ..................................................

    --- Running tests in 'tests/commands/string.txt'...
    ....................

    --- Running tests in 'tests/commands/math.txt'...
    .......................................

    ☺ ☺ ☺  ALL OK. ☺ ☺ ☺


And this is what a failure looks like:

.. code-block:: console

    $ invoke test -n misc
    --- Running tests in 'tests/commands/misc.txt'...
    .
    FAIL: »!1’20”« not found in output of »rtxmlrpc convert.time_delta '' +1527903580 +1527903500«
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    1’20”
    RC=0
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    ................................................

    ☹ ☹ ☹  1 TEST(S) FAILED. ☹ ☹ ☹

This also shows how you can run only one selected test suite, using the ``--name`` or ``-n`` option.


.. _build-sh:

The Build Script
----------------

The `build.sh`_ script contains all the minute details and settings to successfully
build selected dependencies and the `libtorrent` / `rtorrent` source on many platforms.

And no, it is not a `Makefile`, since there's no benefit in that, for the things the script does.
``[g]make`` is used *within* the contributing projects.

See :ref:`build-from-source` on the ‘normal’ use of the script for building a binary.
Other uses like building packages (with or without `Docker`) or the most recent upstream source
are described in the following sections.

To **build a new extended binary after you downloaded updates** via a ``git pull --ff-only``,
just call ``./build.sh extend`` – this will apply any new patches included in that update,
but not re-build all the dependencies.

If you're sure that the diff only contains source code changes (in ``patches/*.cc``),
only calling ``make`` in the `rTorrent` source directory is *way faster*.
In case dependency versions changed in ``build.sh``, you have to go the slowest route with
``./build.sh clean_all all`` to get them onto your machine.


For everything else, call ``./build.sh help`` to get a usage summary similar to this:

.. code-block:: console

    $ ./build.sh help
    Environment for building rTorrent PS-1.0-349-g12ccbe8-2018-06-30-1143 0.9.6/0.13.6
    export PACKAGE_ROOT=/opt/rtorrent
    export INSTALL_ROOT=/home/pyroscope
    …

    Usage: ./build.sh (all | clean | clean_all | download | build | check | extend)
    Build rTorrent PS-1.0-… 0.9.6/0.13.6 into ~/.local/rtorrent/0.9.6-PS-1.1-dev

    Custom environment variables:
        CURL_OPTS="-sLS" (e.g. --insecure)
        MAKE_OPTS="-j4"
        CFG_OPTS="" (e.g. --enable-debug --enable-extra-debug)
        CFG_OPTS_LT="" (e.g. --disable-instrumentation for MIPS, PowerPC, ARM)
        CFG_OPTS_RT=""

    Build actions:
        build_all   a/k/a ‹all› – Download and build and install all deps + vanilla + extended
        build       Build and install all components
        build_git   a/k/a ‹git› – Build and install libtorrent and rtorrent from git checkouts
        check       Print some diagnostic success indicators
        clean_all   Remove all downloads and created files
        clean       Clean up generated files
        deps        Build all dependencies
        deps_git    Build all dependencies [GIT HEAD MODE]
        docker_deb  Build Debian packages via Docker
        download    Download and unpack sources
        env         Show build environement
        extend      Rebuild and install libtorrent and rTorrent with patches applied
        install     Install to /opt/rtorrent
        pkg2deb     Package current /opt/rtorrent installation for APT [needs fpm]
        pkg2pacman  Package current /opt/rtorrent installation for PACMAN [needs fpm]
        vanilla     Build vanilla rTorrent [also un-patches src dirs]


.. _do-release:

Creating a Release
------------------

*  Finish ``docs/CHANGES.md`` and set the release date
*  Run ``invoke cmd_docs >docs/include-commands.rst``, and commit any additions
*  Make sure every command has docs in the manual (``invoke undoc``)
*  Tag the release, push tags, put changelog up on GitHub
*  Build packages and upload to Bintray (using ``bintray.sh``)
*  Change DEB download links in `pimp-my-box`
*  Make a stable snapshot of docs under the new version
*  Bump version to next release in ``docs/conf.py``
*  Announce to `reddit` etc.


.. _build-pkg2deb:

Building the Debian Package
---------------------------

A Debian package for easy installation is built using
`fpm <https://github.com/jordansissel/fpm>`_, so you have to install
that first on the build machine, if you don't have it yet:

.. code-block:: bash

    apt-get install ruby ruby-dev
    gem install fpm
    fpm -h | grep fpm.version

Then you need to prepare the install target, as follows (we assume
building under the ``rtorrent`` user here):

.. code-block:: bash

    mkdir -p /opt/rtorrent
    chmod 0755 /opt/rtorrent
    chown -R rtorrent.rtorrent /opt/rtorrent

Then, the contents of the package are built by calling
``./build.sh install``, which will populate the ``/opt/rtorrent``
directory. When that is done, you can test the resulting executable
located at ``/opt/rtorrent/bin/rtorrent``.

Finally, ``./build.sh pkg2deb`` creates the Debian package in ``/tmp``.
The script expects the packager's name and email in the usual
environment variables, namely ``DEBFULLNAME`` and ``DEBEMAIL``. For a
few platforms (recent Debian, Ubuntu, and Raspbian), you can find
pre-built ones at `Bintray`_.

.. seealso::

    :ref:`build-docker_deb`


Building git HEAD of rTorrent
-----------------------------

You can also build the latest source of the main rTorrent project (including its ``libtorrent``),
with all the settings and rpath linking of the ``rtorrent-ps`` builds,
but just like *vanilla* when it comes to applying patches
(only *essential* ones are applied, like the `OpenSSL` one).

This is intended to be used for checking compatibility of patches with the head of the core project,
and preparing PRs for it.
You will *not get a stable system* and these builds are in no way recommended for production use.

Start by checking out the two projects as siblings of the ``rtorrent-ps`` workdir,
leading to a folder structure like this:

::

    .
    ├── libtorrent
    ├── rakshasa-rtorrent
    └── rtorrent-ps

As you can see, the sibling folders can have an optional ``rakshasa-`` prefix.

Then use these commands within ``rtorrent-ps`` to build all dependencies and
the git HEAD code from the sibling folders:

.. code-block:: bash

    INSTALL_DIR=$HOME/.local/rtorrent-git ./build.sh clean_all deps_git build_git

Just like with the vanilla and extended version, you'll get a ‘branded’ binary
called ``rtorrent-git``, and a symlink at ``~/bin/rtorrent`` will point to it.

The ``INSTALL_DIR`` is set explicitly,
so that a release version and git HEAD can be installed and used concurrently,
without any conflicts.


.. _build-docker_deb:

Using Docker for Building Packages
----------------------------------

The ``docker_deb`` build action uses ``Dockerfile.Debian`` to compile and package
*rTorrent-PS* on a given *Debian* or *Ubuntu* release.

``docker_deb`` takes an optional ``‹distro›:‹codename›`` argument,
and defaults to ``debian:stretch``.
You can also use ``all``, ``stable``, or ``oldstable`` to name classes of distributions,
defined in the related `docker_distros_*`_ lists at the start of `build.sh`_.

Any additional arguments are passed on to the underlying ``docker build`` command.
Since ``docker_deb`` takes arguments, you cannot call any further actions after it,
in the same ``build.sh`` call.

.. note::

    You need Docker version ``17.06`` or higher to use this.


.. _`build.sh`: https://github.com/pyroscope/rtorrent-ps/blob/master/build.sh#L1-L3
.. _`Bintray`: https://bintray.com/pyroscope/rtorrent-ps/rtorrent-ps
.. _`docker_distros_*`: https://github.com/pyroscope/rtorrent-ps/search?type=Code&utf8=%E2%9C%93&q=docker_distros_stable
