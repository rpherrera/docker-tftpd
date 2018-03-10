# README

## Introduction

This Dockerfile provides you a simple tftpd daemon. The directory "/tftpdboot" from Host filesystem is exposed as a volume and you can mount it in order to get your files properly served. Only the UDP/69 port is exposed.

Both virtual machine and tftpd container were combined in order to ease the process of unbricking some old TP-Link routers (i.e.: TL-WDR3600 and TL-WR841ND), since they look for a specific IP addresse (`192.168.0.66`) after a hard reset (a.k.a. 30/30/30). But hey: you can still use it as your own tftpd server, so the default virtual machine is `tftp_server`.

## Testing the tftpd daemon

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

4. Try resolving the route:

```
$ ip route get 192.168.10.100
192.168.10.100 dev en0  src 192.168.1.34
```

5. Put the file(s) you would like to transfer (e.g.: `wr841nv10_tp_recovery.bin`) right into the `tftpboot` directory:

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

## Testing the TP-Link router unbricker

Please notice this procedure was tested in the following TP-Link routers and it can no longer in different models:

- TL-WDR3600
- TL-WR841ND

1. Bring the right virtual machine up:

```
$ vagrant up tplink-unbricker
```

2. Choose an interface you want the VM gets bridged to (here `1` was chosen):

```
==> tp-link: Available bridged network interfaces:
1) en0: Wi-Fi (AirPort)
2) p2p0
3) awdl0
4) en1: Thunderbolt 1
5) en2: Thunderbolt 2
6) bridge0
==> tplink-unbricker: When choosing an interface, it is usually the one that is
==> tplink-unbricker: being used to connect to the internet.
    tplink-unbricker: Which interface should the network bridge to? 1
```

3. Make sure your machine (`192.168.1.34` in this example) has the network configured with a netmask compatible (`192.168.0.0/16` or `255.255.0.0`) with the virtual machine (`192.168.0.66`) you just launched:

```
$ ip route show
default via 192.168.1.1 dev en0
192.168.0.0/16 dev en0  scope link
```

4. Try resolving the route:

```
$ ip route get 192.168.0.66
192.168.0.66 dev en0  src 192.168.1.34
```

5. Put the file(s) you would like to transfer (e.g.: `wr841nv10_tp_recovery.bin`) right into the `tftpboot` directory:

```
cp wr841nv10_tp_recovery.bin ./tftpboot
```

6. Connect into your tftpd virtual machine IP address and try to retrieve the file you need:

```
$ tftp
tftp> connect 192.168.0.66
tftp> get wr841nv10_tp_recovery.bin
Received 4089437 bytes in 0.9 seconds
tftp> quit
```

7. Now you can be confident that after a hard reset (30/30/30) your router might be unbricked with more confidence and without any major networking hassles. Just remember that some routers (i.e.: TL-WDR3600, TL-WR841ND, etc) may demand you to configure your `tftpd` server IP address to `192.168.0.66`, so once the routers bootup this is the address they are going to look for a firmware, using their own tftp clients, which by the way comes builtin in their "recovery-mode".

## External References

 - [Docker Hub Repository](https://hub.docker.com/r/herrera/tftpd/)

## Author

Rafael de Paula Herrera [<herrera.rp@gmail.com>](mailto:herrera.rp@gmail.com)

XMR: `46vBhfyQMMM2vu2HHNVonb4ZH3z92kAvVSvfxctEP9Kr12xPANBvwEP4NPkLfbWXDcMsvJVXwkscn48gcUAv4hBZJuFXhYS`

BTC: `1boderQndxMt81ZR994WN3k6KsrEZcYkG`