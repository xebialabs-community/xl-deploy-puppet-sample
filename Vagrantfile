# -*- mode: ruby -*-
# vi: set ft=ruby :
domain = 'xebialabs.demo'

nodes = [
  { :hostname => 'base', :ip => '10.0.0.10', :box => 'ubuntu-1310-x64-virtualbox-puppet', :ram => 1024},
  { :hostname => 'tomcat1', :ip => '10.0.0.101', :box => 'ubuntu-1310-x64-virtualbox-puppet', :ram => 1024},
  { :hostname => 'tomcat2', :ip => '10.0.0.102', :box => 'ubuntu-1310-x64-virtualbox-puppet', :ram => 1024 },
  { :hostname => 'tomcat3', :ip => '10.0.0.103', :box => 'ubuntu-1310-x64-virtualbox-puppet', :ram => 1024 },
  { :hostname => 'jbossqa', :ip => '10.0.0.201', :box => 'ubuntu-1304-puppet-java', :ram => 1024 },
  { :hostname => 'jbossprod1', :ip => '10.0.0.202', :box => 'ubuntu-1304-puppet-java', :ram => 1024 },
  { :hostname => 'jbossprod2', :ip => '10.0.0.203', :box => 'ubuntu-1304-puppet-java', :ram => 1024 },
  { :hostname => 'dbqa', :ip => '10.0.0.300', :box => 'ubuntu-1310-x64-virtualbox-puppet'  },
  { :hostname => 'dbprod', :ip => '10.0.0.300', :box => 'ubuntu-1310-x64-virtualbox-puppet'  }
]

# http://superuser.com/questions/144453/virtualbox-guest-os-accessing-local-server-on-host-os wget http://10.0.2.2:4516
Vagrant::Config.run do |config|
  nodes.each do |node|
    config.vm.define node[:hostname] do |node_config|

      if Vagrant.has_plugin?("vagrant-cachier")
        config.cache.scope = :box
        config.cache.synced_folder_opts = {
          type: :nfs,
          # The nolock option can be useful for an NFSv3 client that wants to avoid the
          # NLM sideband protocol. Without this option, apt-get might hang if it tries
          # to lock files needed for /var/cache/* operations. All of this can be avoided
          # by using NFSv4 everywhere. Please note that the tcp option is not the default.
          mount_options: ['rw', 'vers=3', 'tcp', 'nolock']
        }
      end

      node_config.vm.box = node[:box]
      node_config.vm.host_name = node[:hostname] + '.' + domain
      node_config.vm.network :hostonly, node[:ip]
      node_config.vm.share_folder("catalog", "/catalog", ENV["CATALOG"])

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
  #config.vm.provision :shell, path: "bootstrap.sh"

  config.vm.provision :puppet do |puppet|
    puppet.hiera_config_path = 'hiera.yaml'
    puppet.manifests_path = 'puppet/manifests'
    puppet.module_path = 'puppet/modules'
    puppet.manifest_file = 'site.pp'
    puppet.module_path = ["./puppet/modules", "puppet/xl-modules/tool-deployit-plugins"]

    #puppet.options = "--verbose --debug"
  end
end
