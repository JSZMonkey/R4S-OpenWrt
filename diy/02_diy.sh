#!/bin/bash
clear

rm -rf ../PATCH/files-5.10/arch/arm64/boot/dts/rockchip/rk3568-nanopi-r5c.dts

# Add luci-app-eqos
svn co https://github.com/immortalwrt/luci/trunk/applications/luci-app-eqos package/new/luci-app-eqos

rm -rf ./package/new/luci-app-mosdns
rm -rf ./package/new/mosdns
svn export https://github.com/sbwml/luci-app-mosdns/trunk/mosdns package/new/mosdns
svn export https://github.com/sbwml/luci-app-mosdns/trunk/luci-app-mosdns package/new/luci-app-mosdns
