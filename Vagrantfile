# -*- mode: ruby -*-
# vi: set ft=ruby :

# This is a Vagrantfile example that can be used to serve firmwares to some
# routers from TP-Link family (e.g.: TL-WDR3600 or TL-WR841ND) right after they
# being hard reset (also known as 30/30/30 procedure). It uses tftpd as a Docker
# container to serve files placed under '/vagrant/tftpboot' directory from Host system.

ENV["LC_ALL"] = "en_US.UTF-8"

def configure_machine(config:, cpus:, memory:, ip_address:, netmask_bits:, hostname:, name:)
  config.vm.box = "bento/ubuntu-16.04"
  config.vm.boot_timeout = 360

  config.vm.hostname = hostname
  config.vm.network "public_network", use_dhcp_assigned_default_route: true, ip: ip_address
  config.vm.provision "shell", inline: "ip address flush dev eth1 && ip address add #{ip_address}/#{netmask_bits} dev eth1", preserve_order: true, run: "always"

  config.vm.provider "virtualbox"

  config.ssh.shell = "bash"
  config.vm.provision "shell", path: "bin/provision.sh", preserve_order: true, run: "once"
  config.vm.provision "shell", path: "bin/docker-run.sh", preserve_order: true, run: "always"

  config.vm.provider :virtualbox do |vbx|
    vbx.name = name
    vbx.gui = true
    vbx.linked_clone = true

    vbx.memory = memory
    vbx.cpus = cpus
    vbx.customize ["modifyvm", :id, "--ioapic", "on"]
  end
end

Vagrant.configure("2") do |config|
  config.vm.define "tftpd-server" do |tftpd_server|
    configure_machine(
      config: tftpd_server,
      cpus: 1,
      memory: 256,
      ip_address: "192.168.10.100",
      netmask_bits: "16",
      hostname: "tftpd-server",
      name: "tftpd - Default Server"
    )
  end

  config.vm.define "tplink-unbricker", autostart: false do |tplink_unbricker|
    configure_machine(
      config: tplink_unbricker,
      cpus: 1,
      memory: 256,
      ip_address: "192.168.0.66",
      netmask_bits: "16",
      hostname: "tplink-unbricker",
      name: "tftpd - TP-Link Unbricker"
    )
  end
end