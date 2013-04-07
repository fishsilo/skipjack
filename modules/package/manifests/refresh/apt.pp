class package::refresh::apt {
    exec {
        "apt-get update":
            command => "/usr/bin/apt-get update";
    }
}
