xldeploy-puppet-sample
======================

Show how to integrate XL Deploy and Puppet using Vagrant

# Setup and Installation #

After cloning this repository, initialize and update the git submodules for it:

    git submodule init
    git submodule update

This should clone repositories and provide the necessary shared puppet modules that are needed to run any vagrant projects.


# Submodules #

    git submodule add git@github.com:puppetlabs/puppetlabs-java.git modules/java
    git submodule add git@github.com:puppetlabs/puppetlabs-stdlib.git modules/stdlib
    git submodule add git@github.com:puppetlabs/puppetlabs-mysql.git modules/mysql
    git submodule add git@github.com:camptocamp/puppet-tomcat.git modules/tomcat
    git submodule add git@github.com:camptocamp/puppet-archive.git modules/archive
    git submodule add git@github.com:bmoussaud/community-plugins.git  xl-modules --branch puppet39





