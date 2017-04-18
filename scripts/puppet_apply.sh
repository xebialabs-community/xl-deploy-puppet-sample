echo "---------------------------------------------------"
echo "-------- PUPPET APPLY -----------------------------"
echo "---------------------------------------------------"
puppet apply --modulepath=/etc/puppet/modules:/vagrant/my_modules --hiera_config=/vagrant/hiera.yaml /vagrant/puppet/site.pp  --verbose
