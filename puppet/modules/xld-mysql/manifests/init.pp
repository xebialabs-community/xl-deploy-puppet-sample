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

  deployit_container { "Infrastructure/$environment/$fqdn/mysql-$dbname":
    type         => 'sql.MySqlClient',
    properties   => {
      username    => $dbuser,
      password    => $dbpassword,
      databaseName  => $dbname,
      mySqlHome     => '/usr',
    },
    server       => Deployit["xld-server"],
    environments => "Environments/$environment/App-$environment",
  }

  deployit_dictionary { "Environments/$environment/App-db-$environment":
    server               => Deployit["xld-server"],
    environments         => "Environments/$environment/App-$environment",
    entries              => {
      'db.username'      => $dbuser,
      'db.password'      => $dbpassword,
      'db.name'          => $dbname,
      'db.host'          => $ipaddress_eth1,
      'db.url'           => "jdbc:mysql://{{db.host}}:3306/{{db.name}}",
    },
  }
}
