class setup_environment
{
    $userEnvironmentConfig = fileserve('puppet:///common/user-environment')
    $resourceConfigsHash   = environment_parse_configuration($userEnvironmentConfig)
    $resourceDefaultsHash  = {}

    create_resources(setup_environment::vcs_environment, $resourceConfigsHash, $resourceDefaultsHash)
}
