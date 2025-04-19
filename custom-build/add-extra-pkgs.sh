#!/bin/sh

DOWNLOAD_DIR=$HOME/Downloads/openwrt-extra-pkgs
OPENWRT_ROOT_DIR=$PWD

[ ! -d "$DOWNLOAD_DIR" ] && mkdir -p "$DOWNLOAD_DIR"

clone_or_update() {
    local repo_url=$1
    local repo_dir=$2
    local repo_name=$3

    if [ ! -d "$repo_dir" ]; then
        echo "正在克隆$repo_name..."
        git clone "$repo_url" "$repo_dir"
    else
        echo "正在更新$repo_name..."
        cd "$repo_dir" || exit
        git pull
        cd - >/dev/null || exit
    fi
}

clone_or_update "https://github.com/sbwml/openwrt_pkgs.git" "$DOWNLOAD_DIR/sbwml-openwrt-pkgs" "sbwml-openwrt-pkgs"
clone_or_update "https://github.com/sirpdboy/luci-app-ddns-go.git" "$DOWNLOAD_DIR/sirpdboy-luci-app-ddns-go" "sirpdboy-luci-app-ddns-go"
clone_or_update "https://github.com/EasyTier/luci-app-easytier.git" "$DOWNLOAD_DIR/easytier-luci-app-easytier" "easytier-luci-app-easytier"
clone_or_update "https://github.com/immortalwrt/luci.git" "$DOWNLOAD_DIR/immortalwrt-luci" "immortalwrt-luci"
clone_or_update "https://github.com/immortalwrt/packages.git" "$DOWNLOAD_DIR/immortalwrt-packages" "immortalwrt-packages"

rm -rf $OPENWRT_ROOT_DIR/feeds/luci/applications/luci-app-airplay2
cp -r $DOWNLOAD_DIR/immortalwrt-luci/applications/luci-app-airplay2 $OPENWRT_ROOT_DIR/feeds/luci/applications

rm -rf $OPENWRT_ROOT_DIR/feeds/luci/applications/luci-app-ddns-go
cp -r $DOWNLOAD_DIR/sirpdboy-luci-app-ddns-go/luci-app-ddns-go $OPENWRT_ROOT_DIR/feeds/luci/applications

rm -rf $OPENWRT_ROOT_DIR/feeds/luci/applications/luci-app-easytier
cp -r $DOWNLOAD_DIR/easytier-luci-app-easytier/luci-app-easytier $OPENWRT_ROOT_DIR/feeds/luci/applications

rm -rf $OPENWRT_ROOT_DIR/feeds/luci/applications/luci-app-msd_lite
cp -r $DOWNLOAD_DIR/immortalwrt-luci/applications/luci-app-msd_lite $OPENWRT_ROOT_DIR/feeds/luci/applications

rm -rf $OPENWRT_ROOT_DIR/feeds/luci/applications/luci-app-socat
cp -r $DOWNLOAD_DIR/sbwml-openwrt-pkgs/luci-app-socat $OPENWRT_ROOT_DIR/feeds/luci/applications

rm -rf $OPENWRT_ROOT_DIR/feeds/packages/net/ddns-go
cp -r $DOWNLOAD_DIR/sirpdboy-luci-app-ddns-go/ddns-go $OPENWRT_ROOT_DIR/feeds/packages/net

rm -rf $OPENWRT_ROOT_DIR/feeds/packages/net/easytier
cp -r $DOWNLOAD_DIR/easytier-luci-app-easytier/easytier $OPENWRT_ROOT_DIR/feeds/packages/net

rm -rf $OPENWRT_ROOT_DIR/feeds/packages/net/msd_lite
cp -r $DOWNLOAD_DIR/immortalwrt-packages/net/msd_lite $OPENWRT_ROOT_DIR/feeds/packages/net
