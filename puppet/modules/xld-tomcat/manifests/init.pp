# == Class: baseconfig
#
# Install Tomcat instance and declare it in XLD
#


class xld-tomcat {

  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  class {'java':
    distribution 	  => 'jdk',
    version       	=> 'latest',
  }
  #sources_src => 'http://10.0.2.2:3000/dist'
  class { 'tomcat':
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

  deployit_directory { 'Infrastructure/puppet':
    server   	  => Deployit["xld-tomcat"],
  }
  deployit_directory { 'Environments/Puppet':
    server   	  => Deployit["xld-tomcat"],
    require    => Deployit_directory["Infrastructure/puppet"]
  }

  deployit_container { "Infrastructure/puppet/$hostname":
    type     	  => "overthere.SshHost",
    properties	=> {
      os      => UNIX,
      address => $ipaddress_eth1,
      username  => vagrant,
      password => vagrant,
      connectionType => INTERACTIVE_SUDO,
      sudoUsername => root,
    },
    server   	 => Deployit["xld-tomcat"],
    require    => Deployit_directory["Infrastructure/puppet"]
  }
  deployit_container { "Infrastructure/puppet/$hostname/appserver-$hostname":
    type     	=> 'tomcat.Server',
    properties	=> {
      stopCommand 	=> '/etc/init.d/tomcat-appserver stop',
      startCommand 	=> 'nohup /etc/init.d/tomcat-appserver start',
      home 			    => '/srv/tomcat/appserver',
      stopWaitTime	=> 0,
      startWaitTime => 10,
    },
    server   	=> Deployit["xld-tomcat"],
    require 	=> Deployit_container["Infrastructure/puppet/$hostname"],
    environments => "Environments/Puppet/demo",
  }

  deployit_container { "Infrastructure/puppet/$hostname/appserver-$hostname/$hostname.vh":
    type     	=> 'tomcat.VirtualHost',
    properties	=> { },
    server   	=> Deployit["xld-tomcat"],
    require 	=> Deployit_container["Infrastructure/puppet/$hostname/appserver-$hostname"],
    environments => "Environments/Puppet/demo",
  }

  deployit_container { "Infrastructure/puppet/$hostname/test-runner-$hostname":
    type     	=> 'tests2.TestRunner',
    properties	=> { },
    server   	=> Deployit["xld-tomcat"],
    require 	=> [Deployit_container["Infrastructure/puppet/$hostname"],Deployit_container["Infrastructure/puppet/$hostname/appserver-$hostname/$hostname.vh"]],
    environments => "Environments/Puppet/demo",
  }

  deployit_dictionary { "Environments/Puppet/$hostname.dict":
    entries                                                 => {
      "log.RootLevel"                                       => "ERROR",
      "log.FilePath"                                        => "/tmp/null",
      "tomcat.port"                                         =>  hiera('tomcat.port.http'),
      "tests2.ExecutedHttpRequestTest.url"                  => "http://localhost:{{tomcat.port}}/petclinic/index.jsp",
      "tomcat.DataSource.username"                          => "scott",
      "tomcat.DataSource.password"                          => "tiger",
      "TITLE"                                               => "Demo Puppet",
      "tomcat.DataSource.driverClassName"                   => "com.mysql.jdbc.Driver",
      "tomcat.DataSource.url"                               => "jdbc:mysql://localhost/{{tomcat.DataSource.context}}",
      "tomcat.DataSource.context"                           => "petclinic",
      "tests2.ExecutedHttpRequestTest.expectedResponseText" => "Home",
    },
    restrict_to_containers => ["Infrastructure/puppet/$hostname/appserver-$hostname/$hostname.vh", "Infrastructure/puppet/$hostname/test-runner-$hostname", "Infrastructure/puppet/$hostname/appserver-$hostname"],
    environments         => "Environments/Puppet/demo",
    server   	           => Deployit["xld-tomcat"],
    require              => Deployit_container["Infrastructure/puppet/$hostname/test-runner-$hostname"]
  }

}
