#!/bin/bash
fastboot boot t2/boot_t2a.img
sleep 2
fastboot boot t2_out/Image.gz-dtb --cmdline 'console=ttyMSM1,115200,n8 earlycon=msm_serial_dm,0x78b0000 rootwait rw root=/dev/mmcblk0p37 no_console_suspend mdss_mdp.panel=truly_r63350 androidboot.serialno=e665c21 trace_event=icc_set_bw,icc_set_bw_end,clk_set_rate,clk_enable,clk_disable'
