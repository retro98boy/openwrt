#!/bin/sh

CFG_FILE=cmcc-rax3000m-cfg

rm $CFG_FILE
# 下载官方配置
wget -O $CFG_FILE "https://downloads.openwrt.org/snapshots/targets/mediatek/filogic/config.buildinfo"

# 删除所有目标
sed -i 's/CONFIG_TARGET_ALL_PROFILES=y/CONFIG_TARGET_ALL_PROFILES=n/' $CFG_FILE
sed -i '/^CONFIG_TARGET_DEVICE/d' $CFG_FILE

# 增加目标
echo "CONFIG_TARGET_DEVICE_mediatek_filogic_DEVICE_cmcc_rax3000m=y" >> $CFG_FILE
echo "CONFIG_TARGET_DEVICE_PACKAGES_mediatek_filogic_DEVICE_cmcc_rax3000m=""" >> $CFG_FILE

# 集成中文包
echo "CONFIG_LUCI_LANG_zh_Hans=y" >> $CFG_FILE

# 修改默认的软件源
# sed -i 's|CONFIG_VERSION_REPO="https://downloads.openwrt.org/releases/24.10.4"|CONFIG_VERSION_REPO="https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/24.10.4"|' $CFG_FILE

# 集成额外的软件包
cat cmcc-rax3000m-pkgs >> $CFG_FILE
