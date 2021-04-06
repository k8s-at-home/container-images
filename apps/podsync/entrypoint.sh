#!/usr/bin/env bash

#shellcheck disable=SC1091
source "/shim/umask.sh"
source "/shim/vpn.sh"

if [[ ! -f "/config/config.toml" ]]; then
    mkdir -p /config
    cp /app/config.toml /config/config.toml
fi

exec /app/podsync --config /config/config.toml ${EXTRA_ARGS}
