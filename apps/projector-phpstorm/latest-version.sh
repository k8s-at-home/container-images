#!/usr/bin/env bash

version=$(curl -sX GET "https://data.services.jetbrains.com/products?code=PS&release.type=release" | jq -r '.[0].releases[0].version')
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
