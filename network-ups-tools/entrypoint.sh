#!/usr/bin/env bash
set -e

/usr/local/ups/sbin/upsdrvctl -u root start

if test -f "/etc/nut/upsmon.conf"; then
    #upsmon configuration exists, so run it
    (sleep 10; /usr/local/ups/sbin/upsmon -u root)&
fi

exec /usr/local/ups/sbin/upsd -u root -D