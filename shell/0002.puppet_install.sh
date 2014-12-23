#!/bin/bash

set -x
# pipe fail if one command fails
set -o pipefail
PWD=$(pwd)

# check that script is running with elevated privileges
if [ $(/usr/bin/id -u) -ne 0 ]; then
    echo "Not running as root or using sudo"
    exit 1
fi

#enables puppet labs repository for puppet
puppetEnablePuppetLabsRepository ()
{
    if find /etc/apt -name *.list -print0 | xargs --null grep "puppetlabs" >/dev/null 2>&1 ; then
        echo "puppet labs repository present"
        return 1;
    fi

    echo "enabling puppet labs repository for puppet"
    wget --directory-prefix /tmp https://apt.puppetlabs.com/puppetlabs-release-precise.deb >/dev/null 2>&1 \
    && dpkg --install  --force-overwrite /tmp/puppetlabs-release-precise.deb >/dev/null 2>&1 \
    && apt-get update > /dev/null 2>&1
}

pkgLogInstallStatus ()
{
    local PKG="$1"
    local PKG_INSTALL_STATUS=$2

    case $PKG_INSTALL_STATUS in
        0)  echo "Installed required $PKG package"
            ;;
        1)  echo "Required $PKG package present"
            ;;
        *)  echo "Could not install required $PKG package."
            exit 1
            ;;
    esac
}

#installs a package if not allready installed
pkgInstallUnlessExists ()
{
    local PKG="$1"
    local PKG_INSTALLED=$(dpkg-query -W --showformat='${Status}\n' $PKG 2>&1 | grep "install ok installed")

    #pkg is installed
    if [ "$PKG_INSTALLED" != "" ]; then
        return 1
    fi

    apt-get --yes install $PKG >/dev/null 2>&1

    if [ $? -ne 0 ]; then
        return 2
    else
        return 0
    fi
}

# compares two versions and outputs <, > , =
versionCompare ()
{
    if [ $# -lt 2 ]; then
        return 1
    fi

    if [ -z "$1" ] || [ -z "$2" ]; then
        return 1
    fi

    if [ "$1" = "$2" ]; then
        echo '='
        return 0
    fi

    local IFS=","
    local LESSER=$(echo "$@" | tr ' ' "\n" | sort --version-sort | head --lines 1)

    if [ "$LESSER" = "$1" ]; then
        echo '<'
    else
        echo '>'
    fi
}

# returns zero if if $2 is greater or equal than $1
versionMinimumIsSatisfied ()
{
    local COMPARE=$(versionCompare "$@")

    if [ $? -gt 0 ]; then
        return $?
    fi

    case ${COMPARE} in
        '<')  return 0
            ;;
        '=')  return 0;
            ;;
        *)  return 1
            ;;
    esac
}

#see https://github.com/joshfng/railsready/blob/master/railsready.sh
ruby_version="1.9.3"
ruby_version_string="1.9.3"
ruby_source_url="http://cache.ruby-lang.org/pub/ruby/ruby-1.9.3-p545.tar.gz"
ruby_source_tar_name="ruby-1.9.3-p545.tar.gz"
ruby_source_dir_name="ruby-1.9.3-p545"

INSTALL_RUBY=true && type ruby > /dev/null 2>&1 && versionMinimumIsSatisfied ${ruby_version_string} $(ruby --version | cut --fields 2 --delimiter ' ') && INSTALL_RUBY=false
if ${INSTALL_RUBY}; then
# Install Ruby, see https://leonard.io/blog/2012/05/installing-ruby-1-9-3-on-ubuntu-12-04-precise-pengolin
    if ! apt-get install --fix-missing --yes build-essential libssl-dev zlib1g-dev ; then
        echo 'failed to install build-essential libssl-dev zlib1g-dev'
        exit 1
    fi
    if ! apt-get install --fix-missing --yes ruby1.9.1 ruby1.9.1-dev rubygems1.9.1 irb1.9.1 ri1.9.1 rdoc1.9.1 libopenssl-ruby1.9.1; then
        echo 'failed to install ruby1.9.1 ruby1.9.1-dev rubygems1.9.1 irb1.9.1 ri1.9.1 rdoc1.9.1 libopenssl-ruby1.9.1'
        exit 1
    fi


    update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby1.9.1 400 \
         --slave /usr/share/man/man1/ruby.1.gz ruby.1.gz /usr/share/man/man1/ruby1.9.1.1.gz \
        --slave   /usr/bin/ri ri /usr/bin/ri1.9.1 \
        --slave   /usr/bin/irb irb /usr/bin/irb1.9.1 \
        --slave   /usr/bin/rdoc rdoc /usr/bin/rdoc1.9.1

    # sudo gem update --system --no-ri --no-rdoc
    gem install bundler --no-ri --no-rdoc -f
fi

#enable puppet labs repository
puppetEnablePuppetLabsRepository

#install minimum puppet version to allow librarian to run
PUPPET_MIN_VERSION=3.*
INSTALL_PUPPET=true && type puppet > /dev/null 2>&1 && versionMinimumIsSatisfied ${PUPPET_MIN_VERSION} "$(puppet --version)" && INSTALL_PUPPET=false

if ${INSTALL_PUPPET}; then
    #known puppet issue with overwritting man pages, see http://projects.puppetlabs.com/issues/16746#note-2
    apt-get install \
        puppet="$PUPPET_MIN_VERSION" \
        puppet-common="$PUPPET_MIN_VERSION" \
        puppetmaster="$PUPPET_MIN_VERSION" \
        puppetmaster-common="$PUPPET_MIN_VERSION" \
        --yes \
        --option Dpkg::Options::="--force-overwrite" \
        >/dev/null 2>&1
fi

if ${INSTALL_PUPPET} && [ $? -eq 0 ]; then
    echo "Installed puppet verion $PUPPET_MIN_VERSION"
elif ${INSTALL_PUPPET} && [ $? -ne 0 ]; then
    echo "Failed to upgrade pupppet to $PUPPET_MIN_VERSION"
    exit 1
else
    echo "Puppet version requirement (min $PUPPET_MIN_VERSION) met"
fi

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
