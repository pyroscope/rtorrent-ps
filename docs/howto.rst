Tips & How-Tos
==============

.. _grok-std-cfg:

Checking Details of the Standard Configuration
----------------------------------------------

Not every detail of the standard configuration can be documented in this manual,
because at some point it would basically duplicate the ``*.rc`` files in English,
and also run the risk of being out of date (i.e. wrong) very fast.

To understand every nook and cranny of the features added by the config sets
that get installed if you follow :ref:`DebianInstallFromSource`,
look into the ``*.rc`` files and specifically read the comments in them.

The ``pyrocore`` files are in the ``~/.pyroscope/rtorrent.d`` directory,
and ``pimp-my-box`` ones in ``~/rtorrent/rtorrent.d``.

Remember that ``.rcignore`` files in those directories allow to
selectively disable parts of the standard configuration, like so:

.. code-block:: shell

    echo >>~/rtorrent/rtorrent.d/.rcignore "disable-control-q.rc"

For finding specifics on added commands or paths and such, ``grep`` is your friend,
as in this example:

.. code-block:: console

    $ grep -C1 import.rc ~/.pyroscope/rtorrent.d/*.rc ~/rtorrent/rtorrent.d/*.rc ~/rtorrent/*rt*rc
    rtorrent/rtorrent.rc-execute2 = (cat,(pyro.bin_dir),pyroadmin),-q,--create-import,(cat,(cfg.basedir),"rtorrent.d/*.rc")
    rtorrent/rtorrent.rc:import = (cat,(cfg.basedir),"rtorrent.d/.import.rc")
    rtorrent/rtorrent.rc-


Validate Self-Signed Certs
--------------------------

The following helps in case you want to use trackers with ``https`` announce URLs
that still use self-signed certificates, instead of *Let's Encrypt* like they should.
Unless you disable certificate checks in the rTorrent configuration,
you must add such certificates to your the system to make them valid.

This script does that via an easy command call, just pass it the tracker domain or URL:

.. code-block:: shell

    cat >/usr/local/sbin/load-domain-certificate <<'EOF'
    #! /bin/bash
    if test -z "$1"; then
        echo "usage: $0 <domainname_or_url>"
        exit 1
    fi
    DOMAINNAME=$(sed -re 's%^(https://)?([^/]+)(.*)$%\2%' <<<$1)
    set -x
    openssl s_client -servername ${DOMAINNAME} -connect ${DOMAINNAME}:443 </dev/null | tee /tmp/${DOMAINNAME}.crt
    openssl x509 -inform PEM -in /tmp/${DOMAINNAME}.crt -text -out /usr/share/ca-certificates/${DOMAINNAME}.crt
    grep ${DOMAINNAME}.crt /etc/ca-certificates.conf >/dev/null || echo ${DOMAINNAME}.crt >>/etc/ca-certificates.conf
    update-ca-certificates
    ls -l /etc/ssl/certs | grep ${DOMAINNAME}
    EOF
    chmod a+x /usr/local/sbin/load-domain-certificate
