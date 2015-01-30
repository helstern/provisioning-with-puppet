#!/bin/bash

if [ -z "${1}" ]; then
    exit 1
fi

if [ -z "${2}" ]; then
    exit 2
fi


TARGET_DIR="/tmp/chruby-${1}"
SOURCE_ARCHIVE="${2}"

mkdir ${TARGET_DIR}
tar -xzvf "${SOURCE_ARCHIVE}" --directory ${TARGET_DIR} --strip-components=1
cd ${TARGET_DIR} && make install
cd /tmp && rm --force --recursive ${TARGET_DIR}