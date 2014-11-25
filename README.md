xldeploy-puppet-sample
======================

This project shows how to integrate XL Deploy and Puppet using Vagrant images.

# Setup and Installation #

After cloning this repository, initialize and update the git submodules for it:

    git submodule init
    git submodule update

This should clone repositories and provide the necessary shared puppet modules that are needed to run any vagrant projects.


## Submodules ##

    git submodule add git@github.com:puppetlabs/puppetlabs-java.git puppet/modules/java
    git submodule add git@github.com:puppetlabs/puppetlabs-stdlib.git puppet/modules/stdlib
    git submodule add git@github.com:puppetlabs/puppetlabs-mysql.git puppet/modules/mysql
    git submodule add git@github.com:camptocamp/puppet-tomcat.git puppet/modules/tomcat
    git submodule add git@github.com:camptocamp/puppet-archive.git puppet/modules/archive
    git submodule add git@github.com:bmoussaud/puppet-xldeploy.git puppet/modules/xld

# Vagrant #

    vagrant plugin install vagrant-cachier
    
# Build the base-image #

These images allow to run the other images *without* internet connection.

## ubuntu-1304-puppet-java ##
Used by tomcat & jboss image

    vagrant up base-java
    vagrant package base-java
    vagrant box add ubuntu-1304-puppet-java package.box  


## ubuntu-1304-puppet-java ##
Used by the tomcat & jboss images

    vagrant up base-java
    vagrant package base-java
    vagrant box add ubuntu-1304-puppet-java package.box  

## ubuntu-1304-puppet-mysql ##
Used the mysql images 

    vagrant up base-mysql
    vagrant package base-mysql
    vagrant box add ubuntu-1304-puppet-mysql package.box  




