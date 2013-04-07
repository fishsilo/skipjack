class puppet {
    group {
        "puppet":
            ensure => present,
            system => true;
    }
}
