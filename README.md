# README

## Introduction

This Dockerfile provides you a simple tftpd daemon. The directory "/tftpdboot" from Host filesystem is exposed as a volume and you can mount it in order to get your files properly served. Only the UDP/69 port is exposed.

Both virtual machine and tftpd container were combined in order to ease the process of unbricking some old TP-Link routers (i.e.: TL-WDR3600 and TL-WR841ND), since they look for a specific IP address (`192.168.0.66`) after a [hard reset (a.k.a. 30/30/30)](https://www.dd-wrt.com/wiki/index.php/Hard_reset_or_30/30/30). But hey: you can still use it as your own tftpd server, so the default virtual machine is `tftp_server`.

## Pre-Requisites

1. [Vagrant](https://www.vagrantup.com/)

2. [Docker](https://www.docker.com/): only if you want to [build/run] the Docker [image/container] locally.

## Bringing up the Virtual Machines

Currently there are 2 pre-configured Vagrant virtual machines:

- `tftpd-server`: General purpose tftpd server, you can use it in order to test the tftpd Docker container and see how it works before you decide to put it into production.

- `tplink-unbricker`: A tftpd server configured to serve as an unbricker to your bricked TP-Link routers (model TL-WDR3600 and TL-WR841ND). Maybe it can be used to unbrick more models from the TP-Link family. Any pull request regarding this would be more than welcomed.

## Testing the tftpd Daemon (tftpd-server)

1. Let's boot our default virtual machine:

```
$ vagrant up
```

2. Choose an interface you want the VM gets bridged to (here `1` was chosen):

```
==> tftpd-server: Available bridged network interfaces:
1) en0: Wi-Fi (AirPort)
2) p2p0
3) awdl0
4) en1: Thunderbolt 1
5) en2: Thunderbolt 2
6) bridge0
==> tftpd-server: When choosing an interface, it is usually the one that is
==> tftpd-server: being used to connect to the internet.
    tftpd-server: Which interface should the network bridge to? 1
```

3. Make sure your machine (`192.168.1.34` in this example) has the network configured with a netmask compatible (`192.168.0.0/16` or `255.255.0.0`) with the virtual machine (`192.168.10.100`) you just launched:

```
$ ip route show
default via 192.168.1.1 dev en0
192.168.10.0/16 dev en0  scope link
```

See if you have that entries or something like this (but consider your network configuration).

4. Network Routing and Troubleshooting

  4.1. Try resolving the route:

```
$ ip route get 192.168.10.100
192.168.10.100 dev en0  src 192.168.1.34
```

If you can route to IP address `192.168.10.100` then we are good.

  4.2. Try to just 3 packets as a ping to the IP address `192.168.10.100`:

```
ping -c3 192.168.10.100
PING 192.168.10.100 (192.168.10.100): 56 data bytes
64 bytes from 192.168.10.100: icmp_seq=0 ttl=64 time=0.289 ms
64 bytes from 192.168.10.100: icmp_seq=1 ttl=64 time=0.416 ms
64 bytes from 192.168.10.100: icmp_seq=2 ttl=64 time=0.680 ms

--- 192.168.10.100 ping statistics ---
3 packets transmitted, 3 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 0.289/0.462/0.680/0.163 ms
```

If you can ping the IP Address `192.168.10.100` then we are good.

  4.3. Reaching the VM network:

If you could neither route nor ping the IP address `192.168.10.100` then you can try to set the netmask properly:

```
$ sudo ip address add 192.168.1.34/16 dev en0
```

Try again (4.1), (4.2) and see if that works for you.

5. Put the file(s) you would like to transfer (e.g.: `wdr3600v1_tp_recovery.bin`, `wr841nv10_tp_recovery.bin`, etc) right into the `tftpboot` directory:

```
cp wr841nv10_tp_recovery.bin ./tftpboot
```

6. Connect into your tftpd virtual machine IP address and try to retrieve the file you need:

```
$ tftp
tftp> connect 192.168.10.100
tftp> get wr841nv10_tp_recovery.bin
Received 4089437 bytes in 0.9 seconds
tftp> quit
```

7. If you were able to transfer the file from the `tftpd` server into the current directory at Host machine, then we are good and you can proceed as usual serving your files the way you want with tftpd container.

## Testing the TP-Link Router Unbricker (tplink-unbricker)

Please notice this procedure was tested in the following TP-Link routers only and it can no longer works for different models:

- TL-WDR3600
- TL-WR841ND

1. Bring the right virtual machine up:

```
$ vagrant up tplink-unbricker
```

2. Choose an interface you want the VM gets bridged to (here `1` was chosen):

```
==> tplink-unbricker: Available bridged network interfaces:
==> tplink-unbricker: Available bridged network interfaces:
1) en0: Wi-Fi (AirPort)
2) en3: Thunderbolt Ethernet
3) p2p0
4) awdl0
5) en1: Thunderbolt 1
6) en2: Thunderbolt 2
7) bridge0
==> tplink-unbricker: When choosing an interface, it is usually the one that is
==> tplink-unbricker: being used to connect to the internet.
    tplink-unbricker: Which interface should the network bridge to? 2
```

3. SSH into VM:

```
vagrant ssh tplink-unbricker
```

5. Put the file(s) you would like to transfer (e.g.: `wr841nv10_tp_recovery.bin` or `wdr3600v1_tp_recovery.bin`) right into the `tftpboot` directory:

```
cp /vagrant/firmwares/wdr3600v1_tp_recovery.bin /vagrant/tftpboot
```

Pay attention to `/vagrant/firmwares` directory: here we assume you have downloaded your firmware and already put the `.bin` file there (which in our example is `wr841nv10_tp_recovery.bin`). So this step is up to you and you should find any firmware you like. After some trials and errors, we just found that the unbrick process always worked on `TL-WDR3600` when used [this dd-wrt image: `factory-to-ddwrt.bin`](https://www.dd-wrt.com/routerdb/de/download/TP-Link/TL-WDR3600/v1.x/factory-to-ddwrt.bin/4129) as firmware image (MD5: `7ae4f25869bd85bc6f12921aa508e143`).

6. Inspect traffic through `tcpdump`:

```
sudo tcpdump -i eth1 -n udp port 69
```

7. Perform the [Hard Reset or 30/30/30](https://www.dd-wrt.com/wiki/index.php/Hard_reset_or_30/30/30) on your router. Usually you will need to:

7.1. Power on the router
7.2. Press the WPS button and keep holding
7.3. Wait for at least 30 seconds
7.4. Power off the router by disconnecting its power chord supply
7.5. Wait for at least 30 seconds
7.6. Power on the router by connecting its power chord supply
7.7. Wait for at least 30 seconds

8. Keep an eye in `tcpdump` output and check if there are log entries like this:

```
01:27:21.321957 IP 192.168.0.86.3511 > 192.168.0.66.69:  44 RRQ "wdr3600v1_tp_recovery.bin" octet timeout 5
```

If so, that means your router is looking for `wdr3600v1_tp_recovery.bin` file inside your `tftpd` server, so please just double-check and make sure you have put the right file into the `tftpboot` directory.

When the firmware file is found successfully, the router downloads it and start re-flashing itself, so look at the update led that should be blinking for a while. If the re-flash process runs smootlhy the router will reboot itself and then after the power up it gets running as usual according to the default behavior found in the firmware you provided.

Warning: If all router led lights are now in a state of non-stop blinking it means that the re-flashing processes has failed, so you will have to provide another firmware as your recovery file to `tftpd` (step 5) and start over again the 30/30/30 (step 7).

## External References

 - [GitHub `rpherrera/docker-tftpd`](https://github.com/rpherrera/docker-tftpd)
 - [DockerHub `herrera/tftpd`](https://hub.docker.com/r/herrera/tftpd/)
 - [Hard Reset or 30/30/30](https://www.dd-wrt.com/wiki/index.php/Hard_reset_or_30/30/30)
 - [Vagrant](https://www.vagrantup.com/)
 - [Docker](https://www.docker.com/)
 - [Docker Hub Repository](https://hub.docker.com/r/herrera/tftpd/)
 - [TL-WDR3600 - Download the Official Firmware](https://www.tp-link.com/br/download/TL-WDR3600.html#Firmware)
 - [TL-WDR3600 - TFTP Auto Recovery (Old Wiki)](https://wiki.openwrt.org/toh/tp-link/tl-wdr3600#tftp_auto_recovery_in_revision_15)
 - [TL-WDR3600 - TFTP Auto Recovery (New Wiki)](https://openwrt.org/toh/tp-link/tl-wdr3600#tftp_auto_recovery_in_revision_15)
 - [TL-WR841ND - Download the Official Firmware](https://www.tp-link.com/br/download/TL-WR841ND.html#Firmware)
 - [TL-WR841ND - TFTP Recovery via Bootloader (Old Wiki)](https://wiki.openwrt.org/toh/tp-link/tl-wr841nd#tftp_recovery_via_bootloader_for_v8_v9_v10_v11_v12)
 - [TL-WR841ND - TFTP Recovery via Bootloader (New Wiki)](https://openwrt.org/toh/tp-link/tl-wr841nd#tftp_recovery_via_bootloader_for_v8_v9_v10_v11_v12)
 - [Firmware Image that always worked on `TL-WDR3600`: `factory-to-ddwrt.bin` (MD5: `7ae4f25869bd85bc6f12921aa508e143`)](https://www.dd-wrt.com/routerdb/de/download/TP-Link/TL-WDR3600/v1.x/factory-to-ddwrt.bin/4129)

## Author

Rafael de Paula Herrera [<herrera.rp@gmail.com>](mailto:herrera.rp@gmail.com)

XMR: `46vBhfyQMMM2vu2HHNVonb4ZH3z92kAvVSvfxctEP9Kr12xPANBvwEP4NPkLfbWXDcMsvJVXwkscn48gcUAv4hBZJuFXhYS`

BTC: `1boderQndxMt81ZR994WN3k6KsrEZcYkG`