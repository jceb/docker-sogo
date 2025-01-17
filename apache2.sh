#!/bin/bash
set -eo pipefail

# Copy back and enable administrator's configuration
cp -L /srv/etc/apache-SOGo.conf /etc/apache2/conf-enabled/SOGo.conf

# Run apache in foreground
APACHE_ARGUMENTS="-DNO_DETACH" exec /usr/sbin/apache2ctl start
