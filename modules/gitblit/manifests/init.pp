class gitblit ($users_file) {

  $root = "/opt/gitblit/1.2.1"
  $runfile = "$root/runfile.sh"
  $data = "/srv/gitblit"
 
  package {
    "gitblit":
      ensure => "latest";
  }

  file {
    "users":
      path => "$data/users.conf",
      ensure => "file",
      source => $users_file,
      require => Package["gitblit"];
    "runfile":
      path => $runfile,
      ensure => "file",
      mode => "0755",
      require => Package["gitblit"];
  }

  daemontools::service {
    "gitblit":
      runfile => $runfile,
      ensure => "present",
      require => [File["users", "runfile"], Package["gitblit"]];
  }

}
