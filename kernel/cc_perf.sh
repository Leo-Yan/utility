#!/usr/bin/bash

set -e

KERNEL=$1

pushd $KERNEL

make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- LDFLAGS="-static" -C tools/perf VF=1 CORESIGHT=1 NO_JEVENTS=1 DEBUG=1 $2

popd
