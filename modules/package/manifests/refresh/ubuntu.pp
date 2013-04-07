class package::refresh::ubuntu {
    include package::refresh::apt
    Class["package::refresh::apt"] -> Class["package::refresh::ubuntu"]
}
