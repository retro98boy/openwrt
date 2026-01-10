#!/bin/sh

CFG_FILE=x86-64-efi-qemu-cfg

rm $CFG_FILE
# 下载官方配置
wget -O $CFG_FILE "https://downloads.openwrt.org/snapshots/targets/x86/64/config.buildinfo"

# 修改分区大小
echo "CONFIG_TARGET_KERNEL_PARTSIZE=32" >> $CFG_FILE
echo "CONFIG_TARGET_ROOTFS_PARTSIZE=512" >> $CFG_FILE

# 集成中文luci
echo "CONFIG_PACKAGE_luci=y" >> $CFG_FILE
echo "CONFIG_LUCI_LANG_zh_Hans=y" >> $CFG_FILE

# 集成额外的软件包
cat high-performance-device-common-pkgs >> $CFG_FILE
cat qemu-ga-pkg >> $CFG_FILE
