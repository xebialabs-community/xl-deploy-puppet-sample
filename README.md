xldeploy-puppet-sample
======================

Tested using Vagrant 1.9.3, Puppet v3.8.5

This project shows how to integrate [XL Deploy](https://xebialabs.com/products/xl-deploy/) and [Puppet](https://puppetlabs.com/) using [Vagrant](https://www.vagrantup.com/) images.
It integrates the [xl-deploy  Puppet Module](https://forge.puppetlabs.com/xebialabs/xldeploy) to declare automaticaly in the XL Deploy repository all the middleware managed by Puppet

# XL Deploy

Start an XL Deploy instance up with the following properties:

* tomcat-plugin
* [xld-smoke-test-plugin](https://github.com/xebialabs-community/xld-smoke-test-plugin/releases) * listening on the port `4516`
* username `admin`
* password `admin`

The XLDeploy URL and credential can be changed in the common.yaml file.


# the Tomcat images

```
vagrant up tomcat1 tomcat2
```

Configure a new virtual machine, install a tomcat server and declare all
the matching CI in the XL Deploy repository in the 'PuppetDemo'
directory. All the CI are gathered in the same environment.

Once created, look at the XL Deploy Repository and go to 

* `Infrastructure/PuppetDemo`: it includes the configured host and tomcat container
* `Environments/PuppetDemo`: it includes the configured environment and dictionary.


# the MySQL image

```
vagrant up dbprod
```

Configure a new virtual machine, install a MySql client & server and declare all
the matching CI in the XL Deploy repository in the 'PuppetDemo'
directory. All the CI are gathered in the same environment.

Once created, look at the XL Deploy Repository and go to 

* `Infrastructure/PuppetDemo`: it includes the configured MySql client CI
* `Environments/PuppetDemo`: it includes the configured environment and dictionary.


