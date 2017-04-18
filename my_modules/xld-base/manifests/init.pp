# == Class: baseconfig
#
# XLD base ci
#


class xld-base ( $sudo_username, $staging_directory_path, $xldeploy_url)  {

  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  user { 'deployer':
    ensure           => 'present',
    gid              => '502',
    home             => '/home/deployer',
    password         => '$6$WZal6zvVq1Ta2$2Ry3mHamB8DrdBEckUA5qSmDYP.wtm8s5aHw31M5U/g0/eJYaeASyO/UWG3HgKjW04LHtphKEbi9kHpdF6EcO0', #deployer01
    password_max_age => '99999',
    password_min_age => '0',
    shell            => '/bin/bash',
    managehome       => true,
    uid              => '505',
    require          => Group["deployer"],
  }

  ssh_authorized_key { 'deployer_ssh':
    user    => 'deployer',
    type    => 'rsa',
    key     => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDRtOhvmAxnoCEMvRUdsQMdwedgShPQNXNVVkLf1NOWR+fxzmWWGQ5vfQ5puh0wsJujgB3/oO4WgiG6pfigaXWMFuysPvQWb4UNO1WdWbhXntJPTkLq0EZSq5uafvQY7dJa9chs/DVwRmmSQMKGwwdbQgEMBxBuC2Ni6vGL1uAwObaXyU+gosq/AU7fI+zvDL8UE4s93b93fOh5V7HWufbfyJxKyjds7fNOx7T1kY6fvdUG0xVX3fcsO4xxDwGHufOionu/lRWbCFoHuxcDFZxpl/68zF7pG9zgcoyzBRXVHg4GTOPh2GRpz+e+CUYWrnAdQs2qHk/OY6lJ0GiIQV2B',
    require => User["deployer"],
  }

  sudo::conf { 'deployers':
    ensure  => present,
    content => 'deployer ALL=(ALL) NOPASSWD:ALL',
  }

  sudo::conf { 'ubuntu':
    ensure  => present,
    content => 'ubuntu ALL=(ALL) NOPASSWD:ALL'
  }

  group { 'deployer':
    ensure => 'present',
    gid    => '502',
  }

  xldeploy_ci { "Infrastructure/$environment":
    type        => 'core.Directory',
    rest_url    => $xldeploy_url
  }

  xldeploy_ci { "Environments/$environment":
    type        => 'core.Directory',
    rest_url    => $xldeploy_url
  }

  xldeploy_ci { "Infrastructure/$environment/$fqdn":
    type                   => "overthere.SshHost",
    rest_url               => $xldeploy_url,
    properties             => {
      os                   => UNIX,
      port                 => 22,
      address              => $ipaddress_enp0s8,
      username             => 'deployer',
      password             => 'deployer01',
      connectionType       => INTERACTIVE_SUDO,
      sudoUsername         => $sudo_username,
      stagingDirectoryPath => $staging_directory_path,
    },
  }

  xldeploy_ci {"Environments/$environment/App-$environment":
    type       => 'udm.Environment',
    properties => { },
    rest_url   => $xldeploy_url,
  }


}
