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

  deployit_container { "Infrastructure/$environment/$hostname/appserver-$hostname":
    type     	=> 'tomcat.Server',
    properties	=> {
      stopCommand 	=> '/etc/init.d/tomcat-appserver stop',
      startCommand 	=> 'nohup /etc/init.d/tomcat-appserver start',
      home 			    => '/srv/tomcat/appserver',
      stopWaitTime	=> 0,
      startWaitTime => 10,
    },
    server   	=> Deployit["xld-server"],
    require 	=> Deployit_container["Infrastructure/$environment/$hostname"],
    environments => "Environments/$environment/demo",
  }

  deployit_container { "Infrastructure/$environment/$hostname/appserver-$hostname/$hostname.vh":
    type     	=> 'tomcat.VirtualHost',
    properties	=> { },
    server   	=> Deployit["xld-server"],
    require 	=> Deployit_container["Infrastructure/$environment/$hostname/appserver-$hostname"],
    environments => "Environments/$environment/demo",
  }

  deployit_container { "Infrastructure/$environment/$hostname/test-runner-$hostname":
    type     	=> 'tests2.TestRunner',
    properties	=> { },
    server   	=> Deployit["xld-server"],
    require 	=> [Deployit_container["Infrastructure/$environment/$hostname"],Deployit_container["Infrastructure/$environment/$hostname/appserver-$hostname/$hostname.vh"]],
    environments => "Environments/$environment/demo",
  }

  deployit_dictionary { "Environments/$environment/$hostname.dict":
    entries                                                 => {
      "log.RootLevel"                                       => "ERROR",
      "log.FilePath"                                        => "/tmp/null",
      "tomcat.port"                                         =>  hiera('tomcat.port.http'),
      "tests2.ExecutedHttpRequestTest.url"                  => "http://localhost:{{tomcat.port}}/petclinic/index.jsp",
      "tomcat.DataSource.username"                          => "scott",
      "tomcat.DataSource.password"                          => "tiger",
      "TITLE"                                               => "Demo $environment",
      "tomcat.DataSource.driverClassName"                   => "com.mysql.jdbc.Driver",
      "tomcat.DataSource.url"                               => "jdbc:mysql://localhost/{{tomcat.DataSource.context}}",
      "tomcat.DataSource.context"                           => "petclinic",
      "tests2.ExecutedHttpRequestTest.expectedResponseText" => "Home",
    },
    restrict_to_containers => ["Infrastructure/$environment/$hostname/appserver-$hostname/$hostname.vh", "Infrastructure/$environment/$hostname/test-runner-$hostname", "Infrastructure/$environment/$hostname/appserver-$hostname"],
    environments         => "Environments/$environment/demo",
    server   	           => Deployit["xld-server"],
    require              => Deployit_container["Infrastructure/$environment/$hostname/test-runner-$hostname"]
  }

}
