#!/bin/bash

# check that script is running with elevated privileges
if [ $(/usr/bin/id -u) -ne 0 ]; then
    echo "Not running as root or using sudo"
    exit 1
fi

apt-get update --yes
# apt-get upgrade does not always succedes
# apt-get upgrade --yes