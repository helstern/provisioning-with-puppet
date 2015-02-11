class chruby
{
  $ruby = hiera('ruby')
  $version = $ruby['postmodern']['chruby']['version']
  $install_scope = $ruby['postmodern']['chruby']['scope']

  chruby::install-postmodern { "$version" :
    install_scope => $install_scope
  }
}