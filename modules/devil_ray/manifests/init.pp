class devil_ray ($key_id, $key_file) {

  $root = "/opt/devil_ray"
  $key = "$root/s3.priv"
  $conf = "$root/s3.yaml"
  $executable = "$root/devil_ray.sh"
  $upstart = "/etc/init/devil_ray.conf"

  exec {
    "devil_ray_clone":
      command => "/usr/bin/git clone git://github.com/fishsilo/devil_ray.git $root",
      creates => "$root";
    "devil_ray_pull":
      cwd => "$root",
      command => "/usr/bin/git pull",
      require => Exec["devil_ray_clone"];
  }

  file {
    $upstart:
      ensure => "file",
      content => template("devil_ray/devil_ray.conf"),
      mode => "644",
      require => Exec["devil_ray_pull"];
    $key:
      ensure => "file",
      source => $key_file,
      mode => "600",
      require => Exec["devil_ray_pull"];
    $conf:
      ensure => "file",
      content => template("devil_ray/config.erb"),
      mode => "644",
      require => Exec["devil_ray_pull"];
    $executable:
      ensure => "file",
      source => "puppet:///modules/devil_ray/devil_ray.sh",
      mode => "0755",
      require => Exec["devil_ray_pull"];
  }

  service {
    "devil_ray":
      subscribe => File[$upstart, $key, $conf, $executable],
      ensure => "running",
      enable => true;
  }

}
