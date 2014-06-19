# == Class: baseconfig
#
# Install MySQL instance and declare it in XLD
#


class xld-mysql( $dbname,$dbuser,$dbpassword) {

  class { '::mysql::server':
    root_password    => 'deployitpassword',
    override_options => { 'mysqld' => { 'bind-address' => '0.0.0.0' } },
    restart          => true,
  }

  mysql::db { "$dbname":
    user     => $dbuser,
    password => $dbpassword,
    host     => '%',
    grant    => ['all'],
  }

  deployit { "xld-mysql":
    username             => "admin",
    password             => "admin",
    url                  => "http://10.0.2.2:4516",
    encrypted_dictionary => "Environments/$environment/PuppetModuleDictionary"
  }

  deployit_directory { "Infrastructure/$environment":
    server   	  => Deployit["xld-mysql"],
  }
  deployit_directory { 'Environments/$environment':
    server   	  => Deployit["xld-mysql"],
    require    => Deployit_directory["Infrastructure/$environment"]
  }

  deployit_container { "Infrastructure/$environment/$fqdn":
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
    require    => Deployit_directory["Infrastructure/$environment"]
  }

  deployit_container { "Infrastructure/$environment/$fqdn/mysql-$dbname":
    type     	=> 'sql.MySqlClient',
    properties  => {
      username    => $dbuser,
      password    => $dbpassword,
      databaseName  => $dbname,
      mySqlHome     => '/usr',
    },
    server   	=> Deployit["xld-mysql"],
    require 	=> Deployit_container["Infrastructure/$environment/$fqdn"],
    environments => "Environments/$environment/App-$environment",
  }

  deployit_dictionary {"Environments/$environment/App-db-$environment":
    server   	           => Deployit["xld-mysql"],
    environments         => "Environments/$environment/App-$environment",
    require 	           => Deployit_container["Infrastructure/$environment/$fqdn/mysql-$dbname"],
    entries              => {
      'db.username'      => $dbuser,
      'db.password'      => $dbpassword,
      'db.name'          => $dbname,
      'db.host'          => $ipaddress_eth1,
      'db.url'           => "jdbc:mysql://{{db.host}}:3306/{{db.name}}",
    },
  }
}
