class devil_ray ($key_id, $key_file) {

  $root = "/opt/devil_ray"

  exec {
    "clone":
      command => "/usr/bin/git clone git://github.com/fishsilo/devil_ray.git $root",
      creates => "$root";
    "pull":
      cwd => "$root",
      command => "/usr/bin/git pull",
      require => Exec["clone"];
  }

  file {
    "service":
      ensure => "file",
      path => "/etc/init/devil_ray.conf",
      source => "puppet:///modules/devil_ray/devil_ray.conf",
      owner => "root",
      group => "root",
      mode => "644",
      require => Exec["pull"];
    "config":
      ensure => "file",
      path => "$root/s3.yaml",
      content => template("devil_ray/config.erb"),
      mode => "644",
      require => Exec["pull"];
  }

  service {
    "devil_ray":
      require => File["service", "config"],
      ensure => "running",
      enable => true
  }

}
