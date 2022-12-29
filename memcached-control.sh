#!/bin/bash
set -eo pipefail

if [ "${memcached}" = 'false' ]; then
	MOD=-x
else
	MOD=+x
fi

chmod ${MOD} /etc/service/memcached/run
