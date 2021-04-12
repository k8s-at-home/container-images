#!/usr/bin/env bash

#shellcheck disable=SC1091
source "/shim/umask.sh"
source "/shim/vpn.sh"
source "/shim/jks.sh"
source "/shim/ide.sh"

exec "$IDE_RUN_FILE_NAME-projector.sh"
