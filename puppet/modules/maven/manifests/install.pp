define maven::install(
  $version = $title,
  $destinationDir = '',
  $user = 'maven'
) {

  # We support only Debian and RedHat
  case $::osfamily {
    Debian  : { $supported = true }
    RedHat  : { $supported = true }
    default : { fail("The ${module_name} module is not supported on ${::osfamily} based systems") }
  }

  if ($version == undef) {
    fail('version parameter must be set')
  }

  $filename = "apache-maven-$version-bin.tar.gz"
  $file = "/tmp/apache-maven-$version-bin.tar.gz"

  # working directory to untar maven
    file { "remove-$file":
      path => "$file",
      ensure => 'absent'
    }

    file { "$file":
      source => "puppet:///maven/$filename",
      require => File["remove-$file"],
    }

    exec { "extract-${filename}":
      cwd     => "$destinationDir",
      command => "tar -xzf ${file}",
      require => File["$file"],
    }

    file { "$destinationDir/apache-maven-$version"
      ensure  => 'directory',
      recurse => true,
      user    => $user,
      group   => $user,
      require => File["extract-${filename}"],
    }
}