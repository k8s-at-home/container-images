#!/usr/bin/env bash

version=$(curl -sX GET "https://raw.githubusercontent.com/bmrzycki/nullserv/master/VERSION")
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
