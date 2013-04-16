class skipjack {
    $base = "/skipjack"

    file {
        "$base":
            ensure => directory,
            mode => 755;
    }
}
        
