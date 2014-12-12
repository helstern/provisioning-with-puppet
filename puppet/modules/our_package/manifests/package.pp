# declares the resource only once
define our_package::package (
    $package        = $title,
    $declare_once   = true,
    $ensure         = 'present'
){
    if true == $declare_once and false == defined(Package[$package]) {
        package{ $package:
            ensure => $ensure
        }
    }

    if false == $declare_once {
        package{ $package:
            ensure => $ensure
        }
    }

}