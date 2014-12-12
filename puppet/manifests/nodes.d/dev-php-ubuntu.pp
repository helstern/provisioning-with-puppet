node 'dev-php' {

    # setting default path for executable resources
    Exec {
        path => ["/usr/bin", "/bin", "/usr/sbin", "/sbin", "/usr/local/bin", "/usr/local/sbin"]
    }

    include apt

    # configure some common low level settings
    include setup_system
    include setup_ssh_access
    include setup_network
    include setup_environment

    include apache
    include setup_java
    include setup_mysql

    include php
    include php::phpmyadmin
    include php::phpcomposer

    include setup_javascript

}