#!/usr/bin/bash

set -e

KERNEL=$1

export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-

pushd $KERNEL

make -C tools/testing/selftests/ TARGETS=bpf SKIP_TARGETS="" $2

popd
