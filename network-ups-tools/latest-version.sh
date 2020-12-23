#!/usr/bin/env bash

git clone -q -b master https://github.com/networkupstools/nut.git "/tmp/nut"
version=$(cd /tmp/nut && git describe master)
version="${version#*v}"
version="${version#*release-}"
rm -rf /tmp/nut
printf "%s" "${version}"
