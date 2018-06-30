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

**TODO**


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

.. _`Bintray`: https://bintray.com/pyroscope/rtorrent-ps/rtorrent-ps


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
The ``docker_all`` action does so for the major releases
– see the `docker_distros`_ list at the start of `build.sh`_ which ones exactly.

``docker_deb`` takes an optional ``‹distro›:‹codename›`` argument,
and defaults to ``debian:stretch``.
Any additional arguments are passed on to ``docker build``,
and ``docker_all`` does the same.
Since those actions take arguments, you cannot call any further actions after them,
in the same ``build.sh`` call.

.. note::

    You need Docker version ``17.06`` or higher to use this.

.. _build.sh: https://github.com/pyroscope/rtorrent-ps/blob/master/build.sh
.. _`docker_distros`: https://github.com/pyroscope/rtorrent-ps/search?type=Code&utf8=%E2%9C%93&q="platforms+to+build"+with+docker_all
