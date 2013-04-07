class truth::universal {
    stage {
        "first": before => Stage['main'];
    }

    class { "package::refresh": stage => "first" }

    include puppet
}
