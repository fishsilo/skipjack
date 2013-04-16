class truth::universal {
    File {
        owner => root,
        group => root
    }

    stage {
        "first": before => Stage['main'];
    }

    class { "package::refresh": stage => "first" }

    include puppet
    include daemontools
    include skipjack::refresh
}
