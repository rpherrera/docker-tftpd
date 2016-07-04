# -*- mode: ruby -*-
# vi: set ft=ruby :

# Notes:
#
# 1.  This is a Vagrantfile example that can be used to serve firmwares to some
# routers from TP-Link family (e.g.: TL-WDR3600 or TL-WR841ND) after the
# 30/30/30 process. It uses the tftpd as a Docker container to serve the files
# placed under the './tftpboot' local directory.
#
# 2.1.  Please note that you must keep installed the same Virtual Box guest
# additions version into both Host and Guest systems. So do yourself a favor and
# install the 'vagrant-vbguest' plugin before running 'vagrant up':
#     $ vagrant plugin install vagrant-vbguest
# 2.2.  You should see a successfully output like this:
#     Installing the 'vagrant-vbguest' plugin. This can take a few minutes...
#     Installed the plugin 'vagrant-vbguest (0.12.0)'!

Vagrant.configure('2') do |config|
    config.vm.box = 'ubuntu/xenial64'

    config.vm.provider 'virtualbox' do |vbox|
        vbox.customize ['modifyvm', :id, '--ioapic', 'on']
        vbox.cpus = 4
        vbox.memory = 1024
    end

    config.vm.network 'private_network', ip: '192.168.0.66'

    config.vm.synced_folder "./tftpboot/", "/vagrant/tftpboot", owner: "ubuntu", group: "ubuntu"

    config.vm.provision 'docker' do |docker|
      docker.run 'tftpd', image: 'herrera/tftpd:1.0.0', args: '-v /vagrant/tftpboot:/tftpboot -p 69:69/udp'
    end
end
