class devil_ray {

  $root = "/opt/devil_ray"
  $config = "$root/s3.yaml"

  exec {
    "clone":
      command => "git clone git://github.com/fishsilo/devil_ray.git $root",
      creates => "$root";
    "pull":
      cwd => "$root",
      command => "git pull",
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
      path => "$config",
      ensure => "file";
  }

  service {
    "devil_ray":
      require => File["service", "$root/s3.yaml"],
      ensure => "running",
      enable => true
  }

}
