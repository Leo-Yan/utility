#!/usr/bin/bash
set -e
#export CROSS_COMPILE=/opt/linaro/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-
DT_DOC_CHECKER=~/Development/qualcomm/dt-schema/tools/dt-doc-validate
DT_EXTRACT_EX=~/Development/qualcomm/dt-schema/tools/dt-extract-example
DT_MK_SCHEMA=~/Development/qualcomm/dt-schema/tools/dt-mk-schema
CURDIR=`pwd`
BUILDDIR=$CURDIR"/qlt-kernel/build/square_5.x-tracking"
GCC_COLORS=
cd ../qlt-kernel
mkdir -p $BUILDDIR
INITRAMFS=rootfs-modified.cpio.gz
export CROSS_COMPILE=/opt/linaro/gcc-linaro-7.4.1-2019.02-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-
#export CROSS_COMPILE=aarch64-linux-gnu-
#export CROSS_COMPILE=/opt/linaro/gcc-linaro-4.9.4-2017.01-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-
#CROSS_COMPILE=/local/mnt/workspace/landing_team/bodonogh/Development/x-compiler/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-
export ARCH=arm64
#cp $CURDIR/3.10_t2_defconfig $BUILDDIR/.config
#make defconfig O=$BUILDDIR
#make db410c_defconfig O=$BUILDDIR
make square_defconfig O=$BUILDDIR
make -W=1 O=$BUILDDIR -j `nproc`
#make -W=1 modules O=$BUILDDIR W=1 C=1 CF='-fdiagnostic-prefix -D__CHECK_ENDIAN__' -j `nproc`
make -W=1 modules O=$BUILDDIR -j `nproc`
make -W=1 Image.gz O=$BUILDDIR -j `nproc`
########## make dtbs_check O=$BUILDDIR DT_DOC_CHECKER=$DT_DOC_CHECKER DT_EXTRACT_EX=$DT_EXTRACT_EX DT_MK_SCHEMA=$DT_MK_SCHEMA
#make dt_binding_check O=$BUILDDIR -j `nproc`
#cd $BUILDDIR
#sudo rm -rf $CURDIR/rootfs-mount/lib/modules/*
rm -rf $CURDIR/rootfs-mount/lib/modules/*
#make -W=12 modules_install ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE O=$BUILDDIR INSTALL_MOD_PATH=$CURDIR/t2-modules
#rm -rf $CURDIR/t2-modules/lib/modules/*/kernel/drivers/video
#rm -rf $CURDIR/t2-modules/lib/modules/*/kernel/drivers/net/ethernet
#rm -rf $CURDIR/t2-modules/lib/modules/*/kernel/drivers/media
#rm -rf $CURDIR/t2-modules/lib/modules/*/kernel/drivers/gpu
#rm -rf $CURDIR/t2-modules/lib/modules/*/kernel/fs
#rm -rf $CURDIR/t2-modules/lib/modules/*/kernel/sound
#rm -rf $CURDIR/t2-modules/lib/modules/*/kernel/drivers/iio
fakeroot make modules_install ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE O=$BUILDDIR INSTALL_MOD_PATH=$CURDIR/rootfs-mount
#sudo depmod -F System.map -b $CURDIR/rootfs-mount
cd $CURDIR
#rm $INITRAMFS
#sudo ./package-rootfs.sh
#ln -sf $CURDIR/$INITRAMFS $BUILDDIR/ramdisk.img
cd $BUILDDIR
cat arch/arm64/boot/Image.gz arch/arm64/boot/dts/qcom/apq8039-t2.dtb > arch/arm64/boot/Image.gz-dtb
cat arch/arm64/boot/Image.gz arch/arm64/boot/dts/qcom/apq8016-sbc.dtb > arch/arm64/boot/Image-db410c.gz-dtb
cat arch/arm64/boot/Image.gz arch/arm64/boot/dts/qcom/msm8939-sony-xperia-kanuti-tulip.dtb > arch/arm64/boot/Image-kanuti-tulip.gz-dtb
cat arch/arm64/boot/Image.gz arch/arm64/boot/dts/qcom/msm8939-alcatel-onetouch-idol3-5.5.dtb > arch/arm64/boot/Image-alcatel-idol3.gz-dtb
mkbootimg \
--kernel arch/arm64/boot/Image.gz-dtb \
--ramdisk $BUILDDIR/ramdisk.img \
--cmdline "console=ttyMSM1,115200,n8 earlycon=msm_serial_dm,0x78b0000 rootwait rw root=/dev/ram0 no_console_suspend mdss_mdp.panel=truly_r63350 androidboot.serialno=e665c21" \
--base 0x80000000 \
--pagesize 2048 \
--output $BUILDDIR/boot_t2a.img

mkbootimg \
--kernel arch/arm64/boot/Image-kanuti-tulip.gz-dtb \
--ramdisk $BUILDDIR/ramdisk.img \
--cmdline "rootwait rw root=/dev/ram0 no_console_suspend androidboot.serialno=dd14548b" \
--base 0x80000000 \
--pagesize 2048 \
--output $BUILDDIR/boot_tulip.img

mkbootimg \
--kernel arch/arm64/boot/Image-alcatel-idol3.gz-dtb \
--cmdline "rootwait rw root=/dev/mmcblk1p1 no_console_suspend androidboot.serialno=30504cf3" \
--base 0x80000000 \
--pagesize 2048 \
--output $BUILDDIR/boot_idol3-mmc-rootfs.img

