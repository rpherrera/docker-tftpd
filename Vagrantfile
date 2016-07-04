# -*- mode: ruby -*-
# vi: set ft=ruby :

# Notes:
#
# 1.  This is a Vagrantfile example that can be used to serve firmwares to some
# routers from TP-Link family (e.g.: TL-WDR3600 or TL-WR841ND) right after they
# being hard reset (also known as 30/30/30 procedure). It uses tftpd as a Docker
# container to serve files placed under './tftpboot' directory from Host system.
#
# 2.  You must keep installed the same version from Virtual Box guest additions
# into both Host and Guest systems. So, please do yourself a favor and before
# running 'vagrant up' command install the 'vagrant-vbguest' plugin by means of:
#     $ vagrant plugin install vagrant-vbguest

Vagrant.configure('2') do |config|
    config.vm.box = 'ubuntu/xenial64'

    config.vm.provider 'virtualbox' do |vbox|
        vbox.customize ['modifyvm', :id, '--ioapic', 'on']
        vbox.cpus = 4
        vbox.memory = 1024
    end

    config.vm.network 'private_network', ip: '192.168.0.66'

    config.vm.synced_folder "tftpboot", "/vagrant/tftpboot"

    config.vm.provision 'docker' do |docker|
      docker.run 'tftpd', image: 'herrera/tftpd:1.0.0', args: '-v /vagrant/tftpboot:/tftpboot -p 69:69/udp'
    end
end
