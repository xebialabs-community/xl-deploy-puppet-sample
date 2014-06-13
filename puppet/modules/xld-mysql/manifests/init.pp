# == Class: baseconfig
#
# Install MySQL instance and declare it in XLD
#


class xld-mysql {
  class { '::mysql::server':
    root_password   => 'deployitpassword',
  }

  mysql::db { 'petportal':
    user     => 'petuser',
    password => 'petpassword',
    host     => 'localhost',
    grant    => ['all'],
  }

  deployit { "xld-mysql":
    username             => "admin",
    password             => "admin",
    url                  => "http://10.0.2.2:4516",
    encrypted_dictionary => "Environments/Puppet/PuppetModuleDictionary"
  }

  deployit_directory { 'Infrastructure/puppet':
    server   	  => Deployit["xld-mysql"],
  }
  deployit_directory { 'Environments/Puppet':
    server   	  => Deployit["xld-mysql"],
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
    server   	 => Deployit["xld-mysql"],
    require    => Deployit_directory["Infrastructure/puppet"]
  }

  deployit_container { "Infrastructure/puppet/$hostname/mysql-$hostname":
    type     	=> 'sql.MySqlClient',
    properties  => {
      username    => 'petuser',
      password    => 'petpassword',
      databaseName  => 'petportal',
      mySqlHome     => '/usr',
    },
    server   	=> Deployit["xld-mysql"],
    require 	=> Deployit_container["Infrastructure/puppet/$hostname"],
    environments => "Environments/Puppet/demo",
  }


}
