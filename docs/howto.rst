Tips & How-Tos
==============

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
