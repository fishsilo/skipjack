class haproxy::package {
    package {
        "haproxy-15":
            ensure => "latest";
    }
}

class haproxy {
    require haproxy::package
}
