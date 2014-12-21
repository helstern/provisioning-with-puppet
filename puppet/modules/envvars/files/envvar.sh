#!/bin/sh

if [ $# -lt 2 ]; then
  exit 1
fi

ENVFILE="${1}"
ENVVAR="${2}"

if [ $# -eq 2 ]; then
 VALUE=$(cat)
elif [ $# -eq 3 ]; then
 VALUE="${3}"
fi

if [ ! -f "${ENVFILE}" ]; then
    exit 1
fi

if [ -z "${ENVVAR}" ]; then
    exit 1
fi

if [ -z "${VALUE}" ]; then
    exit 1
fi

if grep "export ${ENVVAR}=${VALUE}" "${ENVFILE}"; then
    exit 0
fi

echo "export ${ENVVAR}=${VALUE}" >> "${ENVFILE}"