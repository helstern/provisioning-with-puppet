class php::xdebugconf
{
  $xdebugConfName = 'xdebug-conf-override'

  if (defined(Service['apache2'])) {
    $notify  = [Service['apache2']]
  } else {
    $notify = []
  }

  file { "file:$xdebugConfName":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 664,
    path    => "/etc/php5/mods-available/$xdebugConfName.ini",
    source  => "puppet:///modules/php/$xdebugConfName.ini",
    notify => $notify
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
