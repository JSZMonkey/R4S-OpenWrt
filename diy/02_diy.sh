#!/bin/bash
clear

# Add luci-app-eqos

cp -rf ../lede_luci/applications/luci-app-eqos ./package/new/luci-app-eqos

# Mosdns
cp -rf ../lede_pkg/net/mosdns ./package/new/mosdns
cp -rf ../lede_luci/applications/luci-app-mosdns ./package/new/luci-app-mosdns
rm -rf ./feeds/packages/net/v2ray-geodata
cp -rf ../mosdns/v2ray-geodata ./package/new/v2ray-geodata
