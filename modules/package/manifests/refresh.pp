class package::refresh {
    stage => "first"
    case $operatingsystem {
        'ubuntu': { include package::refresh::ubuntu }
    }
}
