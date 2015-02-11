class apt {

    our_package::package {'apt::apt-file':
        package          => 'apt-file',
        declare_once    => true,
        ensure          => 'present'
    }

    our_package::package {'apt::python-software-properties':
        package          => 'python-software-properties',
        declare_once    => true,
        ensure          => 'present'
    }

}

