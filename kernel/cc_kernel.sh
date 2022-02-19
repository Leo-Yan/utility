#!/usr/bin/bash

KERNEL=$1
PLAT=$2
OUT="${KERNEL}/${PLAT}_out"

if [[ $# -ne 2 ]] ; then
	echo "Usage: cc_kernel.sh kernel_path platform"
	echo "       Supoorted platform: hikey960"
	exit 1
fi

if [ ! -d $KERNEL ]; then
	echo "Kernel folder $KERNEL doesn't exist!"
	exit 1
fi

echo "Building kernel $KERNEL for $PLAT ..."
echo "Output folder is: $OUT"

case "$PLAT" in
"hikey960")
	export ARCH=arm64
	export CROSS_COMPILE=aarch64-linux-gnu-
	export RAMDISK=$PWD/$PLAT/ramdisk.img
	export BOOTIMG_CONF=$PWD/$PLAT/bootimg-hikey960-debian.cfg
	export TARGET=Image
	export DTB=hisilicon/hi3660-hikey960.dtb
	export KERNEL_CONFIG=defconfig
	export ABOOTIMG=boot.img
	;;
* )
	echo "can't build for $PLAT, wrong platform name?"
	exit
	;;
esac

pushd $KERNEL

make $KERNEL_CONFIG O=$OUT
./scripts/config --file $OUT/.config -e CONFIG_PHY_HI3660_USB
./scripts/config --file $OUT/.config -e CONFIG_HISI_HIKEY_USB
./scripts/config --file $OUT/.config -e CONFIG_TYPEC
./scripts/config --file $OUT/.config -e CONFIG_TYPEC_TCPM
./scripts/config --file $OUT/.config -e CONFIG_TYPEC_TCPCI
./scripts/config --file $OUT/.config -e CONFIG_TYPEC_RT1711H
./scripts/config --file $OUT/.config -e CONFIG_WL18XX
./scripts/config --file $OUT/.config -e CONFIG_WLCORE_SDIO
./scripts/config --file $OUT/.config -e CONFIG_CFG80211
./scripts/config --file $OUT/.config -e CONFIG_MAC80211
./scripts/config --file $OUT/.config -e CONFIG_MAC80211_MESH
./scripts/config --file $OUT/.config -e CONFIG_MAC80211_LEDS
./scripts/config --file $OUT/.config -e CONFIG_RFKILL
./scripts/config --file $OUT/.config -e CONFIG_RFKILL_GPIO
yes "" | make oldconfig O=$OUT

make -j `nproc` $TARGET $DTB O=$OUT

IMAGE_FILE=$OUT/arch/$ARCH/boot/$TARGET
DTB_FILE=$OUT/arch/$ARCH/boot/dts/$DTB

if [ ! -f $IMAGE_FILE ]; then
	echo "Fail to build $IMAGE_FILE"
	exit 1
fi

if [ ! -f $DTB_FILE ]; then
	echo "Fail to build $DTB_FILE"
	exit 1
fi

if [ ! -z ${ABOOTIMG+x} ]; then
	cat $IMAGE_FILE $DTB_FILE > $OUT/Image-dtb
	abootimg --create $OUT/boot.img -k $OUT/Image-dtb -r $RAMDISK -f $BOOTIMG_CONF
fi

popd
