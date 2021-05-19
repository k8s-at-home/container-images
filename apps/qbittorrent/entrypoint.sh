#!/usr/bin/env bash

#shellcheck disable=SC1091
source "/shim/umask.sh"
source "/shim/vpn.sh"

if [[ ! -f "/config/qBittorrent/qBittorrent.conf" ]]; then
    mkdir -p /config/qBittorrent
    cp /app/qBittorrent.conf /config/qBittorrent/qBittorrent.conf
fi

python3 /shim/config.py

if [[ ! -d "/config/qBittorrent/logs" ]]; then
    mkdir -p /config/qBittorrent/logs
fi

ln -sf /proc/self/fd/1 /config/qBittorrent/logs/qbittorrent.log

exec /app/qbittorrent-nox --webui-port="${WEBUI_PORT}" ${EXTRA_ARGS}
