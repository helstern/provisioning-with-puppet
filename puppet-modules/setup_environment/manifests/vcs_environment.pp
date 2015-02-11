define setup_environment::vcs_environment($user, $vcsSource) {

    $knownHostsFilePath = "/home/$user/.ssh/known_hosts"
    file { $knownHostsFilePath :
        ensure   => present,
        owner => $user,
        mode => 0644,
        require => [Package['rsync'], Package['git']],
    }

    $addGithubToKnownHostsTitle = "add github ssh known host key for $user"
    exec { $addGithubToKnownHostsTitle :
        cwd     => "/home/$user",
        command => 'ssh-keyscan -t rsa -H github.com 2>&1 | cat .ssh/known_hosts - | tr "\n" "\v" | sort --unique - | tr "\v" "\n" > .ssh/known_hosts',
        require => File[$knownHostsFilePath],
    }

    $dotFilesRepoPath = "/tmp/vagrant-user-env/$user"
    vcsrepo { "clone $dotFilesRepoPath for $user":
        path => $dotFilesRepoPath,
        ensure   => present,
        provider => git,
        source   => $vcsSource,
        require => Exec[$addGithubToKnownHostsTitle],
    }

    $checkoutVCSBranchTitle = "checkout branch develop for $user"
    exec { $checkoutVCSBranchTitle :
        cwd     => $dotFilesRepoPath,
        command => "git checkout develop",
        require => Vcsrepo["clone $dotFilesRepoPath for $user"],
    }

    exec { "copy dot files for $user" :
        user    => $user,
        cwd     => $dotFilesRepo,
        command => "$dotFilesRepoPath/bin/setup-dot-files.sh --force",
        require => Exec[$checkoutVCSBranchTitle],
    }

}