class package::refresh {
    case $operatingsystem {
        'ubuntu': { include package::refresh::ubuntu }
    }

    file {
        "/usr/local/bin/s3fs.skipjack.sh":
            ensure => file,
            mode => 755,
            source => "puppet:///modules/package/refresh/s3fs.sh";
        "/mnt/s3fs":
            ensure => directory;
    }

    exec {
        "S3FS":
            command => "/usr/local/bin/s3fs.skipjack.sh",
            require => File["/usr/local/bin/s3fs.skipjack.sh", "/mnt/s3fs"];
    }
}
