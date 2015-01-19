# == Class: baseconfig
#
# Install MySQL instance and declare it in XLD
#


class xld-mysql( $dbname,$dbuser,$dbpassword, $xldeploy_url) {

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

  xldeploy_environment_member { "Manage MySQL members of Environments/$environment/App-$environment":
    env          => "Environments/$environment/App-$environment",
    members      => ["Infrastructure/$environment/$fqdn/mysql-$dbname"],
    dictionaries => ["Environments/$environment/App-db-$environment"],
    rest_url     => $xldeploy_url,
  }

}
