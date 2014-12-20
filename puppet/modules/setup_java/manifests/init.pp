class setup_java inherits setup_java::params
{
    include bootstrap::preseed

    # obtain these via configuration
    $javaPackage = $setup_java::params::java_package
    $javaVersion = $setup_java::params::java_version

    # pick software source package
    if $javaPackage == "jdk" {
      $packageNameTpl = "oracle-jdk:version-installer"
    } elsif $javaPackage == "jre" {
      $packageNameTpl = "oracle-java:version-installer"
    } else {
      fail("Unspecified java package $javaPackage for version $javaVersion")
    }

    if $javaVersion !~ /^1\.(6|7|8)/ {
      fail("Unspecified java package $javaPackage for version $javaVersion")
    } else {
      $packageName = regsubst($packageNameTpl, ':version', $1)
    }

    # pick debconf responsefile
    if $javaVersion =~ /^1\.(6|7|8)/ {
        $enquiringPackage = regsubst('oracle-java:version-installer', ':version', $1)
        $responseFile     = "java.install.seed"
    }

    # add java ppa
    apt::ppa_repository {'webupd8team/java':
        refresh => true,
        include_src => true
    }

    bootstrap::preseedFile { $responseFile:
      source => 'puppet:///modules/setup_java/java.install.seed',
      require => [
        Apt::Ppa_repository['webupd8team/java']
      ]
    }

    package { $packageName:
      ensure => present,
      responsefile => "$bootstrap::preseed::dir$responseFile",
      require => [
        Apt::Ppa_repository['webupd8team/java'],
        Bootstrap::PreseedFile[$responseFile]
      ],
    }
}
