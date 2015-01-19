# -*- mode: ruby -*-
# vi: set ft=ruby :
domain = 'xebialabs.demo'

nodes = [
  { :hostname => 'jbossdev', :ip => '10.0.0.190', :box => 'ubuntu-1304-puppet-java', :ram => 1024 },
  { :hostname => 'jbossqa', :ip => '10.0.0.201', :box => 'ubuntu-1304-puppet-java', :ram => 1024 },
  { :hostname => 'jbossprod1', :ip => '10.0.0.202', :box => 'ubuntu-1304-puppet-java', :ram => 1024 },
  { :hostname => 'jbossprod2', :ip => '10.0.0.203', :box => 'ubuntu-1304-puppet-java', :ram => 1024 },

  { :hostname => 'dbqa', :ip => '10.0.0.204', :box => 'ubuntu-1304-puppet-mysql', :ram => 512 },
  { :hostname => 'dbprod', :ip => '10.0.0.205', :box => 'ubuntu-1304-puppet-mysql', :ram => 512 },

  { :hostname => 'tomcat1', :ip => '10.0.0.101', :box => 'ubuntu-1304-puppet-java', :ram => 1024},
  { :hostname => 'tomcat2', :ip => '10.0.0.102', :box => 'ubuntu-1304-puppet-java', :ram => 1024 },
  { :hostname => 'tomcat3', :ip => '10.0.0.103', :box => 'ubuntu-1304-puppet-java', :ram => 1024 },

  { :hostname => 'base-java', :ip => '10.0.0.10', :box => 'ubuntu-1310-x64-virtualbox-puppet', :ram => 1024},
  { :hostname => 'base-mysql', :ip => '10.0.0.11', :box => 'ubuntu-1310-x64-virtualbox-puppet', :ram => 1024},
]

# http://superuser.com/questions/144453/virtualbox-guest-os-accessing-local-server-on-host-os wget http://10.0.2.2:4516
Vagrant.configure("2") do |config|
  nodes.each do |node|
    config.vm.define node[:hostname] do |node_config|

      node_config.vm.box = node[:box]
      node_config.vm.host_name = node[:hostname] + '.' + domain
      node_config.vm.network :private_network, ip: node[:ip]
      node_config.vm.synced_folder ENV["CATALOG"], "/catalog", mount_options: ['dmode=777','fmode=666' ]

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
  #config.vm.provision :shell, path: 'bootstrap.sh'

  #config.vm.provision :shell, :path => "scripts/librarian.sh"

  config.vm.provision :puppet do |puppet|
    puppet.hiera_config_path = 'hiera.yaml'
    puppet.manifests_path = 'puppet/manifests'
    puppet.manifest_file = 'site.pp'
    puppet.module_path = ['./puppet/modules']

    #puppet.options = "--verbose --debug --trace"
  end
end
