#!/bin/bash

MYDIR=$(readlink -f $(dirname $0))

$MYDIR/build-fpm-container.sh
$MYDIR/build-fd.sh "$@"
$MYDIR/build-fzf.sh "$@"
$MYDIR/build-ripgrep.sh "$@"
$MYDIR/build-packer-builder-xenserver.sh "$@"
