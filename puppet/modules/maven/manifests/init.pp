class maven {

  maven::install { "3.2.5" :
    destinationDir => '/usr/local/apache-maven'
  }

  envvars::system { 'M2_HOME' :
    value   => '/usr/local/apache-maven/apache-maven-3.2.5',
    isPath  => false,
    require => Maven::Install['3.2.5']
  }

  envvars::system { 'M2' :
    value   => '$M2_HOME/bin',
    isPath  => true,
    require => Maven::Install['3.2.5']
  }
}