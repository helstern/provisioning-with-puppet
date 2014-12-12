class setup_system::utilities (
    $operatingsystem = $::operatingsystem
) {
    $packages = hiera('utilities')
    $resource_hash = create_resources_hash('setup_system::utilities', $packages, 'package')

    $resource_defaults = {
        declare_once => true,
        ensure       => "present"
    }
    create_resources(our_package::package, $resource_hash, $resource_defaults)
}
