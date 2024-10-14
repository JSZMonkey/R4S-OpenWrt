#!/bin/bash
clear

# 调整默认 LAN IP
sed -i 's/192.168.1.1/192.168.0.1/g' package/base-files/files/bin/config_generate

# qBittorrent 下载
cp -rf ../lede_luci/applications/luci-app-qbittorrent ./package/new/luci-app-qbittorrent
cp -rf ../lede_pkg/net/qBittorrent-static ./package/new/qBittorrent-static
cp -rf ../lede_pkg/net/qBittorrent ./package/new/qBittorrent
cp -rf ../lede_pkg/libs/qtbase ./package/new/qtbase
cp -rf ../lede_pkg/libs/qttools ./package/new/qttools
cp -rf ../lede_pkg/libs/rblibtorrent ./package/new/rblibtorrent
sed -i 's,"nas","services",g' package/new/luci-app-qbittorrent/luasrc/controller/qbittorrent.lua
sed -i 's,nas,services,g' package/new/luci-app-qbittorrent/luasrc/view/qbittorrent_status.htm
# Add luci-app-eqos


# Add luci-app-nft-qos



# Add luci-app-control-webrestriction


# Mosdns
#rm -rf ./package/new/mosdns
#rm -rf ./package/new/luci-app-mosdns
#rm -rf ./package/new/v2ray-geodata
#cp -rf ../lede_pkg/net/mosdns ./package/new/mosdns
#cp -rf ../lede_pkg/net/v2ray-geodata ./package/new/v2ray-geodata
#cp -rf ../lede_pkg/utils/v2dat ./package/new/v2dat
#cp -rf ../lede_luci/applications/luci-app-mosdns ./package/new/luci-app-mosdns

# 流量监视
#rm -rf ./package/new/luci-app-wrtbwmon
#git clone -b master --depth 1 https://github.com/JSZMonkey/luci-app-wrtbwmon.git package/new/luci-app-wrtbwmon
