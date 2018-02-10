#!/bin/bash

set -e

MYDIR=$(readlink -f $(dirname $0))

$MYDIR/package-cargo.sh \
    -b rg \
    -c ripgrep \
    -d "A line-oriented search tool" \
    -l MIT \
    -u "https://github.com/BurntSushi/ripgrep" \
    "$@"
