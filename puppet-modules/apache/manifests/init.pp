# https://www.digitalocean.com/community/tutorials/how-to-configure-the-apache-web-server-on-an-ubuntu-or-debian-vps
class apache
{
    $apache = hiera('apache')

    package { "apache2":
            ensure  => present
    }

    service { "apache2":
            ensure      => running,
            enable      => true,
            require     => Package['apache2'],
            subscribe   => [
                File["/etc/apache2/mods-enabled/rewrite.load"],
                File["/etc/apache2/sites-available/default"]
            ],
    }

    # ensure mod rewrite is enabled
    file { "/etc/apache2/mods-enabled/rewrite.load":
            ensure  => link,
            target  => "/etc/apache2/mods-available/rewrite.load",
            require => Package['apache2'],
    }

    file { '/var/www/default':
        ensure => directory,
        recurse => true,
        group => $apache['group'],
        mode => 0775,
        require => Package['apache2'],
    }

    # add the available sites vhost configuration
    file { "/etc/apache2/sites-available/default":
            ensure  => present,
            source  => "puppet:///modules/apache/default-vhost",
            require => Package['apache2'],
    }

    # set the fully qualified name of the server
    $fqdn = $apache['fqdn']


    if ($operatingsystem =~ /(?i-mx:^ubuntu)/ and $operatingsystemrelease =~ /^14/) {
      $command = "echo 'ServerName $fqdn' | sudo tee /etc/apache2/conf-available/fqdn.conf ; a2enconf fqdn"
    } else {
      $command = "echo 'ServerName $fqdn' | sudo tee /etc/apache2/conf.d/fqdn"
    }

    exec { $command:
        require => [Package['apache2']]
    }

    #change the group ownership of apache's document root and it's contents, make sure group members can write
    file { $apache['document-root']:
            ensure => directory,
            recurse => true,
            group => $apache['group'],
            mode => 0775,
            require => Package['apache2'],
    }

    #create the apache data dir
    file { $apache['data-dir']:
            ensure => directory,
            owner  => root,
            group => $apache['group'],
            require => Package['apache2'],
    }

    #add users to the apache group
    if (size($apache['group-members']) > 0) {
        user {
            $apache['group-members']:
            groups => $apache['group'],
            require => Package['apache2'],
        }
    }
}
