# == Class: baseconfig
#
# Install JBossAS instance and declare it in XLD
#


class xld-jbossas {

  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  include java
  include jbossas


  deployit_container { "Infrastructure/$environment/$fqdn/$hostname":
    type         => 'jbossas.ServerV5',
    properties   => {
      home        => hiera('jbossas::home'),
      serverName  => hiera('jbossas::configuration'),
    },
    server       => Deployit["xld-server"],
    environments => "Environments/$environment/App-$environment",
  }

  deployit_dictionary { "Environments/$environment/App-$environment-$hostname.dict":
    server                 => Deployit["xld-server"],
    environments           => "Environments/$environment/App-$environment",
    entries                => {
      'TITLE'         => "Hello from {{IP}}",
      'IP'            => $ipaddress_eth1,
      'log.level'     => hiera('config::loglevel'),
      'log.file.path' => hiera('config::logfilepath'),
    },
    restrict_to_containers => ["Infrastructure/$environment/$fqdn/$hostname"],
  }


}
