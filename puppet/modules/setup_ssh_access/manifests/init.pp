class setup_ssh_access {

    $accountKeys = hiera('authorized_keys')

    #  {
    #    unique name => {
    #      type,
    #      key,
    #      name
    #      user
    #    }
    #  }
    # must extract resourceHashes from parsing the list
    $resourceHashes = ssh_key_parse_account_keys($accountKeys)

    $defaults = {
        ensure => present
    }

    create_resources(ssh_authorized_key, $resourceHashes, $defaults)
}