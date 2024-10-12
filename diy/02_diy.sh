#!/bin/bash
clear

# 调整默认 LAN IP
sed -i 's/192.168.1.1/192.168.0.1/g' package/base-files/files/bin/config_generate

# qBittorrent 下载
cp -rf ../immortalwrt_luci/applications/luci-app-qbittorrent ./package/new/luci-app-qbittorrent
cp -rf ../immortalwrt_pkg/net/qBittorrent-Enhanced-Edition ./package/new/qBittorrent-Enhanced-Edition
cp -rf ../immortalwrt_pkg/libs/qt6base ./package/new/qt6base
cp -rf ../immortalwrt_pkg/libs/libtorrent-rasterbar ./package/new/libtorrent-rasterbar
cp -rf ../immortalwrt_pkg/utils/qt6tools ./package/new/qt6tools

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
