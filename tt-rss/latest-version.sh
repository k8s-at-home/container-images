#!/usr/bin/env bash

MAYOR_VERSION=1
CHECKOUT_DIR=/tmp/tt-rss

if [ -d "$CHECKOUT_DIR" ]; then
  cd "$CHECKOUT_DIR"
  git pull > /dev/null
else
  git clone https://git.tt-rss.org/fox/tt-rss.git "$CHECKOUT_DIR" > /dev/null
  cd "$CHECKOUT_DIR"
fi

number_of_commits=$(git rev-list --count --first-parent HEAD)

printf "%s.%s.0" "${MAYOR_VERSION}" "${number_of_commits}"
