#!/bin/bash

set -e

MYDIR=$(readlink -f $(dirname $0))

$MYDIR/package-cargo.sh \
    -b fd \
    -c fd-find \
    -d "A simple, fast and user-friendly alternative to find." \
    -l MIT \
    -u "https://github.com/sharkdp/fd" \
    "$@"
