class ruby-install
{
  $ruby = hiera('ruby')

  $version = $ruby['postmodern']['ruby-install']
  ruby_install::install-postmodern { $version :}

  $ruby_version = $ruby['version']

  exec { "install_ruby":
    require => Ruby_install::Install-postmodern[$version],
    command => "ruby-install ruby $ruby_version",
    creates => "/opt/rubies/ruby-$ruby_version"
  }
}