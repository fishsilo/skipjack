class os {
    case $operatingsystem {
        'ubuntu': { include os::ubuntu }
    }
}
