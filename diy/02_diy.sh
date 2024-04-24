#!/bin/bash
clear

# Add luci-app-eqos

cp -rf ../lede_luci/applications/luci-app-eqos ./package/new/luci-app-eqos

# Mosdns
rm -rf ./package/new/mosdns
rm -rf ./package/new/luci-app-mosdns
rm -rf ./package/new/v2ray-geodata
cp -rf ../lede_pkg/net/mosdns ./package/new/mosdns
cp -rf ../lede_pkg/net/v2ray-geodata ./package/new/mosdns
cp -rf ../lede_pkg/utils/v2dat ./package/new/v2dat
cp -rf ../lede_luci/applications/luci-app-mosdns ./package/new/luci-app-mosdns

# 流量监视
rm -rf ./package/new/luci-app-wrtbwmon
git clone -b patch-1 --depth 1 https://github.com/JSZMonkey/luci-app-wrtbwmon.git package/new/luci-app-wrtbwmon
