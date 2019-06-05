#!/bin/bash

set -e

if [ $# -ne 2 ]; then
    echo "ERROR: Usage: $0 <Singularity version> <installation prefix>" >&2
    exit 1
fi
singularity_version=$1
prefix=$2

singularity_tarball=singularity-${singularity_version}.tar.gz
curl -OL https://github.com/sylabs/singularity/releases/download/v${singularity_version}/$singularity_tarball

TMPDIR=$(mktemp -d)
export GOPATH=$TMPDIR/go

export WORKDIR=$GOPATH/src/github.com/sylabs
mkdir -p $WORKDIR
cp $singularity_tarball $WORKDIR
cd $WORKDIR

tar xfz $singularity_tarball
cd singularity

./mconfig --prefix=$prefix
cd builddir
make
# need to use sudo because of setuid
echo ">> running 'sudo make install' (you may need to give your sudo password here...)"
sudo make install

rm -rf $TMPDIR

echo "Singularity $singularity_version is now installed at $prefix"
