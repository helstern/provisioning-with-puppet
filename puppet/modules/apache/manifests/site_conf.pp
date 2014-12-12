define apache::site_conf (
  $conf_file = $title,
  $site_name = undef
) {

  file { "/etc/apache2/sites-available/$site_name" :
    ensure => link,
    target => $conf_file,
    require => Package['apache2'],
  }

  file { "/etc/apache2/sites-enabled/$site_name" :
    ensure => link,
    target => "/etc/apache2/sites-available/$site_name",
    require => [
      File["/etc/apache2/sites-available/$site_name"],
      Package['apache2']
    ],
    notify => Service['apache2']
  }

}
