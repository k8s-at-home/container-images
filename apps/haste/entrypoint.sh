#!/usr/bin/env bash

#shellcheck disable=SC1091
source "/shim/umask.sh"
source "/shim/vpn.sh"

exec node /app/server.js ${@} ${EXTRA_ARGS}
