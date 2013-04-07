class package::refresh::ubuntu {
    Class["package::refresh::apt"] -> Class["package::refresh::ubuntu"]
}
