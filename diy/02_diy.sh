#!/bin/bash
clear

# Add luci-app-eqos
cp -rf ../lede_luci/applications/luci-app-eqos ./package/new/luci-app-eqos

# Add luci-app-nft-qos
cp -rf ../lede_luci/applications/luci-app-nft-qos ./package/new/luci-app-nft-qos


# Add luci-app-control-webrestriction
git clone -b master --depth 1 https://github.com/JSZMonkey/luci-app-control-webrestriction.git package/new/luci-app-control-webrestriction

# Mosdns
rm -rf ./package/new/mosdns
rm -rf ./package/new/luci-app-mosdns
rm -rf ./package/new/v2ray-geodata
cp -rf ../lede_pkg/net/mosdns ./package/new/mosdns
cp -rf ../lede_pkg/net/v2ray-geodata ./package/new/v2ray-geodata
cp -rf ../lede_pkg/utils/v2dat ./package/new/v2dat
cp -rf ../lede_luci/applications/luci-app-mosdns ./package/new/luci-app-mosdns

# 流量监视
rm -rf ./package/new/luci-app-wrtbwmon
git clone -b master --depth 1 https://github.com/JSZMonkey/luci-app-wrtbwmon.git package/new/luci-app-wrtbwmon


rm -rf ./feeds/packages/net/miniupnpd
cp -rf ../lede_pkg/net/miniupnpd ./feeds/packages/net/miniupnpd
pushd feeds/packages
patch -p1 <../../../PATCH/miniupnpd/01-set-presentation_url.patch
patch -p1 <../../../PATCH/miniupnpd/02-force_forwarding.patch
patch -p1 <../../../PATCH/miniupnpd/03-Update-301-options-force_forwarding-support.patch.patch
