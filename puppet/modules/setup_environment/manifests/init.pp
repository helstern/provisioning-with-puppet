class setup_environment
{
    $userEnvironmentConfig = hiera('user_environment')

    $resourceConfigsHash   = environment_parse_configuration($userEnvironmentConfig)
    $resourceDefaultsHash  = {}

    create_resources(setup_environment::vcs_environment, $resourceConfigsHash, $resourceDefaultsHash)
}
