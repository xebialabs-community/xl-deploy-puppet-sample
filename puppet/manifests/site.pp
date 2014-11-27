node 'tomcat1','tomcat2' {
  $environment = "Production"
  include xld-base
  include xld-tomcat
}

node 'tomcat3' {
  $environment = "Production"
  include xld-base
  include xld-tomcat
  #include xld-app
}

node 'jbossdev' {
  $environment = "Development"
  include xld-base
  include xld-jbossas
  include xld-mysql
}

node 'jbossqa' {
  $environment = "QA"
  include xld-base
  include xld-jbossas
}

node 'jbossprod1','jbossprod2' {
  $environment = "Production"
  include xld-base
  include xld-jbossas
}

node 'dbqa' {
  $environment = "QA"
  include xld-base
  include xld-mysql
}

node 'dbprod' {
  $environment = "Production"
  include xld-base
  include xld-mysql
}


node 'base-java' {

  exec { "apt-update":
    command => "/usr/bin/apt-get update"
  }

  Exec["apt-update"] -> Package <| |>

  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  package { ['liblog4j1.2-java', 'libcommons-logging-java']:
    ensure => present,
  }
  package { ['linux-headers-generic','build-essential','dkms']:
    ensure => present,
  }

  include java
}

node 'base-mysql' {

# add the baseconfig module to the new 'pre' run stage
# set defaults for file ownership/permissions
  File {
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }
  class { '::mysql::server':
    root_password   => 'deployitpassword',
  }
  package { "mysql-client": }
#package {"linux-headers-generic":}
#package {"build-essential":}
#package {"dkms":}
}



