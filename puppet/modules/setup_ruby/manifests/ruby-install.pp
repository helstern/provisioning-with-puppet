class setup_ruby::ruby-install
{
  $ruby = hiera('ruby')

  $version = $ruby['postmodern']['ruby-install']
  ruby-install::install-postmodern { "$version" :}

  $ruby_version = $ruby['version']
  exec { "install_ruby":
    require => Ruby-install::Install-postmodern[$version],
    command => "ruby-install ruby $ruby_version",
    creates => "/opt/rubies/ruby-$ruby_version"
  }
}