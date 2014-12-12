class setup_javascript::nodejs
{
  #params
  $architecture = 'x64'
  $platform     = 'linux'
  $version      = 'v0.10.24'

  #file name and file type based on params
  $fileType     = 'tar.gz'
  $fileName = "node-$version-$platform-$architecture.$fileType"

  #install location, known as node prefix
  $installLocation = '/usr/local'

  file { $installLocation:
    ensure => directory,
    owner => root,
    group => root
  }

  exec { 'download node':
    command => "sudo wget --no-verbose --quiet --output-document=/tmp/$fileName http://nodejs.org/dist/$version/$fileName",
    unless => "test ! -f $installLocation/$fileName",
    require => File[$installLocation]
  }

  #unpacking
  $unpackDir = "/tmp/node-$version-$platform-$architecture/"

  file { $unpackDir :
    ensure => directory,
  }

  exec { 'unpack node' :
    command => "sudo tar --extract --gzip --file /tmp/$fileName --strip-components 1 --directory $unpackDir",
    require => [File[$unpackDir], Exec['download node']]
  }

  #installing, moving to install location
  exec { 'installing node' :
    command => "sudo find $unpackDir -maxdepth 1 -type f | xargs sudo rm --force && sudo cp --recursive --no-clubber $unpackDir* $installLocation",
    require => Exec['unpack node']
  }

  exec { 'cleaning up':
    command => "sudo rm --recursive --force $unpackDir",
    require => Exec['installing node']
  }
}
