class package::refresh::ubuntu {
    require => Class["package::refresh::apt"]
}
