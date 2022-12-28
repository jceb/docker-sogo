#!/bin/bash
set -eo pipefail

mkdir -p /var/run/sogo
touch /var/run/sogo/sogo.pid
chown -R sogo:sogo /var/run/sogo

#Solve libssl bug for Mail View
if [[ -z "${LD_PRELOAD}" ]]; then
	LIBSSL_LOCATION=$(find / -type f -name "libssl.so.*" -print -quit)
	echo "LD_PRELOAD=$LIBSSL_LOCATION" >>/etc/default/sogo
	export LD_PRELOAD=$LIBSSL_LOCATION
else
	echo "LD_PRELOAD=$LD_PRELOAD" >>/etc/default/sogo
	export LD_PRELOAD=$LD_PRELOAD
fi

# Copy back administrator's configuration
cp -L /srv/etc/sogo.conf /etc/sogo/sogo.conf

# Create SOGo home directory if missing
mkdir -p /srv/lib/sogo
chown -R sogo /srv/lib/sogo

# Load crontab
cp -L /srv/etc/cron /etc/cron.d/sogo

# Run SOGo in foreground
LD_PRELOAD=$LD_PRELOAD exec /sbin/setuser sogo /usr/sbin/sogod -WOUseWatchDog $USEWATCHDOG -WONoDetach YES -WOPort 20000 -WOPidFile /var/run/sogo/sogo.pid
