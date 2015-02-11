class php::phpmyadmin
{
  include bootstrap::preseed

  $responseFile = 'phpmyadmin.seed'

  # copy the response file
  bootstrap::preseedFile { $responseFile:
    source => 'puppet:///modules/php/phpmyadmin.seed'
  }

  # install the package
  package { 'phpmyadmin':
    ensure => present,
    responsefile => "$bootstrap::preseed::dir$responseFile",
    require => [
      Bootstrap::PreseedFile[$responseFile],
      Package['php5', 'php5-mysql', 'apache2']
    ],
  }

  $phpmyadminApacheConf = '/etc/phpmyadmin/apache.conf'
  # create the available phpmyadmin site by creating a link to available and enabled site
  apache::site_conf { $phpmyadminApacheConf:
    site_name => "phpmyadmin",
    require => Package['phpmyadmin']
  }

}
