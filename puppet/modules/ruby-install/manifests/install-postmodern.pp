define ruby-install::install-postmodern (
  $version = $title
) {

  if ($version == undef) {
    fail('version parameter must be set')
  }

  # copy archive from fileserver
  $source_archive = "/tmp/ruby-install-$version.tar.gz"
  file { "$source_archive":
    source => "puppet:///ruby-install/v$version.tar.gz",
    backup => false
  }

  # copy the installer
  file { '/tmp/install_ruby-install.sh':
    ensure  => present,
    source  => "puppet:///modules/ruby-install/installer-postmodern.sh",
  }

  exec { "install_ruby-install":
    command => "bash /tmp/install_ruby-install.sh $version $source_archive",
    creates => '/usr/bin/ruby-install',
    require => [File['/tmp/install_ruby-install.sh'], File["$source_archive"]]
  }
}