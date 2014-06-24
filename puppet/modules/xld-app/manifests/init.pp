# == Class: baseconfig
#
# Install Deploy the application through XLD
#


class xld-app {

  deployed_application { "PetClinic on Environments/$environment/App-$environment Env":
    version          => "Applications/Java/PetPortal/2.0-68",
    environment      => "Environments/$environment/App-$environment",
    server           => Deployit['xld-server'],
    require          => Deployit_dictionary["Environments/$environment/$fqdn.dict"],
    force_deployment => true,
    ensure           => present,

  }
}
