#!/usr/bin/env bash

version=$(curl -s 'https://api.github.com/repos/JetBrains/projector-server/releases' | jq -r '. - map(select(.tag_name | contains("agent"))) | first | .tag_name')
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
