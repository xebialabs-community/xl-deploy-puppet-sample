# == Class: baseconfig
#
# Performs initial configuration tasks for all Vagrant boxes.
#


class baseconfig {
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  exec { "apt-get update":
    command => "/usr/bin/apt-get update",
    #onlyif => "/bin/sh -c '[ ! -f /var/cache/apt/pkgcache.bin ] || /usr/bin/find /etc/apt/* -cnewer /var/cache/apt/pkgcache.bin | /bin/grep . > /dev/null'",
  }

  host {
    'hostmachine':
      ip => '192.168.0.1';

    'tomcat1':
      ip => '192.168.0.42';

    'tomcat2':
      ip => '192.168.0.43';

    'tomcat3':
      ip => '192.168.0.44';

    'db':
      ip => '192.168.0.44';
  }

}
