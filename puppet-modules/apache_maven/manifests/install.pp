define apache_maven::install(
  $version = $title,
  $destinationDir = '',
  $user = 'apache-maven'
) {

  # Debian and RedHat
  case $::osfamily {
    Debian  : { $supportedOs = true }
    RedHat  : { $supportedOs = true }
    default : { $supportedOs = false }
  }

  if (! $supportedOs) {
    fail("The ${module_name} module is not supported on ${::osfamily} based systems")
  }

  if ($version == undef) {
    fail('version parameter must be set')
  }

  $filename = "apache-maven-$version-bin.tar.gz"
  $file = "/tmp/apache-maven-$version-bin.tar.gz"

  # copy archive from fileserver
    file { "$file":
      source => "puppet:///apache_maven/apache-maven-$version-bin.tar.gz",
      backup => false
    }

    # extact the archive
    exec { "extract-${filename}":
      cwd     => "$destinationDir",
      command => "tar -xzf ${file}",
      require => File["$file"],
    }

    # change permissions
    file { "$destinationDir/apache-maven-$version" :
      ensure  => 'directory',
      recurse => true,
      owner   => $user,
      require => Exec["extract-${filename}"],
    }
}