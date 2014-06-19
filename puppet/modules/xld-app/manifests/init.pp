# == Class: baseconfig
#
# Install Deploy the application through XLD
#


class xld-app {

  include xld-base

  deployed_application { "PetClinic on Demo Env":
    version          => "Applications/Java/PetPortal/2.0-68",
    environment      => "Environments/Puppet/demo",
    server           => Deployit['xld-server'],
    require          => Deployit_dictionary["Environments/Puppet/$hostname.dict"],
    force_deployment => true,
    ensure           => present,

  }
}
