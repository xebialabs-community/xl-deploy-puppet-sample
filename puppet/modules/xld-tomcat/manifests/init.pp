# == Class: baseconfig
#
# Install Tomcat instance and declare it in XLD
#


class xld-tomcat ( $deployment_group)  {

  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  class { 'tomcat':
    version     => '7',
    sources     => true,
    sources_src => 'file:/catalog/Tomcat'
  }

  tomcat::instance { 'appserver':
    ensure      => present,
    server_port => hiera('tomcat.port.mgt'),
    http_port   => hiera('tomcat.port.http'),
    ajp_port    => hiera('tomcat.port.ajp'),
  }

  xldeploy_container { "Infrastructure/$environment/$fqdn/appserver-$hostname":
    type            => 'tomcat.Server',
    properties      => {
      stopCommand   => '/etc/init.d/tomcat-appserver stop',
      startCommand  => 'nohup /etc/init.d/tomcat-appserver start',
      home          => '/srv/tomcat/appserver',
      stopWaitTime  => 0,
      startWaitTime => 10,
      deploymentGroup => $deployment_group,
    },
    server          => Xldeploy["xld-server"],
    environments    => "Environments/$environment/App-$environment",
  }

  xldeploy_container { "Infrastructure/$environment/$fqdn/appserver-$hostname/$hostname.vh":
    type         => 'tomcat.VirtualHost',
    properties   => {
      deploymentGroup => $deployment_group,
    },
    server       => Xldeploy["xld-server"],
    environments => "Environments/$environment/App-$environment",
  }

  xldeploy_container { "Infrastructure/$environment/$fqdn/test-runner-$hostname":
    type         => 'tests2.TestRunner',
    properties   => {
      deploymentGroup => $deployment_group,
    },
    server       => Xldeploy["xld-server"],
    environments => "Environments/$environment/App-$environment",
  }

  xldeploy_dictionary { "Environments/$environment/$fqdn.dict":
    entries                                                 => {
      "log.RootLevel"                                       => "ERROR",
      "log.FilePath"                                        => "/tmp/null",
      "tomcat.port"                                         =>  hiera('tomcat.port.http'),
      "tests2.ExecutedHttpRequestTest.url"                  => "http://localhost:{{tomcat.port}}/petclinic/index.jsp",
      "tomcat.DataSource.username"                          => "scott",
      "tomcat.DataSource.password"                          => "tiger",
      "TITLE"                                               => "$environment",
      "tomcat.DataSource.driverClassName"                   => "com.mysql.jdbc.Driver",
      "tomcat.DataSource.url"                               => "jdbc:mysql://localhost/{{tomcat.DataSource.context}}",
      "tomcat.DataSource.context"                           => "petclinic",
      "tests2.ExecutedHttpRequestTest.expectedResponseText" => "Home",
    },
    restrict_to_containers                                  => ["Infrastructure/$environment/$fqdn/appserver-$hostname/$hostname.vh", "Infrastructure/$environment/$fqdn/test-runner-$hostname", "Infrastructure/$environment/$fqdn/appserver-$hostname"],
    environments                                            => "Environments/$environment/App-$environment",
    server                                                  => Xldeploy["xld-server"],
  }

}
