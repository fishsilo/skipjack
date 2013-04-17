class daemontools::package {
    package {
        "daemontools-run":
            require => Package["daemontools"],
            ensure => installed;
        "daemontools": ensure => installed;
    }
}

class daemontools {
    require daemontools::package
    require skipjack

    $service_base = "$skipjack::base/services"

    file {
        "$skipjack::base/services":
            ensure => directory,
            mode => 755,
            require => File["$skipjack::base"];
        "/etc/init/skipjack-svscan.conf":
            ensure => file,
            require => File["/usr/bin/svscan.skipjack"],
            source => "puppet:///modules/daemontools/skipjack-svscan.upstart.conf";
        "/usr/bin/svscan.skipjack":
            ensure => file,
            content => template("daemontools/svscan.skipjack.erb"),
            mode => 755,
            require => Package["daemontools-run"];
    }

    service {
        "skipjack-svscan":
            require => File["/etc/init/skipjack-svscan.conf"],
            provider => upstart,
            ensure => running,
            enable => true;
    }

}
        

define daemontools::service ($runfile, $ensure="present")  {
    require daemontools

    $service_base = "$daemontools::service_base"

    if $ensure == "present" {
        file {
            "$service_base/$name":
                ensure => directory,
                mode => 755,
                require => File["$service_base"];
            "$service_base/$name/run":
                ensure => file,
                mode => 755,
                notify => Exec["daemontools::service restart $name"],
                require => File["$service_base/$name/log/run"],
                source => $runfile;
            "$service_base/$name/log":
                ensure => directory,
                mode => 755,
                require => File["$service_base/$name"];
            "$service_base/$name/log/run":
                ensure => file,
                mode => 755,
                require => File["$service_base/$name/log/main"],
                source => "puppet:///modules/daemontools/log.run";
            "$service_base/$name/log/main":
                ensure => directory,
                mode => 755,
                require => File["$service_base/$name/log"];
        }

        exec {
            "daemontools::service restart $name":
                command => "/usr/bin/svc -t $service_base/$name",
                require => Package["daemontools"],
                refreshonly => true;
        }
    } else {
        exec {
            "daemontools::service kill $name":
                command => "/usr/bin/svc -dx $service_base/$name",
                require => Package["daemontools"],
                onlyif => "/usr/bin/svok $service_base/$name";
            "daemontools::service purge $name":
                command => "/bin/rm -r -f $service_base/$name",
                require => [Package["daemontools"],Exec["daemontools::service kill $name"]],
                onlyif => "[ -d '$service_base/$name' ]";
        }
    }
}
        


    
