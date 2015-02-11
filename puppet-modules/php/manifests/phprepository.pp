define php::phprepository(
    $phpversion = undef,
    $source      = undef
){
    case $phpversion {
        "5.4": { #php 5.4 is not added by default on ubuntu precise, so add https://launchpad.net/~ondrej/+archive/php5-oldstable
            apt::ppa_repository {$source:
                refresh => true
            }
        }
        default: {
                #use the default ubuntu precise repository php version, 5.3
        }
    }
}

