#!/usr/bin/env bash
set -e

/usr/local/ups/sbin/upsdrvctl -u kah start
exec /usr/local/ups/sbin/upsd -u kah -D
