#!/usr/bin/env bash

#shellcheck disable=SC1091
source "/shim/umask.sh"
source "/shim/vpn.sh"

if [[ ! -f "/config/sabnzbd.ini" ]]; then
    printf "Copying over default configuration ... "
    mkdir -p /config/sabnzbd
    cp /app/sabnzbd.ini /config/sabnzbd.ini
fi

if [[ -n ${HOST_WHITELIST_ENTRIES} ]]; then
    printf "Updating host_whitelist setting ... "
    sed -i -e "s/^host_whitelist *=.*$/host_whitelist = ${HOSTNAME}, ${HOST_WHITELIST_ENTRIES}/g" /config/sabnzbd.ini
fi

exec /usr/bin/python3 /app/SABnzbd.py --browser 0 --server 0.0.0.0:8080 --config-file /config/sabnzbd.ini ${EXTRA_ARGS}
