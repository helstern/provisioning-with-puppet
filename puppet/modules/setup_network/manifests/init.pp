
class setup_network {

  $network = hiera('network')
  $host_only = $network['host-only']
  #import local variable used by network/interface template
    $eth1 = {
        'gateway'     => $host_only['gateway'],
        'netmask'     => $host_only['netmask'],
        'dns_servers' => $host_only['dns_servers'],
        'address'     => $host_only['ip'],
        'network'     => extract_network_address($host_only['gateway'], $host_only['netmask'])
    }

    file { "/etc/network/interfaces.d/010-eth0.conf" :
        ensure  => 'file',
        owner   => 'root',
        group   => 'root',
        mode    => '644',

        replace => yes,
        content => template('setup_network/010-eth0.conf.erb'),
        backup  => '.puppet.bak',

        notify => Exec['restart networking service']
    }


    file { "/etc/network/interfaces.d/015-eth1.conf" :
        ensure  => 'file',
        owner   => 'root',
        group   => 'root',
        mode    => '644',

        replace => yes,
        content => template('setup_network/015-eth1.conf.erb'),
        backup  => '.puppet.bak',

        notify => Exec['restart networking service']
    }

    file { "/etc/network/interfaces.d/015-eth2.conf" :
        ensure  => 'file',
        owner   => 'root',
        group   => 'root',
        mode    => '644',

        replace => yes,
        content => template('setup_network/015-eth2.conf.erb'),
        backup  => '.puppet.bak',

        notify => Exec['restart networking service']
    }

  exec { 'restart networking service' :
    refreshonly  => true,
    command => '/etc/init.d/networking restart',
  }
}
