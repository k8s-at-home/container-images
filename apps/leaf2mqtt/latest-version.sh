#!/usr/bin/env bash

git clone -q -b master https://github.com/Troon/leaf2mqtt.git "/tmp/leaf2mqtt"
version=$(cd /tmp/leaf2mqtt && git rev-parse --short HEAD)
version="${version#*v}"
version="${version#*release-}"
rm -rf /tmp/leaf2mqtt
printf "%s" "${version}"
