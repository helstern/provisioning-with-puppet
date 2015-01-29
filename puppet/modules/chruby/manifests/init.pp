class chruby
{
  $ruby = hiera('ruby')
  $version = $ruby['postmodern']['chruby']['version']
  $scope = $ruby['postmodern']['chruby']['version']

  chruby::install-postmodern { "$version" :
    scope => $scope
  }
}