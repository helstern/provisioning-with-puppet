#!/bin/bash

if [ -z "${1}" ]; then
    exit 1
fi

if [ -z "${2}" ]; then
    exit 2
fi


VERSION="${1}"
SOURCE_ARCHIVE="${2}"

cd /tmp
tar -xzvf "${SOURCE_ARCHIVE}" --target /tmp/ruby-install-${VERSION}
cd ruby-install-${VERSION}/ && make install

cd /tmp && rm --force --recursive ruby-install-${VERSION}/
