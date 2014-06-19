# == Class: baseconfig
#
# XLD base ci
#


class xld-base ( $url,$username,$password)  {

  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  deployit { "xld-server":
    username             => $username,
    password             => $password,
    url                  => $url,
    encrypted_dictionary => "Environments/$environment/PuppetModuleDictionary"
  }

  deployit_directory { "Infrastructure/$environment":
    server   	  => Deployit["xld-server"],
  }

  deployit_directory { "Environments/$environment":
    server   	  => Deployit["xld-server"],
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
      sudoUsername => jbossas,
    },
    server   	 => Deployit["xld-server"],
    require    => Deployit_directory["Infrastructure/$environment"]
  }


}
