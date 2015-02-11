class setup_system
{
    setup_system::sudoers_file{'0002-root-access-x11.conf':
        source  => "puppet:///modules/setup_system/etc/sudoers.d/0002-root-access-x11.conf"
    }

    our_package::package {'setup_system::git':
        package          => 'git',
        declare_once    => true,
        ensure          => 'present'
    }

    class { 'setup_system::etckeeper':
        operatingsystem => $::operatingsystem
    }

    class { 'setup_system::utilities':
        operatingsystem => $::operatingsystem,
        require         => Class['setup_system::etckeeper']
    }
}
