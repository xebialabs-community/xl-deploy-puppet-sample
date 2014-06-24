node 'tomcat1','tomcat2' {
  include xld-base
  include xld-tomcat
}

node 'tomcat3' {
  include xld-base
  include xld-tomcat
  include xld-app
}

node 'jbossdev' {
  $environment = "Dev"
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
  # add the baseconfig module to the new 'pre' run stage
  # set defaults for file ownership/permissions
  File {
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  class { 'baseconfig':
    stage => 'pre'
  }

  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }
  include baseconfig
  include java
  package {"linux-headers-generic":}
  package {"build-essential":}
  package {"dkms":}
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
  package {"mysql-client": }
  #package {"linux-headers-generic":}
  #package {"build-essential":}
  #package {"dkms":}
  }



