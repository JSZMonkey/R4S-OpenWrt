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

# MACFilter
rm -rf ./feeds/luci/applications/luci-app-accesscontrol
cp -rf ../lede_luci/applications/luci-app-accesscontrol ./package/new/luci-app-accesscontrol

# luci-app-wrtbwmon
rm -rf ./feeds/luci/applications/luci-app-wrtbwmon
git clone https://github.com/brvphoenix/luci-app-wrtbwmon -b master ./feeds/luci/applications/
#cp -rf ./feeds/luci/applications/luci-app-wrtbwmon/luci-app-wrtbwmon ./feeds/luci/applications/luci-app-wrtbwmon
