class gitblit ($users_file, $prop_file) {

  include data

  $root = "/opt/gitblit/1.2.1"
  $runfile = "$root/runfile.sh"
  $data = "$data::root/gitblit"
  $user = "gitblit"
  $group = "gitblit"
 
  package {
    "gitblit":
      ensure => "latest";
  }

  user {
    $user:
      ensure => "present",
      system => "true",
      home => $data,
      group => $group,
      require => Group[$group];
  }

  group {
    $group:
      ensure => "present",
      system => "true";
  }

  file {
    $data:
      ensure => "directory",
      owner => $user,
      group => $user,
      mode => "0755",
      require => [File[$data::root], User[$user], Group[$group]];
    "$data/users.conf":
      ensure => "file",
      source => $users_file,
      owner => $user,
      group => $user,
      mode => "0600",
      require => [File[$data], User[$user], Group[$group]];
    "$data/gitblit.properties":
      ensure => "file",
      source => $prop_file,
      mode => "0644",
      require => File[$data];
    $runfile:
      ensure => "file",
      mode => "0755",
      require => Package["gitblit"];
  }

  daemontools::service {
    "gitblit":
      runfile => $runfile,
      ensure => "present",
      require => [
        File["$data/users.conf", "$data/gitblit.properties", $runfile],
        Package["gitblit"]];
  }

}
