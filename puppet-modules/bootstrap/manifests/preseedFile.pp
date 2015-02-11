#this type allows definition of debconf answer files
define bootstrap::preseedFile (
  $file = $title,
  $content = undef,
  $source = undef
) {

  include bootstrap::preseed

  if $source != undef and $content != undef {
    fail('Can not specify both content and source for a boostrap::preseedFile')
  }

  if $source == undef and $content == undef {
    $content = ''
  }

  file { "$bootstrap::preseed::dir$file":
    ensure  => file,
    mode => 664,
    backup => false,
    require => Exec["create $bootstrap::preseed::dir"]
  }

  if $content != undef {
    File["$bootstrap::preseed::dir$file"] {
      content => $content,
    }
  } elsif $source != undef {
    File["$bootstrap::preseed::dir$file"] {
      source => $source,
    }
  }

}
