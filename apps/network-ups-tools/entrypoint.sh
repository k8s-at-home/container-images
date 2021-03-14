#!/usr/bin/env bash
set -e

/usr/local/ups/sbin/upsdrvctl -u root start
exec /usr/local/ups/sbin/upsd -u root -D
