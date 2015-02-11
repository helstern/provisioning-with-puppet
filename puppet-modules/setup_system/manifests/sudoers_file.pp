define setup_system::sudoers_file(
    $filename   = $title,
    $source     = undef
) {
    if ( $source == undef) {
        fail('source is required')
    }

    file { "/tmp/$filename":
        source  => $source
    }

    exec { "visudo lint $filename" :
        command => "visudo -c -f /tmp/$filename",
        require => File["/tmp/$filename"]
    }

    file { "/etc/sudoers.d/$filename":
        owner   => root,
        group   => root,
        mode    => 440,
        source  => "/tmp/$filename",
        require => [
            Exec["visudo lint $filename"]
        ]
    }
}