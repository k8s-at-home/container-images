#!/usr/bin/env bash

#shellcheck disable=SC1091
source "/shim/umask.sh"
source "/shim/vpn.sh"

# Update settings.json with environment variables
/usr/local/bin/envsubst < /app/settings.json.tmpl > /config/settings.json

echo "Transmission starting with the following configuration..."
cat /config/settings.json

exec /app/transmission-daemon --foreground --config-dir /config --port "${WEBUI_PORT}" ${EXTRA_ARGS}
