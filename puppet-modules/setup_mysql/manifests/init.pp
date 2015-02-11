class setup_mysql
{
  $mysql = hiera('mysql')

  # server
  class { '::mysql::server':
    # package
    package_ensure   => present,

    # service
    service_manage   => true,
    service_enabled  => true,
    restart => true,

    # configuration
    root_password    => $mysql['root_password'],
    override_options => {
      'mysqld' => {
        'max_connections' => '1024'
        }
    }
  }

  class { '::mysql::client':
    #package
    package_ensure => true,
    #bindings
    bindings_enable => true,
  }

  # backup
  # will create a file '/usr/local/sbin/mysqlbackup.sh' and register it for execution with cron
  class { '::mysql::server::backup':
    #package
    ensure   => present,
    #user
    backupuser => "backup",
    backuppassword => "backup",
    #location
    backupdir => '/var/backups/mysql',
    #style
    backupcompress => true,
    backuprotate => 2,
    file_per_database => true,
    #cron
    time => ['20', '5'],
    require => Class['::mysql::server'],
  }
}

