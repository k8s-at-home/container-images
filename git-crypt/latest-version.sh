#!/usr/bin/env bash

version=$(curl -sX GET "https://api.github.com/repos/AGWA/git-crypt/tags" | jq --raw-output 'del(.[] | select(.name | contains ("debian")))[0].name')
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
