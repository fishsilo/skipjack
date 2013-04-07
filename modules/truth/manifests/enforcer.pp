class truth::enforcer {
    require truth::universal

    # Now conditionally include things based on properties and facts
    if has_role("loadbalancer") {
        include haproxy
        notice("I am a loadbalancer")
    }

}
