Development Guide
=================

This chapter contains some explanations of the project structure and
activities related to development of the project.


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
with all the settings and rpath linking of the ``rtorrent-ps`` builds.
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

    ./build.sh clean_all deps git

Just like with the vanilla and extended version, you'll get a ‘branded’ binary
called ``rtorrent-git``, and a symlink at ``~/bin/rtorrent`` will point to it.

Note however that the new ``libtorrent.so`` is unlikely to work with the
vanilla and extended code, so they'll be rendered unusable until you rebuild them.
Doing that will in turn render the git version broken.
This could be easily avoided if the (ABI) versions were bumped in git
directly after a release, but alas…

So if you want to run git HEAD concurrently to release versions,
use a dedicated user account to build, install, and run it.


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
