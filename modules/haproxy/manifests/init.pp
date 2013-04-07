class haproxy::package {
    package {
        "haproxy-1.5": ensure => latest;
    }
}

class haproxy {
    require => Class["haproxy::package"]

}
    
