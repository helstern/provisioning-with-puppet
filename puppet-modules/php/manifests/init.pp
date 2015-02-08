class php {

    $php = hiera('php')

    php::phprepository{'php5 repository':
        phpversion => $php['version'],
        source     => $php['source']
    }

    $serverModule = ['libapache2-mod-php5']
    package { $serverModule:
        ensure => "present"
    }

    $package_defaults = {
        ensure => "present",
        require => [
            Php::Phprepository['php5 repository']
        ],
        before => [
            Package[$serverModule]
        ]
    }
    $package_resources = create_resources_hash('php', $php['packages'], 'package')
    create_resources(our_package::package, $package_resources, $package_defaults)

    if 'php5-xdebug' in $php['packages'] {
        class { "php::xdebugconf" :
            require => Package[$php['packages']]
        }
    }

}

