domain = 'xebialabs.demo'

nodes = [
  { :hostname => 'tomcat1', :ip => '10.0.0.101', :box => 'ubuntu-1310-x64-virtualbox-puppet', :ram => 1024},
  { :hostname => 'tomcat2', :ip => '10.0.0.102', :box => 'ubuntu-1310-x64-virtualbox-puppet', :ram => 1024 },
  { :hostname => 'tomcat3', :ip => '10.0.0.103', :box => 'ubuntu-1310-x64-virtualbox-puppet', :ram => 1024 },
  { :hostname => 'db', :ip => '10.0.0.200', :box => 'ubuntu-1310-x64-virtualbox-puppet'  }
]

# http://superuser.com/questions/144453/virtualbox-guest-os-accessing-local-server-on-host-os wget http://10.0.2.2:4516
Vagrant::Config.run do |config|
  nodes.each do |node|
    config.vm.define node[:hostname] do |node_config|
      node_config.vm.box = node[:box]
      node_config.vm.host_name = node[:hostname] + '.' + domain
      node_config.vm.network :hostonly, node[:ip]

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

  config.vm.provision :puppet do |puppet|
    puppet.hiera_config_path = 'hiera.yaml'
    puppet.manifests_path = 'puppet/manifests'
    puppet.module_path = 'puppet/modules'
    puppet.manifest_file = 'site.pp'
    puppet.module_path = ["./puppet/modules", "puppet/xl-modules/tool-deployit-plugins"]

    puppet.options = "--verbose --debug "
  end
end
