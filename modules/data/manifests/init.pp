class data {

  $root = "/srv"

  file {
    $root:
      ensure => "directory",
      mode => "0755";
  }

}
