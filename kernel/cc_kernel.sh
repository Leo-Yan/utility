#!/usr/bin/bash

KERNEL=$1
PLAT=$2
OUT="${KERNEL}/${PLAT}_out"

if [[ $# -ne 2 ]] ; then
	echo "Usage: cc_kernel.sh kernel_path platform"
	echo "       Supoorted platform: hikey960, db410c"
	exit 1
fi

if [ ! -d $KERNEL ]; then
	echo "Kernel folder $KERNEL doesn't exist!"
	exit 1
fi

function build_kernel_images {
	pushd $KERNEL

	make -j `nproc` $TARGET $DTB modules O=$OUT

	rm -rf $OUT/modules
	make -j `nproc` O=$OUT INSTALL_MOD_PATH=$OUT/overlay INSTALL_MOD_STRIP=1 modules_install
	tar --owner root:0 --group root:0 -C $OUT/overlay -cf $OUT/overlay.tgz .

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

	popd
}

function build_abootimg {
	case "$PLAT" in
	"hikey960")
		cat $IMAGE_FILE $DTB_FILE > $OUT/Image-dtb
		abootimg --create $OUT/boot.img -k $OUT/Image-dtb -r $RAMDISK -f $BOOTIMG_CONF
		;;

	"db410c")
		cat $IMAGE_FILE $DTB_FILE > $OUT/Image.gz-dtb
		echo "not a ramdisk" > ramdisk.img
		abootimg --create $OUT/boot.img -k $OUT/Image.gz-dtb -r ramdisk.img \
			-c pagesize=2048 -c kerneladdr=0x80008000 -c ramdiskaddr=0x81000000 \
			-c cmdline="root=/dev/mmcblk0p14 rw rootwait console=tty0 console=ttyMSM0,115200n8 fastboot crashkernel=256M crash_kexec_post_notifiers nohlt"
		;;

	* )
		echo "can't build for $PLAT, wrong platform name?"
		exit
		;;
	esac
}

function copy_images {
	if [ ! -z ${COPYIMAGE+x} ]; then
		cp_to_dbg_machine $IMAGE_FILE
		cp_to_dbg_machine $DTB_FILE
		cp_to_dbg_machine $OUT/boot.img
		cp_to_dbg_machine $OUT/overlay.tgz
	fi
}

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

	# Generate config file and enable specific configurations
	# for WIFI and USB devices.
	# For kernel 5.14, there still have three patches are left out
	# from mainline kernel, need to cherry-pick from John's
	# hikey960's mainline-WIP branch:
	# Revert "arm64: dts: hi3660: Harmonize DWC USB3 DT nodes name"
	# 00958c40cc30 arm64: dts: hisilicon: Add usb mux hub for hikey960
	# 6361feb972fb dt-bindings: misc: add schema for USB hub on Kirin devices

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
	./scripts/config --file $OUT/.config -e CONFIG_USB_RTL8150
	./scripts/config --file $OUT/.config -e CONFIG_USB_RTL8152
	./scripts/config --file $OUT/.config -e CONFIG_USB_LAN78XX
	./scripts/config --file $OUT/.config -e CONFIG_USB_USBNET
	./scripts/config --file $OUT/.config -e CONFIG_USB_NET_AX8817X
	./scripts/config --file $OUT/.config -e CONFIG_USB_NET_AX88179_178A
	./scripts/config --file $OUT/.config -e CONFIG_BPF_SYSCALL
	./scripts/config --file $OUT/.config -e CONFIG_BPF_JIT_ALWAYS_ON
	./scripts/config --file $OUT/.config -e CONFIG_TRACEPOINTS
	./scripts/config --file $OUT/.config -e CONFIG_KPROBES
	./scripts/config --file $OUT/.config -e CONFIG_UPROBES
	./scripts/config --file $OUT/.config -e CONFIG_KRETPROBES
	./scripts/config --file $OUT/.config -e CONFIG_PROC_KCORE
	./scripts/config --file $OUT/.config -e CONFIG_NOP_TRACER
	./scripts/config --file $OUT/.config -e CONFIG_TRACER_MAX_TRACE
	./scripts/config --file $OUT/.config -e CONFIG_RING_BUFFER
	./scripts/config --file $OUT/.config -e CONFIG_EVENT_TRACING
	./scripts/config --file $OUT/.config -e CONFIG_CONTEXT_SWITCH_TRACER
	./scripts/config --file $OUT/.config -e CONFIG_TRACING
	./scripts/config --file $OUT/.config -e CONFIG_GENERIC_TRACER
	./scripts/config --file $OUT/.config -e CONFIG_FTRACE
	./scripts/config --file $OUT/.config -e CONFIG_FUNCTION_TRACER
	./scripts/config --file $OUT/.config -e CONFIG_FUNCTION_GRAPH_TRACER
	./scripts/config --file $OUT/.config -e CONFIG_SCHED_TRACER
	./scripts/config --file $OUT/.config -e CONFIG_FTRACE_SYSCALLS
	./scripts/config --file $OUT/.config -e CONFIG_TRACER_SNAPSHOT
	./scripts/config --file $OUT/.config -e CONFIG_KPROBE_EVENTS
	./scripts/config --file $OUT/.config -e CONFIG_UPROBE_EVENTS
	./scripts/config --file $OUT/.config -e CONFIG_BPF_EVENTS
	./scripts/config --file $OUT/.config -e CONFIG_DYNAMIC_EVENTS
	./scripts/config --file $OUT/.config -e CONFIG_PROBE_EVENTS
	./scripts/config --file $OUT/.config -e CONFIG_DYNAMIC_FTRACE
	yes "" | make oldconfig O=$OUT
	popd

	;;