mkbootimg \
--kernel arch/arm64/boot/Image-alcatel-idol3.gz-dtb \
--ramdisk $BUILDDIR/ramdisk.img \
--cmdline "rootwait rw root=/dev/ram0 no_console_suspend androidboot.serialno=30504cf3" \
--base 0x80000000 \
--pagesize 2048 \
--output $BUILDDIR/boot_idol3_ramfs.img

mkbootimg \
--kernel arch/arm64/boot/Image-kanuti-tulip.gz-dtb \
--cmdline "rootwait rw root=/dev/mmcblk1p1 no_console_suspend androidboot.serialno=dd14548b" \
--base 0x80000000 \
--pagesize 2048 \
--output $BUILDDIR/boot_tulip-mmc-rootfs.img

mkbootimg \
--kernel arch/arm64/boot/Image-kanuti-tulip.gz-dtb \
--cmdline "rootwait rw root=/dev/mmcblk1p13 no_console_suspend androidboot.serialno=dd14548b" \
--base 0x80000000 \
--pagesize 2048 \
--output $BUILDDIR/boot_tulip-mmc-rootfs-linaro.img

rm -f $CURDIR/modules-adb.tar.bz2
tar cvfJ $CURDIR/modules-adb.tar.bz2 $CURDIR/rootfs-mount/lib/modules/

#--board mtp-sm8250
#echo "image is at $CURDIR/boot_sm8250.img"
echo "mkbootimg --kernel qlt-kernel/build/square_5.x-tracking/arch/arm64/boot/Image.gz-dtb --cmdline 'console=ttyMSM1,115200,n8 earlycon=msm_serial_dm,0x78b0000 rootwait root=/dev/mmcblk0p27' -o boot.img"
echo "fastboot flash boot_a boot.img"
echo "fastboot reboot"
echo "fastboot boot qlt-kernel/build/square_5.x-tracking/arch/arm64/boot/Image.gz-dtb rootfs-modified.cpio.gz --cmdline 'console=ttyMSM1,115200,n8 earlycon=msm_serial_dm,0x78b0000 init=/init'"
echo "fastboot boot qlt-kernel/build/square_5.x-tracking/arch/arm64/boot/Image-db410c.gz-dtb --cmdline 'console=ttyMSM0,115200,n8 earlycon=msm_serial_dm,0x78b0000 rootwait rw root=/dev/mmcblk0p14 androidboot.emmc=true androidboot.serialno=1628e0d7 androidboot.baseband=apq mdss_mdp.panel=0:dsi:0:'"
echo "fastboot boot qlt-kernel/build/square_5.x-tracking/arch/arm64/boot/Image-kanuti-tulip.gz-dtb --cmdline 'console=ttyMSM0,115200,n8 rootwait rw root=/dev/mmcblk0p14 androidboot.hardware=qcom msm_rtb.filter=0x237 androidboot.bootloader=s1 oemandroidboot.s1boot=1291-8005_S1_Boot_MSM8939_LA2.0_37 androidboot.serialno=YT911AST1X ta_info=1,16,256 startup=0x00000004 warmboot=0x77665501 oemandroidboot.imei=3565790739921400 oemandroidboot.phoneid=0000:3565790739921400 oemandroidboot.security=0 oemandroidboot.babeee48=00000200 oemandroidboot.securityflags=0x00000003 display_status=on'"
echo "fastboot -s YT911AST1X boot /work/deckard/m4aqua/lk2nd-msm8916.img"
echo "fastboot -s dd14548b boot $BUILDDIR/boot_tulip.img"
echo "fastboot -s dd14548b boot $BUILDDIR/boot_tulip-mmc-rootfs.img"
echo "adb -s dd14548b push modules-adb.tar.bz2 /home/root"
echo "fastboot -s 30504cf3 boot $BUILDDIR/boot_idol3-mmc-rootfs.img"
echo "fastboot -s 30504cf3 boot $BUILDDIR/boot_idol3_ramfs.img"
echo "adb -s 30504cf3 push modules-adb.tar.bz2 /home/root"
echo "fastboot -s dd14548b boot $BUILDDIR/boot_tulip-mmc-rootfs-linaro.img"
echo "fastboot boot ~/Development/qualcomm/msm8916-mainline/lk2nd/boot_t2a.img"
echo "fastboot boot qlt-kernel/build/square_5.x-tracking/arch/arm64/boot/Image.gz-dtb --cmdline 'console=ttyMSM1,115200,n8 earlycon=msm_serial_dm,0x78b0000 rootwait rw root=/dev/mmcblk0p27 no_console_suspend mdss_mdp.panel=truly_r63350 androidboot.serialno=e665c21'"
echo "fastboot boot $BUILDDIR/boot_t2a.img"
echo "fastboot boot qlt-kernel/build/square_5.x-tracking/arch/arm64/boot/Image.gz-dtb --cmdline 'console=ttyMSM1,115200,n8 earlycon=msm_serial_dm,0x78b0000 rootwait rw root=/dev/mmcblk0p37 no_console_suspend mdss_mdp.panel=truly_r63350 androidboot.serialno=e665c21'"
