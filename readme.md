automation
==========

infrastructure management, puppet, ansible

requires vagrant 1.6.3, which must be clean install, so rremove old version first if it exists

manifests written for puppet 2.7

environments
==========
they are ordered from strongest to weakest, everything can override production

personal environment never leaves the computer, whereas development may be checked-in to git

development environment should be used to create personal environments

    01-personal
    02-development
    03-staging
    04-production
    
