# == Class: baseconfig
#
# XLD base ci
#


class xld-base ( $url,$username,$password,$sudo_username, $staging_directory_path)  {

  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  xldeploy { "xld-server":
    username             => $username,
    password             => $password,
    url                  => $url,
    encrypted_dictionary => "Environments/$environment/PuppetModuleDictionary"
  }

  Xldeploy_directory { "Infrastructure/$environment":
    server      => Xldeploy["xld-server"],
  }

  Xldeploy_directory { "Environments/$environment":
    server      => Xldeploy["xld-server"],
  }

  Xldeploy_container { "Infrastructure/$environment/$fqdn":
    type        => "overthere.SshHost",
    properties  => {
      os      => UNIX,
      address => $ipaddress_eth1,
      username  => vagrant,
      password => vagrant,
      connectionType => INTERACTIVE_SUDO,
      sudoUsername => $sudo_username,
      stagingDirectoryPath => $staging_directory_path
    },
    server      => Xldeploy["xld-server"],
  }


}
