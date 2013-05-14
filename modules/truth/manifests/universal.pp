class truth::universal {
    File {
        owner => root,
        group => root
    }

    stage {
        "first": before => Stage['main'];
    }

    class {
        "devil_ray":
            stage => "first";
        "package::refresh":
            stage => "first",
            require => Class["devil_ray"]
    }

    include puppet
    include daemontools
    include skipjack::refresh
}
