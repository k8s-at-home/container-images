#!/usr/bin/env bash

#shellcheck disable=SC1091
source "/shim/umask.sh"

if [[ -f "/config/conf.js" ]]; then
	cp /config/conf.js /app/conf.js
fi

exec /usr/bin/node zenbot.js "$@" 
