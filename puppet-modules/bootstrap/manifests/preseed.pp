class bootstrap::preseed
{
  # location on the file system where preseed file are located
  $dir = '/var/local/preseed/'

  #create the directory where the preseed files are located
  exec { "create $dir":
    command => "mkdir --parents $bootstrap::preseed::dir",
    creates => [$bootstrap::preseed::dir]
  }
}
