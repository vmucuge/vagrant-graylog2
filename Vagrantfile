# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "precise64"
  #config.vm.box_url = "http://vagrantboxes.footballradar.com/wheezy64.box"

  #config.vm.provider "virtualbox" do |v|
  # v.customize ["modifyvm", :id, "--memory", "1024"]
  #end


  config.vm.define :graylog01 do |graylog01|
    vm_name = "graylog01"
    config.vm.provider :virtualbox do |vb|
      vb.gui = true
      vb.customize ["modifyvm", :id, "--memory", "2048", "--name", "#{vm_name}"]
    end
    graylog01.vm.hostname = "graylog01.test.vm"
    graylog01.vm.network :private_network, ip: "192.168.33.22"

    #elastic01.vm.provision :shell, :path => "elasticrepo.sh"

    #www.vm.provision :puppet, manifests_path => "manifests", manifest_file => "elastic01.pp"
  end


  #config.vm.provision :puppet do |puppet|
  #  puppet.manifest_file = "graylog2.pp"
  #  puppet.module_path   = "modules"
  #end

  config.vm.provision :shell, :path => "graylog2/install_graylog2_20_ubuntu.sh"
  config.vm.network :forwarded_port, guest: 9000, host: 9000
  config.vm.network :forwarded_port, guest: 80, host: 8080
  config.vm.network :forwarded_port, guest: 12201, host: 12201, protocol: 'udp', auto_correct: true
  config.vm.network :forwarded_port, guest: 12201, host: 12201, protocol: 'tcp', auto_correct: true
  config.vm.network :forwarded_port, guest: 12900, host: 12900

end
