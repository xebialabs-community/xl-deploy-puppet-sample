# == Class: baseconfig
#
# Install JBossAS instance and declare it in XLD
#


class xld-tomcat {

  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  class {'java':
    distribution 	  => 'jdk',
    version       	=> '6',
  }

  #sources_src => 'http://10.0.2.2:3000/dist'
  class { 'jboss':
    version     => 7,
    sources     => true,
  }


  tomcat::instance {'appserver':
    ensure      => present,
    server_port => hiera('tomcat.port.mgt'),
    http_port   => hiera('tomcat.port.http'),
    ajp_port    => hiera('tomcat.port.ajp'),
  }

  deployit { "xld-tomcat":
    username             => "admin",
    password             => "admin",
    url                  => "http://10.0.2.2:4516",
    encrypted_dictionary => "Environments/Puppet/PuppetModuleDictionary"
  }
}
