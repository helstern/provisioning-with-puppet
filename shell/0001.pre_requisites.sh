#!/bin/bash

# check that script is running with elevated privileges
if [ $(/usr/bin/id -u) -ne 0 ]; then
    echo "Not running as root or using sudo"
    exit 1
fi

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

apt-get update --yes

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
