class skipjack {
    $base = "/skipjack"

    file {
        "$base":
            ensure => directory,
            mode => 755;
    }
}

class skipjack::refresh {
    require skipjack
    daemontools::service {
        "skipjack":
            runfile => "puppet:///modules/skipjack/services/skipjack";
    }
}
        
