# == Class: baseconfig
#
# XLD base ci
#


class xld-base ( $sudo_username, $staging_directory_path, $xldeploy_url)  {

  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

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


}
