# == Class: baseconfig
#
# Install Deploye the application through XLD
#


class xld-app {

  deployit { "xld-app":
    username             => "admin",
    password             => "admin",
    url                  => "http://10.0.2.2:4516",
    encrypted_dictionary => "Environments/Puppet/PuppetModuleDictionary"
  }

  deployed_application { "PetClinic on Demo Env":
    version          => "Applications/Java/PetPortal/2.0-68",
    environment      => "Environments/Puppet/demo",
    server           => Deployit['xld-app'],
    require          => Deployit_dictionary["Environments/Puppet/$hostname.dict"],
    force_deployment => true,
    ensure           => present,

  }
}
