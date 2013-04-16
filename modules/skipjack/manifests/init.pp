class skipjack {
    $base = "/skipjack"

    file {
        "$base":
            ensure => directory,
            mode => 755;
    }

    daemontools::service {
        "skipjack":
            runfile => "puppet:///modules/skipjack/services/skipjack";
    }
}
        
