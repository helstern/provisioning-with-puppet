class php::xdebugconf
{
  $xdebugConfName = 'xdebug-conf-override'

  file { "file:$xdebugConfName":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 664,
    path    => "/etc/php5/mods-available/$xdebugConfName.ini",
    source  => "puppet:///modules/php/$xdebugConfName.ini",
    notify  => Service['apache2'],
  }

  exec { "exec:$xdebugConfName":
    command => "php5enmod $xdebugConfName",
    require => File["file:$xdebugConfName"],
  }

  $phpxdbg = 'phpxdbg'
  file { "file:$phpxdbg":
    owner   => root,
    group   => root,
    mode    => 0755,
    path    => "/usr/local/bin/$phpxdbg",
    source  => "puppet:///modules/php/$phpxdbg"
  }

}
