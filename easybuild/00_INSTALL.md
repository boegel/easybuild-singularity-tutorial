# Installing EasyBuild

## Requirements

- OS: Linux
- Python: Python 2.6 or 2.7 *(support for Python 3 coming soon)*
- Python packages: `setuptools`
- an environment modules tool, [Lmod](https://github.com/TACC/Lmod) is recommended
- various common utilities like `make`, `patch`, `tar`, ...

(see also https://easybuild.readthedocs.io/en/latest/Installation.html#requirements)

To install all requirements on a bare CentOS 7 system:

```
# EPEL is required for Lmod, python-pip packages
yum install -y epel-release

# direct EasyBuild dependencies
yum install -y python setuptools Lmod

# pip is only needed for 'pip install easybuild'
yum install -y python-pip

# various common utilities leveraged by EasyBuild
yum install -y file which git bzip2 gzip tar zip unzip xz patch make

# system C++ compilers (only needed to compile GCC from source)
yum install -y gcc-c++

# additional Perl modules required by Autotools
yum install -y perl-Data-Dumper
yum install -y perl-Thread-Queue

# openssl-devel for SSL support in CMake, Python
yum -y install openssl-devel

# rdma-core-devel is only needed for building OpenMPI with Infiniband support (which is done by default)
yum -y install rdma-core-devel
```

## Installation

(see also https://easybuild.readthedocs.io/en/latest/Installation.html)

### Installion via `pip`

You should be able to install EasyBuild using `pip`, just like any other Python package:

```
sudo pip install easybuild
```

or

```
pip install --user easybuild
```

If you run into problems due to dependencies of the `vsc-install` and/or `vsc-base` packages that get installed
as dependencies, you can install slightly older versions of these first via:

```
pip install 'vsc-install<0.11.4' 'vsc-base<2.9.0'
```

The next major release of EasyBuild (4.0) will no longer depend on `vsc-install` & `vsc-base`.


### Bootstrap installation

If you don't have admin rights to install EasyBuild and prefer not to use `pip`, you can use the
bootstrap installation script to install EasyBuild with EasyBuild, and obtain an `EasyBuild` module to load:


```
curl -O https://raw.githubusercontent.com/easybuilders/easybuild-framework/develop/easybuild/scripts/bootstrap_eb.py

export EASYBUILD_PREFIX=$HOME
python bootstrap_eb.py $EASYBUILD_PREFIX
```

Once the bootstrap installation completes, you can load the `EasyBuild` module and get started:

```
module use $EASYBUILD_PREFIX/modules/all
module load EasyBuild
eb --version
```

See also https://easybuild.readthedocs.io/en/latest/Installation.html#bootstrapping-easybuild.


## Updating EasyBuild

To update EasyBuild, either run `pip install -U easybuild`, or use `eb --install-latest-eb-release` to install an
`EasyBuild` module for the latest version of EasyBuild.

(see also https://easybuild.readthedocs.io/en/latest/Installation.html#updating-an-existing-easybuild-installation)
