# Creating Singularity container images via EasyBuild

To learn how you can use EasyBuild in a Singularity container recipe, read
the [Using EasyBuild in Singularity container recipes](#using_easybuild_in_singularity_container_recipes) section.

**To take a shortcut and learn how you can *generate* Singularity container recipes (that use EasyBuild to install software),
skip ahead to the [Generating Singularity container recipes using EasyBuild](#generating_singularity_container_recipes_using_easybuild) section.**

---

<a name="using_easybuild_in_singularity_container_recipes"></a>
## Using EasyBuild in Singularity container recipes

In this tutorial, we will focus on building Singularity container images using CentOS 7.

Hence, we start the container recipe with:

```
Bootstrap: yum
OSVersion: 7
MirrorURL: http://mirror.centos.org/centos-%{OSVERSION}/%{OSVERSION}/os/x86_64/
Include: yum
```

#### Installing requirements

To install the EasyBuild requirements we include ``yum install`` commands in the ``%post`` section, as follows:

```
% post

# EPEL is required for Lmod
yum install -y epel-release

# EasyBuild requirements + pip Python installation tool
yum install -y python setuptools Lmod python-pip

# various utilities
yum install -y bzip2 gzip tar zip unzip xz patch make file git which

# C/C++ compiler (for building GCC) + Perl modules (required for building Autotools)
yum install -y gcc-c++ perl-Data-Dumper perl-Thread-Queue

# OpenSSL (for CMake, Python) + Infiniband support libraries (for OpenMPI)
yum install -y rdma-core-devel
yum install -y openssl-devel
```

#### Installing EasyBuild

Installing EasyBuild can be done using the ``pip`` Python installation tool, also in the ``%post`` section:

```
# install EasyBuild using pip
pip install 'vsc-install<0.11.4' 'vsc-base<2.9.0'
pip install easybuild
```

*(We pre-install a slightly older version of the ``vsc-install`` and ``vsc-base`` Python packages required by EasyBuild here
to avoid problems with some additional Python packages that are required for the most recent versions of ``vsc-install`` and ``vsc-base``.)*

#### Create non-root user

It is strongly discouraged to run EasyBuild using the ``root`` user, so we also create a dedicated ``easybuild`` user.

In addtion, we create two directories in the container to which this user has write permissions.

```
useradd easybuild

mkdir -p /app /scratch
chown easybuild:easybuild -R /app /scratch
```

#### Lmod configuration

We install a system-wide configuration file for Lmod, in which we specify that
``/app/lmodcache`` should be used as location for the Lmod 'spider' cache:

```
cat > /etc/lmodrc.lua << EOF
scDescriptT = {
  {
    ["dir"]       = "/app/lmodcache",
    ["timestamp"] = "/app/lmodcache/timestamp",
  },
}
EOF
```

#### Switching to ``easybuild`` user and configuring EasyBuild

We now switch to the dedicated ``easybuild`` user, and configure EasyBuild to use the prepared directories, as follows:

```
# change to 'easybuild' user
su - easybuild

# use /scratch as general prefix, used for sources, build directories, etc.
export EASYBUILD_PREFIX=/scratch

# install software & modules into /app/{software,modules}
export EASYBUILD_INSTALLPATH=/app
```

#### Install software and update Lmod cache

Now we are ready to install software using EasyBuild in the container.
We simply specify one or more easyconfig files to the ``eb`` command, and use ``--robot`` to enabled the dependency resolution mechanism:


```
eb cowsay-3.04.eb --robot
```

We also instruct Lmod to update its (system-wide) cache, to ensure that the newly installed module(s) can be picked up
via ``module avail`` and ``module load``:

```
mkdir -p /app/lmodcache
$LMOD_DIR/update_lmod_system_cache_files -d /app/lmodcache -t /app/lmodcache/timestamp /app/modules/all
```

#### Cleanup

To conclude the ``%post`` section, we clean up the ``/scratch`` directory (which should only contain temporary files and directories at this point):

```
# exit from 'easybuild' user
exit

# cleanup, everything in /scratch is assumed to be temporary
rm -rf /scratch/*
```

#### Setting up the environment in the container

To ensure a good user experience, we need to also populate the ``%environment`` section.

First, we make sure that Lmod was properly initialised, by sourcing ``/etc/profile``:

```
%environment

# make sure that 'module' and 'ml' commands are defined
source /etc/profile
```

Next up, we make sure that no (loaded) module files from outside the container are picked up,
by purging all loaded modules and clear ``$MODULEPATH``:


```
# purge any modules that may be loaded outside container
module --force purge
# avoid picking up modules from outside of container
module unuse $MODULEPATH
```

Finally, we load the installed modules:

```
# pick up modules installed in /app
module use /app/modules/all

# load module(s) corresponding to installed software
module load cowsay/3.04
```

---

<a name="generating_singularity_container_recipes_using_easybuild"></a>
## Generating Singularity container recipes using EasyBuild

*(note: this tutorial assumes you are using EasyBuild v3.9.2 or later)*

Rather than manually constructing a Singularity container recipe that leverages EasyBuild to install software,
you can use EasyBuild to generate such it!

See also https://easybuild.readthedocs.io/en/latest/Containers.html .

#### History

Experimental support for generating Singulartiy container recipes/images is available since EasyBuild v3.6.0.

In EasyBuild v3.6.2, this functionality was extended to also support Docker containers.

Integration with Singularity was significantly enhanced in EasyBuild v3.9.2.

---

**The current support in EasyBuild to generate container recipes/images is still experimental,
which means it is subject to change in future EasyBuild versions.**

**You will need enable the use of experimental functionality in EasyBuild by configuring it accordingly,
for example by setting the ``$EASYBUILD_EXPERIMENTAL`` environment variable:**

```
export EASYBUILD_EXPERIMENTAL=1
```

**or by using ``eb --experimental``. The sections below assume that this has been taken into account.**

---

### Basics of Singularity integration in EasyBuild

To instruct EasyBuild to generate a container recipe, you should use the ``--containerize`` command line option,
or simply use ``eb -C`` for short.

By default, this will make EasyBuild generate a *Singularity container recipe*
(rather than installing the specified software as it normally would).

### Container configuration

Using the ``--container-config`` EasyBuild configuration option, you can specify several aspects that will be taken
into account in the generated container recipe.

The value passed to ``--container-config`` is currently expected to be a comma-separated list of ``<keyword>=<value>`` pairs.

It is mandatory to specify which *bootstrap agent* to use via the ``bootstrap`` keyword.

Two types are supported: distro bootstrap agents and image-based bootstrap agents.

#### Distro bootstrap agents

To build a container image from scratch, you can specify which Linux distribution you would like to use in the container.

This can be done by specifying a value for the ``bootstrap`` keyword in the value passed to ``--container-config``.

A variety of different Linux distributions is supported, **but currently only ``yum``-based distributions are
well supported in EasyBuild.** Therefore, we will only use ``bootstrap=yum`` in the value passed to ``--container-config``.

A number of additional keywords can be specified to control, mainly to control which exact Linux distribution will be used.
Here, we will only use ``osversion`` to specify the OS version; we rely on the default value for ``mirrorurl`` which
corresponds to CentOS.

#### Image-based bootstrap agents

To build a container image using an existing container image as a base, you can use one of the following bootstrap agents:

* ``localimage``, to use a locally available container image as a base
* ``docker``, ``library`` or ``shub`` to use a base container image that is available on Docker Hub, the Sylabs Container Library or Singularity Hub

In this tutorial, we will only use ``localimage``.

Using any of these requires to also specify a location of the base container image to use via the ``from`` keyword.

#### Additional keywords

A number of additional keywords can be specified through ``--container-config`` to control different parts
of the generated container recipe, but we will not used them here.

Please refer to the [EasyBuild documentation](https://easybuild.readthedocs.io/en/latest/Containers.html#container-configuration-container-config) for more details.

### Example

Example container configurations:

* to build a container image from scratch using (the latest) CentOS 7
```
eb -C --container-config bootstrap=yum,osversion=7 ...
```
* to build a container image using the container image available at ``/containers/example.sif`` as a base
```
eb -C --container-config bootstrap=localimage,from=/containers/example.sif ...
```

### Providing a custom template container recipe

EasyBuild supports providing a custom template container recipe file via ``--container-template-recipe``,
which can be useful if some specifications of the template used by default are hard to control via ``--container-config``.

For more details, please refer to the [EasyBuild documentation](https://easybuild.readthedocs.io/en/latest/Containers.html#container-template-recipe-container-template-recipe).

### Building Singularity container images through EasyBuild

If the ``--container-build-image`` option is specified together with ``eb --containerize`` (or ``eb -C``), then
EasyBuild will leverage ``singularity build`` to also build a container image using the generated container recipe.

Since ``singularity build`` required admin permissions it will be run via the ``sudo`` command, and hence you may need
to enter a password (depending on your system configuration):

```
$ eb -C --container-config bootstrap=yum,osversion=7 cowsay-3.04.eb --container-build-image
== temporary log file in case of crash /tmp/eb-m8GOdr/easybuild-rdYTPD.log

== singularity tool found at /usr/local/bin/singularity
== singularity version '3.2.1' is 2.4 or higher ... OK
== sudo tool found at /usr/bin/sudo
== Singularity definition file created at /home/example/containers/Singularity.cowsay-3.04
== Running 'sudo  /usr/local/bin/singularity build /home/example/containers/cowsay-3.04.sif /home/example/containers/Singularity.cowsay-3.04', you may need to enter your 'sudo' password...
== (streaming) output for command 'sudo  /usr/local/bin/singularity build  /home/example/containers/cowsay-3.04.sif /home/example/containers/Singularity.cowsay-3.04':
INFO:    Starting build...
...
```

### Seeding in source files

The Singularity container recipes generated by EasyBuild allow for seeding in source files via ``/tmp/easybuild/sources``,
since this location is included in the ``sourcepath`` configuration setting inside the container as a fallback path
(any source files that are downloaded are stored in ``/scratch/sources`` during the container build).

### Example: creating a Singularity container image for TensorFlow

Creating a Singularity container image for TensorFlow is now trivial thanks to EasyBuild:

```
eb -C --container-config bootstrap=yum,osversion=7 TensorFlow-1.13.1-foss-2019a-Python-3.7.2.eb --container-build-image
```

However, since starting from scratch implies that all required dependencies, including the compiler toolchain,
will need to be installed, it makes sense to take a more *step-wise approach*. Not only does this help with
avoiding lots of time in case the container build process was interrupted, we can also re-use the different
container images we obtain as a base for building other container images.

For example, we can start by creating a base container image from scratch for the ``foss/2019a`` compiler toolchain:

```
eb -C --container-config bootstrap=yum,osversion=7 foss-2019a.eb --container-build-image
```

Assuming that EasyBuild is configured to store container recipes/images in ``$HOME/containers``,
this should eventually result in a Singularity container image ``$HOME/containers/foss-2019a.sif``.

We can then proceed by creating a new container image using ``foss-2019a.sif`` as a base,
for example for the ``SciPy-bundle`` dependency required by TensorFlow:

```
eb -C --container-config bootstrap=localimage,from=$HOME/containers/foss-2019a.sif SciPy-bundle-2019.03-foss-2019a.eb --container-build-image
```

Once this container image is created, we can use this in turn to build our desired TensorFlow container image:

```
eb -C --container-config bootstrap=localimage,from=$HOME/containers/SciPy-bundle-2019.03-foss-2019a.sif TensorFlow-1.13.1-foss-2019a-Python-3.7.2.eb
```

After a while, this should produce ``HOME/containers/TensorFlow-1.13.1-foss-2019a-Python-3.7.2.sif``.

**Note: to run the last command successfully, you currently need to seed in the source file for Java/1.8 via ``/tmp/easybuild/sources``,
since this is required for installing the ``Bazel`` installation tool that is a build dependency for TensorFlow:**

```
cp $HOME/sources/j/Java/jdk-8u212-linux-x64.tar.gz /tmp/easybuild/sources/
```

### Known limitations

* hardcoded ``yum install`` commands (regardless of Linux distribution being used)
* missing container description/labels
* access to EasyBuild log files for failing installations is still problematic
* no effort was made yet to limit the size of the container images (build-only dependencies, installation logs, ...)
* track for which processor architecture the container image was built?

See also https://github.com/easybuilders/easybuild-framework/labels/containers .

---

For more information, see https://easybuild.readthedocs.io/en/latest/Containers.html .
