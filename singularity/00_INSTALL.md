## Install

Here we will install the latest tagged release from [GitHub](https://github.com/singularityware/singularity). If you prefer to install a different version or to install Singularity in a different location, see these [INSTALL.md](https://github.com/sylabs/singularity/blob/master/INSTALL.md)

### Install golang
This is one of several ways to [install and configure golang](https://golang.org/doc/install).

First, visit the [golang download page](https://golang.org/dl/) and pick a
package archive to download.  Copy the link address and download with `wget`.

```
$ export VERSION=1.12 OS=linux ARCH=amd64
$ cd /tmp
$ wget https://dl.google.com/go/go$VERSION.$OS-$ARCH.tar.gz
```

Then extract the archive to `/usr/local` (or use other instructions on go
installation page).

```
$ sudo tar -C /usr/local -xzf go$VERSION.$OS-$ARCH.tar.gz
```

Finally, set up your environment for go

```
$ echo 'export GOPATH=${HOME}/go' >> ~/.bashrc
$ echo 'export PATH=/usr/local/go/bin:${PATH}:${GOPATH}/bin' >> ~/.bashrc
$ source ~/.bashrc
```
### Install singularity from source

We're going to compile Singularity from source code.  First we'll need to make sure we have some development tools installed so that we can do that.  On Ubuntu, run these commands to make sure you have all the necessary packages installed.

ON a DEB based OS, these commmands should get you up to speed:

```
$ sudo apt-get update && sudo apt-get install -y build-essential libssl-dev uuid-dev libgpgme11-dev squashfs-tools libseccomp-dev
```

On RPM based OS's, these commmands should get you up to speed.

```
$ sudo yum update

$ sudo yum groupinstall 'Development Tools'

$ sudo yum install libtool libarchive-devel openssl-devel libuuid-devel libseccomp-devel
```

now clone the repo and build the source code

```
git clone https://github.com/sylabs/singularity.git
```

Finally it's time to build and install!

```
$ cd singularity

$ ./mconfig -p /usr/local

$ make -C builddir/ -j$(nrpoc)

$ sudo make -C builddir/ install
```

If you want support for tab completion of Singularity commands, you need to source the appropriate file and add it to the bash completion directory in `/etc` so that it will be sourced automatically when you start another shell.

```
$ source /usr/local/etc/bash_completion.d/singularity
```

If everything went according to plan, you now have a working installation of Singularity.  You can test your installation like so:

```
$ singularity run library://sylabsed/examples/lolcow:latest
```

You should see something like the following.

```
_________________________________________
/ Of course you have a purpose -- to find \
\ a purpose.                              /
 -----------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

Your cow will likely say something different (and be more colorful), but as long as you see a cow your installation is working properly.

This command downloads and runs a container from [Sylabs Library](https://cloud.sylabs.io/library/_container/5b9e91c694feb900016ea40b).  During this tutorial we will learn how to build a similar container from scratch.

### Install image buidling dependencies
You may want to build images from their official repositories like debootstrap, yum or zypper, you "may" need to install these depending on the OS you are

e.g
if you get the following error
```
vagrant@ubuntu-bionic:~$ sudo singularity build --sandbox lolcow deffiles/Singularity
WARNING: Authentication token file not found : Only pulls of public images will succeed
INFO:    Starting build...
FATAL:   While performing build: conveyor failed to get: debootstrap is not in PATH... Perhaps 'apt-get install' it: exec: "debootstrap": executable file not found in $PATH
```

that means that your host doesn't have debootstrap installed, but you are trying to run a build from it, so you need to install it in order to proceed with your build.

```
sudo apt-get install debootstrap
```
