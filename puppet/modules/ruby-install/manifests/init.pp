class ruby_install
{
  $ruby = hiera('ruby')
  $version = $ruby['postmodern']['ruby-install']

  ruby_install::install-postmodern { $version :}
}