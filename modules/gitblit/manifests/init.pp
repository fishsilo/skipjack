class gitblit ($users_file) {

  $version = "1.2.1"
  $root = "/opt/gitblit/$version"
  $runfile = "$root/runfile.sh"
  
  package {
    "gitblit":
      ensure => $version;
  }

  file {
    "users":
      path => "$root/data/users.conf",
      ensure => "file",
      source => $users_file,
      require => Package["gitblit"];
    "runfile":
      path => $runfile,
      ensure => "file",
      content => template("gitblit/runfile.sh"),
      require => Package["gitblit"];
  }

  daemontools::service {
    "gitblit":
      runfile => $runfile,
      ensure => "present",
      require => File["users"];
  }

}
