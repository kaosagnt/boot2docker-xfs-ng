# Boot2Docker-XFS-ng

NOTE: This is a fork from the original https://github.com/boot2docker/boot2docker/

It uses TCL (TinyCore Linux 15.x) and the XFS filesystem by default.

Boot2Docker is a lightweight Linux distribution made specifically to run
[Docker](https://www.docker.com/) containers. It runs completely from RAM, is a
~95MB download and boots quickly.

## Important Note

Boot2Docker is officially in **maintenance mode** -- it is recommended that users transition from Boot2Docker over to [Docker for Mac](https://www.docker.com/docker-mac) or [Docker for Windows](https://www.docker.com/docker-windows) instead.

What this means concretely is new Docker releases, kernel updates, etc, but concerted attempts to keep new features/functionality to an absolute minimum to ensure continued maintainability for the few folks who can't yet transition to the better-suited Docker for Windows / Docker for Mac products (Windows 7 users who can't Docker for Windows at all, Windows 10 Home users who thus can't Hyper-V, VirtualBox users who thus can't Hyper-V, etc etc).

See [docker/machine#4537](https://github.com/docker/machine/issues/4537) for some useful discussion around Docker Machine also being in a similar state.

## Features

* Recent Linux Kernel, Docker pre-installed and ready-to-use
* Tiny Core Linux 15.x
* CTOP
* XFS filesystem by default. (Will automount exisitng `ext4` filesystems).
* VM guest additions (VirtualBox, VMware, XenServer)
* Container persistence via disk automount on `/var/lib/docker`
* SSH keys persistence via disk automount

> **Note:** Boot2Docker uses port **2376**, the [registered IANA Docker TLS
> port](http://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xhtml?search=docker)

## Caveat Emptor

Boot2Docker is designed and tuned for development.
**Using it for any kind of production workloads is highly discouraged.**

## Installation

Installation should be performed via [Docker Toolbox](https://docs.docker.com/toolbox/)
which installs [Docker Machine](https://docs.docker.com/machine/overview/), 
the Boot2Docker VM, and other necessary tools.

## How to use

Boot2Docker is used via [Docker Machine](https://docs.docker.com/machine/overview/) 
(installed as part of Docker Toolbox) which leverages a Hyperviser Driver to
initialise, start, stop and delete the VM right from the command line.

Machine Hyperviser drivers include:

* Amazon Web Services
* Microsoft Azure
* Digital Ocean
* Exoscale
* Google Compute Engine
*Generic
* Microsoft Hyper-V
* OpenStack
* Rackspace
* IBM Softlayer
* Oracle VirtualBox
* VMware vCloud Air
* VMware Fusion
* VMware vSphere

## More information

See [Frequently asked questions](FAQ.md) for more details.

#### Boot logs

Logs can be found in /var/lib/boot2docker/log/

#### Docker daemon options

If you need to customize the options used to start the Docker daemon, you can
do so by adding entries to the `/var/lib/boot2docker/profile` file on the
persistent partition inside the Boot2Docker virtual machine. Then restart the
daemon.

The following example will enable core dumps inside containers, but you can
specify any other options you may need.

```console
docker-machine ssh default -t sudo vi /var/lib/boot2docker/profile
# Add something like:
#     EXTRA_ARGS="--default-ulimit core=-1"
docker-machine restart default
```

#### Installing secure Registry certificates

As discussed in the [Docker Engine documentation](https://docs.docker.com/engine/security/certificates/#/understanding-the-configuration)
certificates should be placed at `/etc/docker/certs.d/hostname/ca.crt` 
where `hostname` is your Registry server's hostname.

```console
docker-machine scp certfile default:ca.crt
docker-machine ssh default
sudo mv ~/ca.crt /etc/docker/certs.d/hostname/ca.crt
exit
docker-machine restart
```

Alternatively the older Boot2Docker method can be used and you can add your 
Registry server's public certificate (in `.pem` or `.crt` format) into
the `/var/lib/boot2docker/certs/` directory, and Boot2Docker will automatically
load it from the persistence partition at boot.

You may need to add several certificates (as separate `.pem` or `.crt` files) to this
directory, depending on the CA signing chain used for your certificate.

##### Insecure Registry

As of Docker version 1.3.1, if your registry doesn't support HTTPS, you must add it as an
insecure registry.

```console
$ docker-machine ssh default "echo $'EXTRA_ARGS=\"--insecure-registry <YOUR INSECURE HOST>\"' | sudo tee -a /var/lib/boot2docker/profile && sudo /etc/init.d/docker restart"
```

then you should be able to do a docker push/pull.

#### Running behind a VPN (Cisco AnyConnect, etc)

So sometimes if you are behind a VPN, you'll get an `i/o timeout` error.
The current work around is to forward the port in the boot2docker-vm.

If you get an error like the following:

```no-highlight
Sending build context to Docker daemon
2014/11/19 13:53:33 Post https://192.168.59.103:2376/v1.15/build?rm=1&t=your-tag: dial tcp 192.168.59.103:2376: i/o timeout
```

That means you have to forward port `2376`, which can be done like so:

* Open VirtualBox
* Open Settings > Network for your 'default' VM
* Select the adapter that is 'Attached To': 'NAT' and click 'Port Forwarding'.
* Add a new rule:
	- Protocol: TCP
	- Host IP: 127.0.0.1
	- Host Port: 5555
	- Guest Port: 2376
* Set `DOCKER_HOST` to 'tcp://127.0.0.1:5555'

#### SSH into VM

```console
$ docker-machine ssh default
```

Docker Machine auto logs in using the generated SSH key, but if you want to SSH
into the machine manually (or you're not using a Docker Machine managed VM), the
credentials are:

```
user: docker
pass: tcuser
```

#### Persist data

Boot2docker uses [Tiny Core Linux](http://tinycorelinux.net), which runs from
RAM and so does not persist filesystem changes by default.

When you run `docker-machine`, the tool auto-creates a disk that
will be automounted and used to persist your docker data in `/var/lib/docker`
and `/var/lib/boot2docker`.  This virtual disk will be removed when you run
`docker-machine delete default`.  It will also persist the SSH keys of the machine.
Changes outside of these directories will be lost after powering down or
restarting the VM.

If you are not using the Docker Machine management tool, you can create an `ext4`
formatted partition with the label `boot2docker-data` (`mkfs.ext4 -L
boot2docker-data /dev/sdX5`) to your VM or host, and Boot2Docker will automount
it on `/mnt/sdX` and then softlink `/mnt/sdX/var/lib/docker` to
`/var/lib/docker`. The same can be done for an `xfs` partition but with the
disk label `bt2dckr-data` as `xfs` labels cannot be more than 12 characters.
