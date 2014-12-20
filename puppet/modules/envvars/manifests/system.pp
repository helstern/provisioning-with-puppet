define envvars::system(
  $varname  = $title,
  $value    = undef,
  $isPath   = false,
  $envFile = '/etc/profile.d/envvars.sh'
) {

  if ($value == undef) {
    fail('version parameter must be set')
  }

  file { "$envFile" :
    ensure  => 'present',
  }

  exec { "add system wide variable $varname":
    cwd     => '/',
    command => "echo 'export varname=${value}' >> ${envFile}",
    unless  => "grep 'export varname=${value}' ${envFile}"
  }

  if ($isPath) {
    exec { "add system wide path variable $varname":
      cwd     => '/',
      command => "echo 'export PATH=$PATH:$${varname}' >> ${envFile}",
      unless  => "grep 'export PATH=$PATH:$${varname}' ${envFile}"
    }
  }
}