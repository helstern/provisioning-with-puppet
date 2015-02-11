define envvars::system(
  $varname        = $title,
  $staticValue    = undef,
  $dynamicValue   = undef,
  $isPath   = false,
  $envFile = '/etc/profile.d/envvars.sh'
) {

  if $staticValue == undef and $dynamicValue == undef {
    fail("value must be set for $varname")
  }

  if $staticValue != undef and $dynamicValue != undef {
    fail("only one value must be set for $varname")
  }

  if (!defined(File[$envFile])) {
    file { "$envFile" :
      path    => $envFile,
      ensure  => 'present',
    }
  }

  if (!defined(File['/tmp/envvar.sh'])) {
    file { '/tmp/envvar.sh' :
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => 0777,
      source  => "puppet:///modules/envvars/envvar.sh",
    }
  }

  if (!defined(File['/tmp/pathvar.sh'])) {
    file { '/tmp/pathvar.sh' :
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => 0777,
      source  => "puppet:///modules/envvars/pathvar.sh",
    }
  }

  if ($staticValue != undef) {
    exec { "add system wide env variable $varname using static value":
      cwd     => '/tmp',
      command => "/tmp/envvar.sh '$envFile' '${varname}' '${staticValue}' ",
      require => [
        File[$envFile],
        File['/tmp/envvar.sh'],
      ],
      logoutput => true
    }
  }

  if ($dynamicValue != undef) {
    exec { "add system wide env variable $varname using dinamic value":
      cwd     => '/tmp',
      command => "${dynamicValue} | /tmp/envvar.sh '${envFile}' '${varname}' ",
      require => [
        File[$envFile],
        File['/tmp/envvar.sh'],
      ],
      logoutput => true
    }
  }

  if ($isPath) {
    exec { "add system wide path variable $varname":
      cwd     => '/',
      command => "/tmp/pathvar.sh '$envFile' '${varname}'",
      require => [
        File[$envFile],
        File['/tmp/pathvar.sh'],
      ],
      logoutput => true
    }
  }

#
#  exec { "add system wide variable $varname":
#    cwd     => '/',
#    command => "echo 'export ${varname}=${value}' >> ${envFile}",
#    unless  => "grep 'export ${varname}=${value}' ${envFile}",
#    require => File[$envFile]
#  }
#
#  if ($isPath) {
#    exec { "add system wide path variable $varname":
#      cwd     => '/',
#      command => "echo 'export PATH=\$PATH:\$${varname}' >> ${envFile}",
#      unless  => "grep 'export PATH=\$PATH:\$${varname}' ${envFile}",
#      require => File[$envFile]
#    }
#  }
}