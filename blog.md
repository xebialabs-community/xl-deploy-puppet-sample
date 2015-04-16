# XLD & Puppet



Puppet and XL Deploy can work together if we put each of them in their domain:

* Puppet manages the provisioning by ensuring the OS and the middleware is correctly configured : This node should have a Tomcat 7.0.42 instance running using a tomcat user and listening en the 8080 port
* XLD manages the application deployment that takes 2 inputs: a deployment package built by CI tools (Jenkins / TFS) and a environment built by a provisioning tools, e.g. Puppet !

The integration between the 2 solutions is handled by a [module](https://github.com/xebialabs/puppet-xldeploy) provided by XebiaLabs that will ensure the containers are correctly defined in the XL Deloy repository based on the information managed by Puppet. It uses the REST API offered  by the XL Deploy server: so the security permissions are checked as a operator could do it using the GUI or the CLI.

This article shows you how use the [xebialabs/xldeploy](https://forge.puppetlabs.com/xebialabs/xldeploy) Puppet module.

The Production environment is based on 2 tomcats instances (tomcat1 & tomcat2) and a MySql database (dbprod)
This information is configured in site.pp file: 3 modules are used xld-base, xld-tomcat, xld-mysql.

```
node 'tomcat1','tomcat2' {
  $environment = "PuppetDemo"
  include java
  include xld-base
  include xld-tomcat
}


node 'dbprod' {
  $environment = "PuppetDemo"
  include xld-base
  include xld-mysql
}
```

## XLD-Base module

This module manages the configuration of the node itself : it is a [simple class](https://github.com/xebialabs-community/xl-deploy-puppet-sample/blob/master/puppet/modules/xld-base/manifests/init.pp)

```
  xldeploy_ci { "Infrastructure/$environment":
    type        => 'core.Directory',
    rest_url    => $xldeploy_url
  }

  xldeploy_ci { "Environments/$environment":
    type        => 'core.Directory',
    rest_url    => $xldeploy_url
  }

  xldeploy_ci { "Infrastructure/$environment/$fqdn":
    type        => "overthere.SshHost",
    rest_url    => $xldeploy_url,
    properties  => {
      os      => UNIX,
      address => $ipaddress_eth1,
      username  => vagrant,
      password => vagrant,
      connectionType => INTERACTIVE_SUDO,
      sudoUsername => $sudo_username,
      stagingDirectoryPath => $staging_directory_path
    },
  }

  xldeploy_ci {"Environments/$environment/App-$environment":
    type       => 'udm.Environment',
    properties => { },
    rest_url     => $xldeploy_url
  }
  
```

The xldeploy_ci resources used here will ensure:

* 2 diretories exists in the repository `Infrastructure/$environment` and `Environments/$environment`
* the overthere ssh host is configured in the repository with the Infrastructure/$environment/$fqdn ID : the fully qualified domain name ($fqdn) and the IP address $ipaddress_eth1 are provided by the Puppet facts. The other parameters ($sudo_username, $staging_directory_path) are provided by the Hiera database.
* the target environment `Environments/$environment/App-$environment` is created.

the `$rest_url` parameters is provided by the hiera configuration, it includes the address, the port, the credentianl and the context of the XL Deploy server. The value used here is : `http://admin:admin@10.0.2.2:4516/deployit`


## XLD-Tomcat module

This [module](https://github.com/xebialabs-community/xl-deploy-puppet-sample/blob/master/puppet/modules/xld-tomcat/manifests/init.pp) manages the tomcat configuration and the information that need to be configured in XL Deploy.

The first part of the class is the configuration of the tomcat instance

```
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
```
Then the configuration for XL Deploy repository:

```
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
```

The 2 xldeploy_ci resources configure the ‘tomcat.Server’ and the associated ‘tomcat.VirtualHost’ Configuration items. They share the same deployment group ($deployment_group)
The ‘autorequire’ feature has been implements so it is not necessary to define explicitly ‘require’ between the 2 resources.

The module offers to define dictionaries, to populate them with values managed by Puppet (ex tomcat.http.port or environment name) and to associate them to environments.

```
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

```

Finaly we gather all these containers and the dictionaries in the target enviroment:

```
 xldeploy_environment_member { "Manage Tomcat members of Environments/$environment/App-$environment":
    env          => "Environments/$environment/App-$environment",
    members      => ["Infrastructure/$environment/$fqdn/appserver-$hostname/$hostname.vh", "Infrastructure/$environment/$fqdn/test-runner-$hostname", "Infrastructure/$environment/$fqdn/appserver-$hostname"],
    dictionaries => ["Environments/$environment/$fqdn.dict"],
    rest_url     => $xldeploy_url,
  }
```

Find the complete manifest here: [https://github.com/xebialabs-community/xl-deploy-puppet-sample/blob/master/puppet/modules/xld-tomcat/manifests/init.pp](https://github.com/xebialabs-community/xl-deploy-puppet-sample/blob/master/puppet/modules/xld-tomcat/manifests/init.pp)

## XLD-MySQL module

This module is designed as the previous one: one section to configure the database instance, the other to configure it in XL Deploy. Note the same parameters ($dbuser, $dbpasword and $dbname)  are used to configure the database, the SqlContainer and the dictionary for the tomcat datasource. If the security team decides to change it, it've been defined in a single location and the information can be propagated to the node and the deployed application.

```
 mysql::db { "$dbname":
    user     => $dbuser,
    password => $dbpassword,
    host     => '%',
    grant    => ['all'],
  }

  xldeploy_ci { "Infrastructure/$environment/$fqdn/mysql-$dbname":
    type         => 'sql.MySqlClient',
    properties   => {
      username        => "$dbuser",
      password        => "$dbpassword",
      databaseName    => "$dbname",
      mySqlHome       => '/usr',
      deploymentGroup => "1",
    },
    rest_url  => $xldeploy_url,
  }

  xldeploy_ci { "Environments/$environment/App-db-$environment":
    rest_url   => $xldeploy_url,
    type       => 'udm.Dictionary',
    properties => {
      entries              => {
        'db.username'      => "$dbuser",
        'db.password'      => "$dbpassword",
        'db.name'          => "$dbname",
        'db.host'          => "$ipaddress_eth1",
        'db.url'           => "jdbc:mysql://{{db.host}}:3306/{{db.name}}",
        }},
  }
```

Find the complete manifest file here: [https://github.com/xebialabs-community/xl-deploy-puppet-sample/blob/master/puppet/modules/xld-mysql/manifests/init.pp](https://github.com/xebialabs-community/xl-deploy-puppet-sample/blob/master/puppet/modules/xld-mysql/manifests/init.pp))


The xl-deploy-puppet-module can manage roles, permission... check out the module documentation for the other features.

# Wrap up

The integration between XL Deploy and Puppet applies the separation of concern principle, the one manages the provisioning, the other managed the application deployment and application configuration. The 2 solutions are model based : you describe the target and not the how to reach the target.

You can find all the described manifest files and the whole project based on Vagrant here : [https://github.com/xeblialabs-community/xl-deploy-puppet-sample](https://github.com/xeblialabs-community/xl-deploy-puppet-sample)







