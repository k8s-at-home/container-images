#!/usr/bin/env bash

version=$(curl -sX GET https://api.github.com/repos/seejohnrun/haste-server/commits/master | jq --raw-output '. | .sha')
version="${version#*v}"
version="${version#*release-}"
version="${version:0:7}"
printf "%s" "${version}"
