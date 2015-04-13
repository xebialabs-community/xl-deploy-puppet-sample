xldeploy-puppet-sample
======================

This project shows how to integrate XL Deploy and Puppet using Vagrant images.

# XL Deploy

Start an XL Deploy instance up with the following properties:
* tomcat-plugin
* xld-smoke-test-plugin (https://github.com/xebialabs-community/xld-smoke-test-plugin/releases)
* listening on the port 4516
* username admin
* password admin

The XLDeploy URL and credential can be changed in the common.yaml file.


# Tomcat images

  vagrant up tomcat1 tomcat2

Configure a new virtual machine, install a tomcat server and declare all
the matching CI in the XL Deploy repository in the 'PuppetDemo'
directory. All the CI are gathered in the same environment.

# MySQL image

  vagrant up dbprod

Configure a new virtual machine, install a MySql client & server and declare all
the matching CI in the XL Deploy repository in the 'PuppetDemo'
directory. All the CI are gathered in the same environment.


