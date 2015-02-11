#!/bin/sh

if [ $# -lt 2 ]; then
  exit 1
fi

ENVFILE="${1}"
ENVVAR="${2}"

if [ ! -f "${ENVFILE}" ]; then
    exit 1
fi

if [ -z "${ENVVAR}" ]; then
    exit 1
fi

if grep "export PATH=\$PATH:\$${ENVVAR}" "${ENVFILE}"; then
    exit 0
fi

echo "export PATH=\$PATH:\$${ENVVAR}" >> "${ENVFILE}"
