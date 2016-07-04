# README

## Introduction

This Dockerfile provides you a simple tftpd daemon. The directory "/tftpdboot" from filesystem is exposed as a volume and you can mount it in order to get your files properly served. Only the UDP/69 port is exposed.

## Usage Examples

There are 2 usage examples and they came from distinct phases from the project development. While the first one (called "Host to Guest Communication") aims the general public and it is more simple and straight forward in a sense of stack usage, the second one (called "Inter-Containers Communication") aims to provide the first steps from a troubleshooting guidance.

The motivations behind "Host to Guest Communication" resembles the fact that Docker experimental release (1.12.0-rc2) for Mac OS X did not supported network bridging and this made unfeasible to employ advanced network routing to/from containers, even using PF, so in order to circumvent this situation and be capable of properly serving firmwares, the tftpd Docker container was embedded into a Vagrant Virtual Machine using Virtual Box driver. It is being setup with an IP address (192.168.0.66) where some TP-Link routers (tested models are TL-WDR3600 or TL-WR841ND) expect to find rescue firmware files by means of tftp protocol (UDP/69) after being hard reset (also known as 30/30/30 procedure).

### Host to Guest Communication



### Inter-Docker Communication

Please remember that you are encouraged to mount a local directory that you want to serve right into the exposed volume, so first make sure to create this directory first and fill it with your files:

```
$ mkdir /home/user/tftpboot
$ echo testing-00 > /home/user/file-00.txt
```

Start tftpd as a docker container mounting some of local directory into the exposed volume and optionally bind the host UDP/69 port directly to it:

```
$ docker run -d -v /home/user/tftpboot:/tftpboot -p 69:69/udp -p 69:69 herrera/tftpd:1.0.0
c57e33f60993e806392d96542b71f35f3692d1f74e8c981a33776e2721b6d735
```

Now get the started container IP address based on the shortened version from its ID (provided as output from the previous command) and take note:

```
$ docker inspect -f '{{ .NetworkSettings.IPAddress }}' c57e33
172.17.0.2
```

Start another container using interactive mode, which will be our client for testing purposes:

```
$ docker run --rm --entrypoint sh -it herrera/tftpd:1.0.0
```

Verify the filesystem contents:

```
/ # ls
bin       etc       lib       media     proc      run       srv       tftpboot  usr
dev       home      linuxrc   mnt       root      sbin      sys       tmp       var
```

Connect to the tftpd server and download the testing file:
```
/ # tftp 172.17.0.2 -c get file-00.txt
```

Verify the filesystem contents and note the testing file was successfully retrieved:
```
/ # ls
bin       etc       lib       media     proc      run       srv       tftpboot  usr       file-00.txt
dev       home      linuxrc   mnt       root      sbin      sys       tmp       var
```

View the testing file contents:
```
/ # cat file-00.txt
testing-00
```

Exit destroying the client container (since we started it with the "--rm" option):
```
/ # exit
```

Kill the server container and remove its data traces:
```
$ docker kill c57e33 && docker rm -v c57e33
c57e33f60993
c57e33f60993
```

## External References

 - [Docker Hub Repository](https://hub.docker.com/r/herrera/tftpd/)
