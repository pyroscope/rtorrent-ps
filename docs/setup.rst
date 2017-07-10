Installation Guide
==================

Note that this cannot be a Linux shell 101, so if the terminology and commands that follow
are new for you, refer to the usual sources like
`The Debian Administrator's Handbook`_, `The Linux Command Line`_, and
`The Art of Command Line`_.

.. _The Debian Administrator's Handbook: http://debian-handbook.info/browse/stable/
.. _The Linux Command Line: http://linuxcommand.org/tlcl.php
.. _The Art of Command Line: https://github.com/jlevy/the-art-of-command-line#the-art-of-command-line


General Installation Options
----------------------------

See the `instructions
here <https://github.com/pyroscope/rtorrent-ps/blob/master/docs/DebianInstallFromSource.md#build-rtorrent-and-core-dependencies-from-source>`_
for building from source using the provided ``build.sh`` script, which
will install *rTorrent-PS* into ``~/.local/rtorrent/‹version›``.

.. note:: If you also install the `PyroScope command line
    utilities <https://github.com/pyroscope/pyrocore>`_, do not forget to
    activate the extended features available together with *rTorrent-PS*, as
    mentioned in the
    `Configuration Guide <https://pyrocore.readthedocs.org/en/latest/setup.html#extending-your-rtorrent-rc>`_.

Also take note of the
`pimp-my-box <https://github.com/pyroscope/pimp-my-box>`_ project that
does it all (almost) automatically for Debian-type systems (and is the
preferred way to install on those systems). The automation is done using
`Ansible <http://docs.ansible.com/>`_, which implies you can easily
admin several systems with it, and also maintain them – so it's not a
one-shot installation bash script creating a setup that can never be
changed again.


OS-Specific Installation Options
--------------------------------

Installation Using Debian Packages
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

For a limited set of Debian-derived platforms, there are packages
available that contain pre-compiled binaries (and only those, no
configuration or init scripts). You can download and install such a
package from `Bintray`_ —
assuming one is available for your platform. The packages install the
*rTorrent-PS* binary including some libraries into ``/opt/rtorrent``.

Example on Raspbian Jessie:

.. code-block:: bash

    version="0.9.6-20160308-c7c8d31~jessie_armhf"
    cd /tmp
    curl -Lko rt-ps.deb "https://bintray.com/artifact/download/pyroscope/rtorrent-ps/rtorrent-ps_$version.deb"
    dpkg -i rt-ps.deb

After installation, you must provide a configuration file
(``~/.rtorrent.rc``), and either use the absolute path to the binary to
start it, or link it into ``/usr/local`` like this:

.. code-block:: bash

    ln -s /opt/rtorrent/bin/rtorrent /usr/local/bin

.. note:: You can safely install the package and test it
    out in parallel to an existing installation, just use the absolute path
    ``/opt/rtorrent/bin/rtorrent`` to start rTorrent. Your data is in no way
    affected as long as you normally run a 0.9.x version.


Installation on Arch Linux
^^^^^^^^^^^^^^^^^^^^^^^^^^

There are now two options contributed by `xsmile <https://github.com/xsmile>`_
for installing on *Arch* via ``pacman``.

#. The ``pkg2pacman`` command of ``build.sh`` creates a package similar to the
   Debian one, embedding a tested version combination of dependencies.
   See *“Building the Debian Package”* for general instructions on building that
   variant, and use ``pkg2pacman`` instead of ``pkg2deb``.
#. The *“Arch User Repository”* (AUR) PKGBUILDs maintained by @xsmile.
   These use a standard *Arch* build process, but include the usual *rTorrent-PS*
   patches.

   There is one package for ``libtorrent-ps``, and one for ``rtorrent-ps``,
   and both take their dependencies from the normal OS packages:

   - https://aur.archlinux.org/packages/libtorrent-ps/
   - https://aur.archlinux.org/packages/rtorrent-ps/

There is also the
`rtorrent-pyro-git <https://aur.archlinux.org/packages/rtorrent-pyro-git/>`_
AUR package.
It is *not* the same as you get from using ``build.sh``,
and not recommended anymore by *this* project, given the new options above.

If you have problems with building or installing any of these packages,
contact *their maintainer*.


Homebrew Tap for Mac OSX
^^^^^^^^^^^^^^^^^^^^^^^^

See the
`homebrew-rtorrent-ps <https://github.com/pyroscope/homebrew-rtorrent-ps>`_
repository for instructions to build *rTorrent-PS* and related
dependencies on Mac OSX.

**Right now, it is not maintained by anyone.**


.. _DebianInstallFromSource:

Manual Installation on Debian-type Systems
------------------------------------------

See https://github.com/pyroscope/rtorrent-ps/blob/master/docs/DebianInstallFromSource.md.
