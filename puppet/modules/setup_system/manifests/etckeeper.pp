class setup_system::etckeeper (
    $operatingsystem = $::operatingsystem
) {

    # HIGHLEVEL_PACKAGE_MANAGER config setting.
    $etckeeper_high_pkg_mgr = $operatingsystem ? {
    /(?i-mx:ubuntu|debian)/                           => 'apt',
    /(?i-mx:centos|fedora|redhat|oraclelinux|amazon)/ => 'yum',
    }

    # LOWLEVEL_PACKAGE_MANAGER config setting.
    $etckeeper_low_pkg_mgr = $operatingsystem ? {
    /(?i-mx:ubuntu|debian)/                           => 'dpkg',
    /(?i-mx:centos|fedora|redhat|oraclelinux|amazon)/ => 'rpm',
    }

    package{ 'etckeeper':
        ensure => "present",
        require => [Package['git'], File['etc/etckeeper/etckeeper.conf']],
        notify => Exec['setup etckeeper'],
    }

    file { '/etc/etckeeper':
        ensure => directory,
        mode   => '0755',
        owner   => root,
        group   => root,
        before => File['etc/etckeeper/etckeeper.conf']
    }

    file{ 'etc/etckeeper/etckeeper.conf':
        ensure  => present,
        path    => '/etc/etckeeper/etckeeper.conf',
        owner   => root,
        group   => root,
        mode    => '0644',
        content => template('setup_system/etc/etckeeper/etckeeper.conf.erb'),
    }

    exec{ 'setup etckeeper':
        refreshonly  => true,
        command      => "etckeeper init",
        require => [Package['etckeeper'], File['etc/etckeeper/etckeeper.conf']],
    }
}