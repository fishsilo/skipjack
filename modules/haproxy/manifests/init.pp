class haproxy::package {
    package {
        "haproxy-1.5":
            ensure => installed,
            name => "https://s3-us-west-2.amazonaws.com/com.fishsilo.skipjack/haproxy-15_1.5-dev18_i386.deb";
    }
}

class haproxy {
    require haproxy::package

}
    
