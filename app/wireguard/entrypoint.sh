#!/usr/bin/env bash

set -e

source "/shim/iptables-backend.sh"

if [[ "$(cat /proc/sys/net/ipv4/conf/all/src_valid_mark)" != "1" ]]; then
    echo "[WARNING] sysctl net.ipv4.conf.all.src_valid_mark=1 is not set" >&2
fi

CONFIGS=`sudo /usr/bin/find /etc/wireguard -type f -printf "%f\n"`
if [[ -z "${CONFIGS}" ]]; then
    echo "[ERROR] No configuration files found in /etc/wireguard" >&2
    exit 1
fi

CONFIG=`echo $CONFIGS | head -n 1`
INTERFACE="${CONFIG%.*}"

sudo /usr/bin/wg-quick up "${INTERFACE}"

source "/shim/killswitch.sh"

_shutdown () {
    echo "[INFO] Caught signal, shutting down VPN!"
    sudo /usr/bin/wg-quick down "${INTERFACE}"
}

trap _shutdown SIGTERM SIGINT SIGQUIT

sleep infinity &
wait $!
