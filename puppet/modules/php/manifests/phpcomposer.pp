class php::phpcomposer
{
  $installLocation = '/usr/local/bin'

  exec { 'download composer':
    command => 'wget --no-verbose -O /tmp/installer https://getcomposer.org/installer',
    require => Package['php5-cli'],
    notify => Exec['install composer'],
    unless => 'test -f /usr/local/bin/composer.phar && /usr/local/bin/composer.phar >/dev/null 2>&1'
  }

  exec { 'install composer':
    command => "sudo php /tmp/installer --install-dir $installLocation",
    onlyif => 'sudo php /tmp/installer --check',
    refreshonly  => true,
    require => Exec['download composer']
  }

  exec { 'set permissions composer':
    command => 'sudo chmod ugo+x /usr/local/bin/composer.phar',
    refreshonly  => true,
    require => Exec['install composer']
  }
}
