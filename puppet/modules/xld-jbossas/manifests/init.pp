# == Class: baseconfig
#
# Install JBossAS instance and declare it in XLD
#


class xld-jbossas {

  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  include java
  include jbossas

  deployit { "xld-jbossas":
    username             => "admin",
    password             => "admin",
    url                  => "http://10.0.2.2:4516",
    encrypted_dictionary => "Environments/Puppet/PuppetModuleDictionary"
  }
}
