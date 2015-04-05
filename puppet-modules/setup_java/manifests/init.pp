class setup_java
{
    include bootstrap::preseed

    # retrieve parameters
    $java = hiera('java')
    $javaVersion = $java['version']
    $javaPackage = $java['package']


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
#        include_src => true
    }

    bootstrap::preseed_file { $responseFile:
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
        Bootstrap::Preseed_file[$responseFile]
      ],
    }

    envvars::system { 'JAVA_HOME' :
      dynamicValue => "readlink --canonicalize-existing $(which javac) | sed 's:/bin/javac::'",
      isPath  => false,
      require => [
        Apt::Ppa_repository['webupd8team/java'],
        Package[$packageName]
      ]
    }
}
