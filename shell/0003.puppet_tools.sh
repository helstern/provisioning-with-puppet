#!/usr/bin/env bash

set -e

#puppet configuration
if ! gem search puppet-module --local --installed >/dev/null 2>&1; then
    echo "installing puppet-module gem" \
    && gem install puppet-module \
    && echo "installed puppet-module gem"
fi

#install librarian-puppet package manager for puppet
if ! gem search librarian-puppet --local --installed >/dev/null 2>&1; then
    echo "installing librarian-puppet gem" \
    && gem install librarian-puppet \
    && echo "installed librarian-puppet gem"
fi

#configure puppet repository
PUPPETFILE_SOURCE="/puppet/puppet-librarian/Puppetfile"
PUPPETFILE_TARGET="/etc/puppet/Puppetfile"
REPOSITORY_PATH=$(dirname ${PUPPETFILE_TARGET})

#copy the repository configuration file
cp --remove-destination ${PUPPETFILE_SOURCE} ${PUPPETFILE_TARGET}

# if a .lock file exists, the repository must be updated otherwise it must initialized
cd "$REPOSITORY_PATH"
if [ -f ${PUPPETFILE_TARGET}".lock" ]; then
    librarian-puppet update  #why doesn't it work with --path instead of cd?
else
   librarian-puppet install --clean
fi
cd "$PWD"

if [ $? -ne 0 ]; then
    echo "Failed to initialize puppet-librarian repository"
    exit $?;
fi

