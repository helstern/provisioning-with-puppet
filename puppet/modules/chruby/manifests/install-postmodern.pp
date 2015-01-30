define chruby::install-postmodern
(
  $version = $title,
  $scope = 'system'
) {

  if ($version == undef) {
    fail('version parameter must be set')
  }

  # copy archive from fileserver
  $source_archive = "/tmp/chruby-$version.tar.gz"
  file { "$source_archive":
    source => "puppet:///chruby/v$version.tar.gz",
    backup => false
  }

  # copy the installer
  file { '/tmp/install-chruby.sh':
    ensure  => present,
    source  => "puppet:///modules/chruby/install-postmodern.sh",
  }

  exec { "install-chruby":
    command => "bash /tmp/install_chruby.sh $version $source_archive",
    creates => '/usr/local/share/chruby/chruby.sh',
    require => [File['/tmp/install_ruby-install.sh'], File["$source_archive"]]
  }

  if ($scope == 'system') {
    file { "/etc/profile.d/chruby.sh":
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => 0755,
      source  => "puppet:///modules/chruby/etc/profile.d/chruby.sh",
      require => [
        Exec["install_chruby"],
      ],
    }
  }
}