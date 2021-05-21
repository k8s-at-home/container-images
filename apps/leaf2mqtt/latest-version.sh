#!/usr/bin/env bash

git clone -q -b main https://github.com/mitsumaui/leaf2mqtt.git "/tmp/leaf2mqtt"
version=$(cd /tmp/leaf2mqtt && git describe main --tags)
version="${version#*v}"
version="${version#*release-}"
rm -rf /tmp/leaf2mqtt
printf "%s" "${version}"
