class package::refresh {
    case $operatingsystem {
        'ubuntu': { include package::refresh::ubuntu }
    }
}
