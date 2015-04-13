# == Class: baseconfig
#
# Install Tomcat instance and declare it in XLD
#


class xld-tomcat ( $tomcat_port_http, $tomcat_port_mgt, $tomcat_port_ajp, $deployment_group, $xldeploy_url)  {

  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  include java

  class { 'tomcat':
    version     => '7',
    sources     => true,
    sources_src => 'file:/vagrant/tomcat'
  }

  tomcat::instance { 'appserver':
    ensure      => present,
    server_port => $tomcat_port_mgt,
    http_port   => $tomcat_port_http,
    ajp_port    => $tomcat_port_ajp,
  }

  xldeploy_ci { "Infrastructure/$environment/$fqdn/appserver-$hostname":
    type            => 'tomcat.Server',
    properties      => {
      stopCommand   => '/etc/init.d/tomcat-appserver stop',
      startCommand  => 'nohup /etc/init.d/tomcat-appserver start',
      home          => '/srv/tomcat/appserver',
      stopWaitTime  => 0,
      startWaitTime => 10,
      deploymentGroup => "$deployment_group",
    },
    rest_url        => $xldeploy_url
  }

  xldeploy_ci { "Infrastructure/$environment/$fqdn/appserver-$hostname/$hostname.vh":
    type         => 'tomcat.VirtualHost',
    properties   => {
      deploymentGroup => "$deployment_group",
    },
    rest_url        => $xldeploy_url
  }

  xldeploy_ci { "Infrastructure/$environment/$fqdn/test-runner-$hostname":
    type         => 'smoketest.Runner',
    properties   => {
      deploymentGroup => "$deployment_group",
    },
    rest_url     => $xldeploy_url
  }

  xldeploy_ci { "Environments/$environment/$fqdn.dict":
    type       => "udm.Dictionary",
    properties => {
      entries                                                 => {
        "log.RootLevel"                                       => "ERROR",
        "log.FilePath"                                        => "/tmp/null",
        "tomcat.port"                                         => "$tomcat_port_http",
        "tests2.ExecutedHttpRequestTest.url"                  => "http://localhost:{{tomcat.port}}/petclinic/index.jsp",
        "tomcat.DataSource.username"                          => "scott",
        "tomcat.DataSource.password"                          => "tiger",
        "TITLE"                                               => "$environment",
        "tomcat.DataSource.driverClassName"                   => "com.mysql.jdbc.Driver",
        "tomcat.DataSource.url"                               => "jdbc:mysql://localhost/{{tomcat.DataSource.context}}",
        "tomcat.DataSource.context"                           => "petclinic",
        "tests2.ExecutedHttpRequestTest.expectedResponseText" => "Home",
      },
      restrictToContainers                                    => ["Infrastructure/$environment/$fqdn/appserver-$hostname/$hostname.vh", "Infrastructure/$environment/$fqdn/test-runner-$hostname", "Infrastructure/$environment/$fqdn/appserver-$hostname"],
    },
    rest_url => $xldeploy_url,
    require  => [Xldeploy_ci["Infrastructure/$environment/$fqdn/appserver-$hostname/$hostname.vh"],
      Xldeploy_ci[ "Infrastructure/$environment/$fqdn/test-runner-$hostname"],
      Xldeploy_ci["Infrastructure/$environment/$fqdn/appserver-$hostname"]],
  }

  xldeploy_environment_member { "Manage Tomcat members of Environments/$environment/App-$environment":
    env          => "Environments/$environment/App-$environment",
    members      => ["Infrastructure/$environment/$fqdn/appserver-$hostname/$hostname.vh", "Infrastructure/$environment/$fqdn/test-runner-$hostname", "Infrastructure/$environment/$fqdn/appserver-$hostname"],
    dictionaries => ["Environments/$environment/$fqdn.dict"],
    rest_url     => $xldeploy_url,
  }


}
