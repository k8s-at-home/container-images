#!/usr/bin/env bash

git clone -q -b unstable https://github.com/DeviaVir/zenbot.git "/tmp/zenbot"
version=$(cd /tmp/zenbot && git describe unstable)
version="${version#*v}"
version="${version#*release-}"
rm -rf /tmp/zenbot
printf "%s" "${version}"
