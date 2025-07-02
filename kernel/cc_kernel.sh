#!/usr/bin/bash

set -e

KERNEL=$1
OUT=$2
COPY_TGT=$3

: ${VERBOSE:=0}
: ${ARCH:=arm64}

if [[ $# -lt 2 ]] ; then
	echo "Usage: cc_kernel.sh kernel_dir build_dir [copy_addr]"
	exit 1
fi

if [ ! -d $KERNEL ]; then
	echo "The kernel folder $KERNEL doesn't exist!"
	exit 1
fi

if [ ! -d $OUT ]; then
	echo "The build folder $OUT doesn't exist!"
	exit 1
fi

function build_kernel_static_check {
	if [ -z ${STATIC_CHECK+x} ]; then
		return
	fi

	pushd $KERNEL
	# Static check
	make -j `nproc` C=1 CHECK="/data_nvme1n1/niayan01/tools/smatch/smatch -p=kernel" $TARGET O=$OUT
	#make -j `nproc` C=1 $TARGET O=$OUT
	popd

	# Directly bail out
	exit 1
}

function config_arm64_kernel {
	# Disable irrelevant platforms
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_ACTIONS
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_SUNXI
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_ALPINE
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_APPLE
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_BCM
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_BCM2835
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_BCM_IPROC
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_BCMBCA
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_BRCMSTB
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_BERLIN
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_BITMAIN
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_EXYNOS
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_SPARX5
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_K3
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_LG1K
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_HISI
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_KEEMBAY
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_MEDIATEK
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_MESON
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_MVEBU
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_NXP
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_LAYERSCAPE
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_MXC
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_S32
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_MA35
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_NPCM
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_PENSANDO
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_QCOM
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_REALTEK
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_RENESAS
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_ROCKCHIP
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_SEATTLE
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_INTEL_SOCFPGA
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_STM32
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_SYNQUACER
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_TEGRA
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_TESLA_FSD
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_SPRD
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_THUNDER
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_THUNDER2
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_UNIPHIER
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_VEXPRESS
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_VISCONTI
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_XGENE
	./scripts/config --file $OUT/.config -d CONFIG_ARCH_ZYNQMP

	# Enable platform specific config
	./scripts/config --file $OUT/.config -e CONFIG_ARCH_HISI
	./scripts/config --file $OUT/.config -e CONFIG_ARCH_VEXPRESS
	./scripts/config --file $OUT/.config -e CONFIG_ARCH_XGENE
	./scripts/config --file $OUT/.config -e CONFIG_ARCH_QCOM

	# Enable Arm SPE
	./scripts/config --file $OUT/.config -e CONFIG_ARM_SPE_PMU
}

function config_common_kernel {
	# Enable debugging features
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
	./scripts/config --file $OUT/.config -e CONFIG_FPROBE
	./scripts/config --file $OUT/.config -e CONFIG_BPF_LSM

	./scripts/config --file $OUT/.config -e CONFIG_DEBUG_INFO
	./scripts/config --file $OUT/.config -e CONFIG_DEBUG_INFO_DWARF5
	./scripts/config --file $OUT/.config -e CONFIG_DEBUG_INFO_BTF
	./scripts/config --file $OUT/.config -d CONFIG_DEBUG_INFO_REDUCED
	./scripts/config --file $OUT/.config -e CONFIG_MODULE_ALLOW_BTF_MISMATCH

	./scripts/config --file $OUT/.config -e CONFIG_PID_IN_CONTEXTIDR

	./scripts/config --file $OUT/.config -e CONFIG_PTDUMP_DEBUGFS

	# Enable Arm CoreSight
	./scripts/config --file $OUT/.config -e CONFIG_CORESIGHT
	./scripts/config --file $OUT/.config -e CONFIG_CORESIGHT_LINKS_AND_SINKS
	./scripts/config --file $OUT/.config -e CONFIG_CORESIGHT_LINK_AND_SINK_TMC
	./scripts/config --file $OUT/.config -e CONFIG_CORESIGHT_CATU
	./scripts/config --file $OUT/.config -e CONFIG_CORESIGHT_SINK_TPIU
	./scripts/config --file $OUT/.config -e CONFIG_CORESIGHT_SINK_ETBV10
	./scripts/config --file $OUT/.config -e CONFIG_CORESIGHT_SOURCE_ETM3X
	./scripts/config --file $OUT/.config -e CONFIG_CORESIGHT_SOURCE_ETM4X
	./scripts/config --file $OUT/.config -e CONFIG_CORESIGHT_STM
	./scripts/config --file $OUT/.config -e CONFIG_CORESIGHT_CTCU
	./scripts/config --file $OUT/.config -e CONFIG_CORESIGHT_CPU_DEBUG
	./scripts/config --file $OUT/.config -e CONFIG_CORESIGHT_CTI
	./scripts/config --file $OUT/.config -e CONFIG_CORESIGHT_CTI_INTEGRATION_REGS
	./scripts/config --file $OUT/.config -e CONFIG_CORESIGHT_TRBE
	./scripts/config --file $OUT/.config -e CONFIG_CORESIGHT_TNOC
	./scripts/config --file $OUT/.config -e CONFIG_CORESIGHT_DUMMY

	./scripts/config --file $OUT/.config -e CONFIG_IPV6
	./scripts/config --file $OUT/.config -e CONFIG_TEE
	./scripts/config --file $OUT/.config -e CONFIG_FUSE_FS

	./scripts/config --file $OUT/.config -e CONFIG_SECURITY_SELINUX
	./scripts/config --file $OUT/.config -e CONFIG_SECURITY_NETWORK
	./scripts/config --file $OUT/.config -e CONFIG_SECURITY_PATH
	./scripts/config --file $OUT/.config -e CONFIG_SECURITY_APPARMOR

	./scripts/config --file $OUT/.config -e CONFIG_LTO_CLANG_THIN
	./scripts/config --file $OUT/.config -e CONFIG_LTO_CLANG
	./scripts/config --file $OUT/.config -e CONFIG_LTO
}

function config_hikey960 {
	# Enable device drivers
	./scripts/config --file $OUT/.config -e CONFIG_PHY_HI3660_USB
	./scripts/config --file $OUT/.config -e CONFIG_HISI_HIKEY_USB
	./scripts/config --file $OUT/.config -e CONFIG_TYPEC
	./scripts/config --file $OUT/.config -e CONFIG_TYPEC_TCPM
	./scripts/config --file $OUT/.config -e CONFIG_TYPEC_TCPCI
	./scripts/config --file $OUT/.config -e CONFIG_TYPEC_RT1711H

}

function config_db410c {
	./scripts/config --file $OUT/.config -e CONFIG_QCOM_SYSMON
	./scripts/config --file $OUT/.config -e CONFIG_QCOM_PIL_INFO
	./scripts/config --file $OUT/.config -e CONFIG_QCOM_Q6V5_COMMON
	./scripts/config --file $OUT/.config -e CONFIG_QCOM_Q6V5_MSS
	./scripts/config --file $OUT/.config -e CONFIG_QCOM_Q6V5_PAS
	./scripts/config --file $OUT/.config -e CONFIG_QCOM_WCNSS_PIL
	./scripts/config --file $OUT/.config -e CONFIG_RPMSG_QCOM_GLINK_SMEM
	./scripts/config --file $OUT/.config -e CONFIG_QCOM_RPROC_COMMON
	./scripts/config --file $OUT/.config -e CONFIG_INTERCONNECT_QCOM_MSM8916

	./scripts/config --file $OUT/.config -e CONFIG_PHY_QCOM_USB_HS
	./scripts/config --file $OUT/.config -e CONFIG_PHY_QCOM_USB_SNPS_FEMTO_V2
	./scripts/config --file $OUT/.config -e CONFIG_PHY_QCOM_USB_HS_28NM
	./scripts/config --file $OUT/.config -e CONFIG_PHY_QCOM_USB_SS
}

function config_network {
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
}

function config_block_device {
	# Enable NVME drivers
	./scripts/config --file $OUT/.config -e CONFIG_NVME_CORE
	./scripts/config --file $OUT/.config -e CONFIG_BLK_DEV_NVME
	./scripts/config --file $OUT/.config -e CONFIG_NVME_MULTIPATH

	# Enable Device Mapper
	./scripts/config --file $OUT/.config -e CONFIG_MD
	./scripts/config --file $OUT/.config -e CONFIG_BLK_DEV_DM_BUILTIN
	./scripts/config --file $OUT/.config -e CONFIG_BLK_DEV_DM

	./scripts/config --file $OUT/.config -e CONFIG_MEMORY_HOTPLUG
}

function config_virt_device {
	./scripts/config --file $OUT/.config -e CONFIG_VIRTIO_FS
	./scripts/config --file $OUT/.config -e CONFIG_SCSI_VIRTIO
	./scripts/config --file $OUT/.config -e CONFIG_I2C_VIRTIO
	./scripts/config --file $OUT/.config -e CONFIG_GPIO_VIRTIO
	./scripts/config --file $OUT/.config -e CONFIG_SND_VIRTIO
	./scripts/config --file $OUT/.config -e CONFIG_VIRTIO_INPUT
	./scripts/config --file $OUT/.config -e CONFIG_VIRTIO_MEM
	./scripts/config --file $OUT/.config -e CONFIG_MACVLAN
	./scripts/config --file $OUT/.config -e CONFIG_MACVTAP
	./scripts/config --file $OUT/.config -e CONFIG_VHOST_IOTLB
	./scripts/config --file $OUT/.config -e CONFIG_VHOST
	./scripts/config --file $OUT/.config -e CONFIG_VHOST_NET
	./scripts/config --file $OUT/.config -e CONFIG_FUSE_FS
}

function config_kernel {
	pushd $KERNEL

	if [ -n "$LLVM" ]; then
		make LLVM=${LLVM} $KERNEL_CONFIG O=$OUT
	else
		make $KERNEL_CONFIG O=$OUT
	fi

	if [[ "$ARCH" == "arm64" ]]; then
		config_arm64_kernel
		config_hikey960
		#config_db410c
	fi

	config_common_kernel
	config_network
	config_block_device
	config_virt_device

	if [ -n "$LLVM" ]; then
		yes "" | make LLVM=${LLVM} oldconfig O=$OUT
	else
		yes "" | make oldconfig O=$OUT
	fi

	popd
}

function build_kernel {
	pushd $KERNEL

	if [ -n "$LLVM" ]; then
		make LLVM=${LLVM} -j `nproc` $TARGET V=${VERBOSE} O=$OUT
		make LLVM=${LLVM} headers_install O=$OUT
	else
		make -j `nproc` $TARGET V=${VERBOSE} O=$OUT
		make headers_install O=$OUT
	fi

 	IMAGE_FILE=$OUT/arch/$ARCH/boot/$TARGET

	if [ ! -f $IMAGE_FILE ]; then
		echo "Fail to build $IMAGE_FILE"
		exit 1
	fi

	if [[ ! -z "$DTBS" ]]; then
		make -j `nproc` $DTBS V=${VERBOSE} O=$OUT
		# make CHECK_DTBS=y arm/fvp-base-revc.dtb O=$OUT
	fi

	for f in $DTBS; do
		if [ ! -f $OUT/arch/$ARCH/boot/dts/$f ]; then
			echo "Fail to build $OUT/arch/$ARCH/boot/dts/$f"
			exit 1
		fi
	done

	export COPY_IMAGE_LIST="${IMAGE_FILE}"

	for f in $DTBS; do
		export COPY_IMAGE_LIST+=" $OUT/arch/$ARCH/boot/dts/$f"
	done

	if [ ! -z ${BUILD_KMOD+x} ]; then
		make -j `nproc` modules O=$OUT
		make -j `nproc` O=$OUT INSTALL_MOD_PATH=$OUT/overlay modules_install
		tar --owner root:0 --group root:0 -C $OUT/overlay -cf $OUT/overlay.tgz .
		export COPY_IMAGE_LIST+=" $OUT/overlay.tgz"
	fi

	popd
}

function build_abootimg {
	# Build aboot image for Hikey960
	export RAMDISK=$PWD/hikey960/ramdisk.img
	export BOOTIMG_CONF=$PWD/hikey960/bootimg-hikey960-debian.cfg
 	DTB_FILE=$OUT/arch/$ARCH/boot/dts/hisilicon/hi3660-hikey960.dtb

	cat $IMAGE_FILE $DTB_FILE > $OUT/Image-dtb
	abootimg --create $OUT/boot.img -k $OUT/Image-dtb -r $RAMDISK -f $BOOTIMG_CONF
	export COPY_IMAGE_LIST+=" $OUT/boot.img"

	# We don't build abootimg for DB410c as we use tftp booting in U-boot.
	# But we keep below commands for recording steps.
	#
	# cat $IMAGE_FILE $DTB_FILE > $OUT/Image.gz-dtb
	# echo "not a ramdisk" > ramdisk.img
	# abootimg --create $OUT/boot.img -k $OUT/Image.gz-dtb -r ramdisk.img \
	# 	-c pagesize=2048 -c kerneladdr=0x80008000 -c ramdiskaddr=0x81000000 \
	# 	-c cmdline="root=/dev/mmcblk0p14 rw rootwait console=tty0 console=ttyMSM0,115200n8 fastboot crashkernel=256M crash_kexec_post_notifiers nohlt"
	# export COPY_IMAGE_LIST+=" $OUT/arch/$ARCH/boot/Image $OUT/boot.img"
}

function copy_images {
	cp $IMAGE_FILE /var/lib/tftpboot/

	if [ -z "${COPY_TGT}" ]; then
		return
	fi

	echo "Copy $COPY_IMAGE_LIST to Huanghe ..."
	for f in $COPY_IMAGE_LIST; do
		scp $f $COPY_TGT
	done
}

echo "Building kernel $KERNEL ..."
echo "Output folder is: $OUT"

# Global variables for all platforms
if [[ "$ARCH" == "arm64" ]]; then
	export CROSS_COMPILE=aarch64-linux-gnu-
	export DTBS="hisilicon/hi3660-hikey960.dtb qcom/apq8016-sbc.dtb arm/juno-r2.dtb arm/juno-r2-scmi.dtb arm/fvp-base-revc.dtb"
	export KERNEL_CONFIG=defconfig
elif [[ "$ARCH" == "arm" ]]; then
	export CROSS_COMPILE=arm-linux-gnueabi-
	export DTBS=""
	export KERNEL_CONFIG=u8500_defconfig
fi

export TARGET=Image

echo "Architecture: ${ARCH}"
echo "Compiler    : ${CROSS_COMPILE}"
echo "DTB List    : ${DTBS}"
echo "Kernel Cfg  : ${KERNEL_CONFIG}"

# Hikey960
# Generate config file and enable specific configurations
# for WIFI and USB devices.
# For kernel 5.14, there still have three patches are left out
# from mainline kernel, need to cherry-pick from John's
# hikey960's mainline-WIP branch:
# Revert "arm64: dts: hi3660: Harmonize DWC USB3 DT nodes name"
# 00958c40cc30 arm64: dts: hisilicon: Add usb mux hub for hikey960
# 6361feb972fb dt-bindings: misc: add schema for USB hub on Kirin devices

config_kernel
build_kernel_static_check
build_kernel

# No need to generate and copy images for Arm build
[[ "$ARCH" == "arm" ]] && exit

build_abootimg
copy_images