"db410c")
	export ARCH=arm64
	export CROSS_COMPILE=aarch64-linux-gnu-
	export TARGET=Image.gz
	export DTB=qcom/apq8016-sbc.dtb
	export KERNEL_CONFIG=defconfig
	export ABOOTIMG=boot.img
	export COPYIMAGE=1

	pushd $KERNEL
	make $KERNEL_CONFIG O=$OUT
	./scripts/config --file $OUT/.config -e CONFIG_QCOM_SYSMON
	./scripts/config --file $OUT/.config -e CONFIG_QCOM_PIL_INFO
	./scripts/config --file $OUT/.config -e CONFIG_QCOM_Q6V5_COMMON
	./scripts/config --file $OUT/.config -e CONFIG_QCOM_Q6V5_MSS
	./scripts/config --file $OUT/.config -e CONFIG_QCOM_Q6V5_PAS
	./scripts/config --file $OUT/.config -e CONFIG_QCOM_WCNSS_PIL
	./scripts/config --file $OUT/.config -e CONFIG_RPMSG_QCOM_GLINK_SMEM
	./scripts/config --file $OUT/.config -e CONFIG_QCOM_RPROC_COMMON
	./scripts/config --file $OUT/.config -e CONFIG_WL18XX
	./scripts/config --file $OUT/.config -e CONFIG_WLCORE_SDIO
	./scripts/config --file $OUT/.config -e CONFIG_CFG80211
	./scripts/config --file $OUT/.config -e CONFIG_MAC80211
	./scripts/config --file $OUT/.config -e CONFIG_MAC80211_MESH
	./scripts/config --file $OUT/.config -e CONFIG_MAC80211_LEDS
	./scripts/config --file $OUT/.config -e CONFIG_RFKILL
	./scripts/config --file $OUT/.config -e CONFIG_RFKILL_GPIO
	./scripts/config --file $OUT/.config -e CONFIG_WLAN_VENDOR_ADMTEK
	./scripts/config --file $OUT/.config -e CONFIG_ATH_COMMON
	./scripts/config --file $OUT/.config -e QCOM_WCNSS_CTRL
	./scripts/config --file $OUT/.config -e CONFIG_WCN36XX
	./scripts/config --file $OUT/.config -e CONFIG_USB_RTL8150
	./scripts/config --file $OUT/.config -e CONFIG_USB_RTL8152
	./scripts/config --file $OUT/.config -e CONFIG_USB_LAN78XX
	./scripts/config --file $OUT/.config -e CONFIG_USB_USBNET
	./scripts/config --file $OUT/.config -e CONFIG_USB_NET_AX8817X
	./scripts/config --file $OUT/.config -e CONFIG_USB_NET_AX88179_178A
	./scripts/config --file $OUT/.config -e CONFIG_INTERCONNECT_QCOM_MSM8916
	./scripts/config --file $OUT/.config -e CONFIG_BPF_SYSCALL
	./scripts/config --file $OUT/.config -e CONFIG_BPF_JIT_ALWAYS_ON
	./scripts/config --file $OUT/.config -e CONFIG_TRACEPOINTS
	./scripts/config --file $OUT/.config -e CONFIG_KPROBES
	./scripts/config --file $OUT/.config -e CONFIG_UPROBES
	./scripts/config --file $OUT/.config -e CONFIG_KRETPROBES
	./scripts/config --file $OUT/.config -e CONFIG_PROC_KCORE
	./scripts/config --file $OUT/.config -e CONFIG_NOP_TRACER
	./scripts/config --file $OUT/.config -e CONFIG_TRACER_MAX_TRACE
	./scripts/config --file $OUT/.config -e CONFIG_RING_BUFFER
	./scripts/config --file $OUT/.config -e CONFIG_EVENT_TRACING
	./scripts/config --file $OUT/.config -e CONFIG_CONTEXT_SWITCH_TRACER
	./scripts/config --file $OUT/.config -e CONFIG_TRACING
	./scripts/config --file $OUT/.config -e CONFIG_GENERIC_TRACER
	./scripts/config --file $OUT/.config -e CONFIG_FTRACE
	./scripts/config --file $OUT/.config -e CONFIG_FUNCTION_TRACER
	./scripts/config --file $OUT/.config -e CONFIG_FUNCTION_GRAPH_TRACER
	./scripts/config --file $OUT/.config -e CONFIG_SCHED_TRACER
	./scripts/config --file $OUT/.config -e CONFIG_FTRACE_SYSCALLS
	./scripts/config --file $OUT/.config -e CONFIG_TRACER_SNAPSHOT
	./scripts/config --file $OUT/.config -e CONFIG_KPROBE_EVENTS
	./scripts/config --file $OUT/.config -e CONFIG_UPROBE_EVENTS
	./scripts/config --file $OUT/.config -e CONFIG_BPF_EVENTS
	./scripts/config --file $OUT/.config -e CONFIG_DYNAMIC_EVENTS
	./scripts/config --file $OUT/.config -e CONFIG_PROBE_EVENTS
	./scripts/config --file $OUT/.config -e CONFIG_DYNAMIC_FTRACE
	yes "" | make oldconfig O=$OUT
	#make allyesconfig O=$OUT
	popd

	;;

* )
	echo "can't build for $PLAT, wrong platform name?"
	exit
	;;
esac

build_kernel_images
build_abootimg
copy_images
