#!/bin/bash

SUFFIX=pistahh

MYDIR="$(readlink -f $(dirname $0))"
FZFBASE=$MYDIR/build/fzf
FZFDIR=$FZFBASE/fzf
TREE=$FZFBASE/tree
OUTPUTDIR=$MYDIR/packages

mkdir -p $OUTPUTDIR
if [[ -d $FZFDIR ]]; then
    (cd $FZFDIR; git pull)
else
    git clone 'https://github.com/junegunn/fzf.git' $FZFDIR
fi

docker run -t -v $FZFDIR:/go/src/fzf -w /go/src/fzf golang:latest make
docker run -t -v $FZFDIR:/go/src/fzf -w /go/src/fzf golang:latest make install

FZF_VERSION=$(cd $FZFDIR; git describe --tags)

rm -rf $TREE
mkdir -p $TREE/usr/bin $TREE/usr/share/fzf
cp $FZFDIR/bin/fzf $TREE/usr/bin/
cp $FZFDIR/bin/fzf-tmux $TREE/usr/bin/
cp -r $FZFDIR/shell $TREE/usr/share/fzf

fpm -t deb \
    -s dir \
    -C $TREE \
    -p $OUTPUTDIR \
    -n fzf \
    -v $FZF_VERSION-$SUFFIX \
    -a $(uname -m) \
    -m "Istvan Szekeres (@pistahh) <szekeres@iii.hu>" \
    --vendor "Istvan Szekeres" \
    -S $SUFFIX \
    --description "A command-line fuzzy finder" \
    --url "https://github.com/junegunn/fzf" \
    --deb-no-default-config-files \
    --license MIT \
    --force

