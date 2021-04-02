#!/usr/bin/env bash

version=$(curl -sX GET "https://api.github.com/repos/mxpv/podsync/tags" | jq --raw-output '.[0].name')
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
