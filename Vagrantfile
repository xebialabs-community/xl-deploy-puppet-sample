# -*- mode: ruby -*-
# vi: set ft=ruby :
domain = 'xebialabs.demo'

nodes = [
  { :hostname => 'dbprod', :ip => '10.0.0.205', :box => 'ubuntu/xenial64', :ram => 512 },
  { :hostname => 'tomcat1', :ip => '10.0.0.101', :box => 'ubuntu/xenial64', :ram => 1536},
  { :hostname => 'tomcat2', :ip => '10.0.0.102', :box => 'ubuntu/xenial64', :ram => 1536 },
  { :hostname => 'tomcat3', :ip => '10.0.0.103', :box => 'ubuntu/xenial64', :ram => 1536 },
]

# http://superuser.com/questions/144453/virtualbox-guest-os-accessing-local-server-on-host-os wget http://10.0.2.2:4516
Vagrant.configure("2") do |config|
  nodes.each do |node|
    config.vm.define node[:hostname] do |node_config|

      node_config.vm.box = node[:box]
      node_config.vm.host_name = node[:hostname] + '.' + domain
      node_config.vm.network :private_network, ip: node[:ip]

      memory = node[:ram] ? node[:ram] : 256;
      node_config.vm "virtualbox" do |v|
        v.customize[
          'modifyvm', :id,
          '--name', node[:hostname],
          '--memory', memory.to_s
        ]
      end
    end
  end

  config.vm.provision :shell, :path => "scripts/librarian.sh"
  config.vm.provision :shell, :path => "scripts/puppet_apply.sh"

  #config.vm.provision :puppet do |puppet|
  #  puppet.hiera_config_path = 'hiera.yaml'
  #  puppet.working_directory = "/tmp/vagrant-puppet"
  #  puppet.options = "--verbose --debug"
  #  puppet.module_path = ["my_modules","my_modules"]
  #end
end
