#!/usr/bin/env bash

#shellcheck disable=SC1091
source "/shim/greeting.sh"
source "/shim/umask.sh"
source "/shim/vpn.sh"

set -e

node ./docker-entrypoint.js > ./config.js

exec node /app/server.js ${@} ${EXTRA_ARGS}
