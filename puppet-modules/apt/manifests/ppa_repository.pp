define apt::ppa_repository(
    $repository_name = $title,
    $refresh = false
){

    $repo_name_canonical = $repository_name ? {
        /^ppa:/        => $repository_name,
        default        => "ppa:$repository_name"
    }
    $repo_name_short = regsubst($repository_name, '^ppa:', '')

    exec { "$repo_name_canonical":
        command => "add-apt-repository --yes $repo_name_canonical",
        unless  => "find /etc/apt -name *.list -type f -print0 | xargs -0 grep -i -h $repo_name_short",
        require => Package['python-software-properties']
    }

    if ($refresh) {
        exec { "apt-get update $repo_name_canonical":
            command => 'apt-get update || true',
            require => Exec["$repo_name_canonical"]
        }
    }

}