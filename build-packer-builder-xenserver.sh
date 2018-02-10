#!/bin/bash

SUFFIX=pistahh

while getopts "s:" opt; do
    case "$opt" in
        s) SUFFIX="$OPTARG" ;;
    esac
done

MYDIR="$(readlink -f $(dirname $0))"
PBXBASE=$MYDIR/build/pbx
PBXDIR=$PBXBASE/pbx
TREE=$PBXBASE/tree
OUTPUTDIR=$MYDIR/packages
CDIR=/go/src/github.com/xenserver/packer-builder-xenserver
GOBINDIR=$MYDIR/build/gobin

mkdir -p $OUTPUTDIR
if [[ -d $PBXDIR ]]; then
    (cd $PBXDIR; git pull)
else
    git clone 'https://github.com/xenserver/packer-builder-xenserver.git' $PBXDIR
fi

mkdir -p $PBXDIR $GOBINDIR

docker run \
   -t \
   -v $PBXDIR:$CDIR \
   -v $GOBINDIR:/go/bin \
   -w $CDIR golang:latest \
   bash -c 'go get github.com/mitchellh/gox
            go get github.com/mitchellh/go-vnc
            go get github.com/mitchellh/packer
            go get github.com/hashicorp/packer
            ./build.sh'

PBX_VERSION=$(cd $PBXDIR; git describe --tags || git rev-parse HEAD|cut -b-8)

rm -rf $TREE
mkdir -p $TREE/usr/bin $TREE/usr/share/packer-builder-xenserver
cp $GOBINDIR/packer* $TREE/usr/bin/
strip $TREE/usr/bin/*
cp -ra $PBXDIR/examples $TREE/usr/share/packer-builder-xenserver/

docker run -t -v $TREE:/tree -v $OUTPUTDIR:/output fpm \
    fpm -t deb \
        -s dir \
        -C /tree \
        -p /output \
        -n packer-builder-xenserver \
        -v $PBX_VERSION-$SUFFIX \
        -a $(uname -m) \
        -m "Istvan Szekeres (@pistahh) <szekeres@iii.hu>" \
        --vendor "Istvan Szekeres" \
        -S $SUFFIX \
        --description "Packer builder for XenServer" \
        --url "https://github.com/xenserver/packer-builder-xenserver.git" \
        --deb-no-default-config-files \
        --license MPL2 \
        --force
