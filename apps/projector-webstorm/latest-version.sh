#!/usr/bin/env bash

version=$(curl -sX GET "https://data.services.jetbrains.com/products?code=WS&release.type=release" | jq -r '.[0].releases[0].version')
printf "%s" "${version}"
