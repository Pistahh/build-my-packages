#!/bin/bash

set -e

MAINTAINER="Istvan Szekeres (@pistahh) <szekeres@iii.hu>"
VENDOR="@pistahh"
SUFFIX=pistahh
LICENSE=""

while getopts "b:c:d:m:l:s:u:" opt; do
    case "$opt" in
        b) BINARY="$OPTARG" ;;
        c) CARGO_PACKAGE="$OPTARG" ;;
        d) DESCRIPTION="$OPTARG" ;;
        m) MAINTAINER="$OPTARG" ;;
        l) LICENSE="$OPTARG" ;;
        u) URL="$OPTARG" ;;
        s) SUFFIX="$OPTARG" ;;
        v) VENDOR="$OPTARG" ;;
    esac
done

MYDIR="$(readlink -f $(dirname $0))"
PKGDIR=$MYDIR/packages
CARGODIR=$MYDIR/work/cargo
OUTPUTDIR=$CARGODIR/bin
CACHEDIR=$MYDIR/work/cache/cargo
TREE=$MYDIR/work/tree/$CARGO_PACKAGE
mkdir -p $OUTPUTDIR $CACHEDIR

rm -f $OUTPUTDIR/$BINARY

docker run \
    -t \
    -v $CACHEDIR:/usr/local/cargo/registry \
    -v $CARGODIR:/cargo \
    rust \
    cargo install --root /cargo $CARGO_PACKAGE

VERSION=$($OUTPUTDIR/$BINARY --version|head -1|sed 's/.* //')

rm -rf $TREE
mkdir -p $TREE/usr/bin
cp $OUTPUTDIR/$BINARY $TREE/usr/bin/
strip $TREE/usr/bin/$BINARY

docker run -t -v $TREE:/tree -v $PKGDIR:/package fpm \
    fpm -t deb \
        -s dir \
        -C /tree \
        -p /package \
        -n "$CARGO_PACKAGE" \
        -v "$VERSION-$SUFFIX" \
        -a $(uname -m) \
        -m "$MAINTAINER" \
        --vendor "$VENDOR" \
        -S $SUFFIX \
        --description "$DESCRIPTION" \
        --url "$URL" \
        --deb-no-default-config-files \
        --license "$LICENSE" \
        --force
