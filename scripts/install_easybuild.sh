#!/bin/bash

set -e

#mode=bootstrap
mode=pip

if [[ $mode == 'bootstrap' ]]; then

    if [ $# -ne 1 ]; then
        echo "ERROR: Usage: $0 <installation prefix>" >&2
        exit 1
    fi
    prefix=$1

    echo "bootstrapping EasyBuild into $prefix"

    # download script
    curl -O https://raw.githubusercontent.com/easybuilders/easybuild-framework/develop/easybuild/scripts/bootstrap_eb.py

    # bootstrap EasyBuild
    python bootstrap_eb.py $prefix

    echo "EasyBuild is now installed at $prefix"
    echo "To start using it:"
    echo "$ module use $prefix/modules/all"
    echo "$ module load EasyBuild"
else
    echo "installing EasyBuild with pip"
    # install older version of vsc-install to avoid problems due to 'mock' dependency
    sudo pip install 'vsc-install<0.11.4'
    sudo pip install easybuild
    echo "EasyBuild is now installed at $(which eb)"
fi
