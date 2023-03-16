#!/bin/bash
clear

# Add luci-app-eqos
svn co https://github.com/immortalwrt/luci/trunk/applications/luci-app-eqos package/new/luci-app-eqos

rm -rf ./package/new/luci-app-mosdns
rm -rf ./package/new/mosdns
svn export https://github.com/sbwml/luci-app-mosdns/trunk/mosdns package/new/mosdns
svn export https://github.com/sbwml/luci-app-mosdns/trunk/luci-app-mosdns package/new/luci-app-mosdns

uci set dhcp.lan.ra='hybrid'
uci set dhcp.lan.ndp='hybrid'
uci set dhcp.lan.dhcpv6='hybrid'
uci set dhcp.lan.ra_management='1'
uci commit dhcp
