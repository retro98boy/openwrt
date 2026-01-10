#!/bin/sh

CFG_FILE=rockchip-cfg

rm $CFG_FILE
# 下载官方配置
wget -O $CFG_FILE "https://downloads.openwrt.org/snapshots/targets/rockchip/armv8/config.buildinfo"

# 删除所有目标
sed -i 's/CONFIG_TARGET_ALL_PROFILES=y/CONFIG_TARGET_ALL_PROFILES=n/' $CFG_FILE
sed -i '/^CONFIG_TARGET_DEVICE/d' $CFG_FILE

# 增加目标
echo "CONFIG_TARGET_DEVICE_rockchip_armv8_DEVICE_smart_am40=y" >> $CFG_FILE
echo "CONFIG_TARGET_DEVICE_PACKAGES_rockchip_armv8_DEVICE_smart_am40=""" >> $CFG_FILE

# 修改分区大小
echo "CONFIG_TARGET_KERNEL_PARTSIZE=32" >> $CFG_FILE
echo "CONFIG_TARGET_ROOTFS_PARTSIZE=4096" >> $CFG_FILE

# 集成中文luci
echo "CONFIG_PACKAGE_luci=y" >> $CFG_FILE
echo "CONFIG_LUCI_LANG_zh_Hans=y" >> $CFG_FILE

# 集成额外的软件包
cat high-performance-device-common-pkgs >> $CFG_FILE
cat lxc-pkgs >> $CFG_FILE
