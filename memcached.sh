#!/bin/bash
set -eo pipefail

exec /sbin/setuser memcache /usr/bin/memcached -l 127.0.0.1 -m ${memcached:-64} >>/var/log/memcached.log 2>&1
