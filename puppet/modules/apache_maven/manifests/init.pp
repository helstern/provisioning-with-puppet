class apache_maven {

  user { 'apache-maven':
    ensure => present,
    comment => 'apache-maven user',
    managehome => true
  }

  $destinationDir = '/usr/local/apache-maven'
  file {$destinationDir:
    ensure => directory,
    require => User['apache-maven']
  }

  apache_maven::install { "3.2.5" :
    destinationDir => $destinationDir,
    require => File[$destinationDir]
  }

  envvars::system { 'M2_HOME' :
    staticValue   => '/usr/local/apache-maven/apache-maven-3.2.5',
    isPath  => false,
    require => Apache_Maven::Install['3.2.5']
  }

  envvars::system { 'M2' :
    staticValue   => '$M2_HOME/bin',
    isPath  => true,
    require => Apache_Maven::Install['3.2.5']
  }
}