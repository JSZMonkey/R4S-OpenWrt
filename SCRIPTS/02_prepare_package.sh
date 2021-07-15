#!/bin/bash
clear

#凑合解决方案
#wget -qO - https://patch-diff.githubusercontent.com/raw/openwrt/openwrt/pull/3875.patch | patch -p1

## 基础部分
# 基础修改

#使用 O3 级别的优化
sed -i 's/Os/O3/g' include/target.mk

#更新 Feeds
./scripts/feeds update -a
./scripts/feeds install -a

#默认开启 Irqbalance
sed -i "s/enabled '0'/enabled '1'/g" feeds/packages/utils/irqbalance/files/irqbalance.config

#移除 SNAPSHOT 标签
sed -i 's,-SNAPSHOT,,g' include/version.mk
sed -i 's,-SNAPSHOT,,g' package/base-files/image-config.in

#维多利亚的秘密
rm -rf ./scripts/download.pl
rm -rf ./include/download.mk
wget -P scripts/ https://github.com/immortalwrt/immortalwrt/raw/openwrt-21.02/scripts/download.pl
wget -P include/ https://github.com/immortalwrt/immortalwrt/raw/openwrt-21.02/include/download.mk
wget -P include/ https://github.com/immortalwrt/immortalwrt/raw/openwrt-21.02/include/package-immortalwrt.mk
sed -i '/unshift/d' scripts/download.pl
sed -i '/mirror02/d' scripts/download.pl
echo "net.netfilter.nf_conntrack_helper = 1" >> ./package/kernel/linux/files/sysctl-nf-conntrack.conf


# MPTCP
wget -P target/linux/generic/hack-5.4/ https://github.com/Ysurac/openmptcprouter/raw/develop/root/target/linux/generic/hack-5.4/690-mptcp_trunk.patch
wget -P target/linux/generic/hack-5.4/ https://github.com/Ysurac/openmptcprouter/raw/develop/root/target/linux/generic/hack-5.4/998-ndpi-netfilter.patch

# BBRv2
wget -P target/linux/generic/hack-5.4/ https://github.com/Ysurac/openmptcprouter/raw/develop/root/target/linux/generic/hack-5.4/692-tcp_nanqinlang.patch
wget -P target/linux/generic/hack-5.4/ https://github.com/Ysurac/openmptcprouter/raw/develop/root/target/linux/generic/hack-5.4/693-tcp_bbr2.patch
wget -qO - https://github.com/Ysurac/openmptcprouter/raw/develop/patches/nanqinlang.patch | patch -p1
wget -qO - https://github.com/Ysurac/openmptcprouter/raw/develop/patches/bbr2.patch | patch -p1

# 必要的 Patch 们
#Patch arm cpu name
wget -P target/linux/generic/hack-5.4/ https://github.com/immortalwrt/immortalwrt/raw/master/target/linux/generic/hack-5.4/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch

#Patch jsonc
patch -p1 < ../PATCH/jsonc/use_json_object_new_int64.patch

#Patch dnsmasq
patch -p1 < ../PATCH/dnsmasq/dnsmasq-add-filter-aaaa-option.patch
patch -p1 < ../PATCH/dnsmasq/luci-add-filter-aaaa-option.patch
cp -f ../PATCH/dnsmasq/900-add-filter-aaaa-option.patch ./package/network/services/dnsmasq/patches/900-add-filter-aaaa-option.patch

# Fullcone-NAT 部分

#Patch Kernel 以解决 fullcone 冲突
pushd target/linux/generic/hack-5.4
wget https://github.com/immortalwrt/immortalwrt/raw/master/target/linux/generic/hack-5.4/952-net-conntrack-events-support-multiple-registrant.patch
popd

#Patch FireWall 以增添 fullcone 功能 
mkdir package/network/config/firewall/patches
wget -P package/network/config/firewall/patches/ https://github.com/immortalwrt/immortalwrt/raw/master/package/network/config/firewall/patches/fullconenat.patch

# Patch LuCI 以增添fullcone开关
patch -p1 < ../PATCH/firewall/luci-app-firewall_add_fullcone.patch

#FullCone 相关组件
cp -rf ../openwrt-lienol/package/network/fullconenat ./package/network/fullconenat

# Shortcut-FE 部分

#Patch Kernel 以支持SFE
pushd target/linux/generic/hack-5.4
wget https://github.com/immortalwrt/immortalwrt/raw/master/target/linux/generic/hack-5.4/953-net-patch-linux-kernel-to-support-shortcut-fe.patch
popd

#Patch LuCI 以增添SFE开关
patch -p1 < ../PATCH/firewall/luci-app-firewall_add_sfe_switch.patch

#SFE 相关组件
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/shortcut-fe package/lean/shortcut-fe
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/fast-classifier package/lean/fast-classifier
wget -P package/base-files/files/etc/init.d/ https://github.com/JSZMonkey/OpenWrt-Add/raw/master/shortcut-fe


## 获取额外的 Packages

# 基础 Packages

#AutoCore
svn co https://github.com/immortalwrt/immortalwrt/branches/master/package/emortal/autocore package/lean/autocore
#wget -qO - https://github.com/immortalwrt/immortalwrt/commit/13d6e338f1f7eba45e1aada749ac74fc391b9216.patch | patch -Rp1
rm -rf ./feeds/packages/utils/coremark
svn co https://github.com/immortalwrt/packages/trunk/utils/coremark feeds/packages/utils/coremark

#更换 Node 版本
rm -rf ./feeds/packages/lang/node
svn co https://github.com/nxhack/openwrt-node-packages/trunk/node feeds/packages/lang/node
rm -rf ./feeds/packages/lang/node-arduino-firmata
svn co https://github.com/nxhack/openwrt-node-packages/trunk/node-arduino-firmata feeds/packages/lang/node-arduino-firmata
rm -rf ./feeds/packages/lang/node-cylon
svn co https://github.com/nxhack/openwrt-node-packages/trunk/node-cylon feeds/packages/lang/node-cylon
rm -rf ./feeds/packages/lang/node-hid
svn co https://github.com/nxhack/openwrt-node-packages/trunk/node-hid feeds/packages/lang/node-hid
rm -rf ./feeds/packages/lang/node-homebridge
svn co https://github.com/nxhack/openwrt-node-packages/trunk/node-homebridge feeds/packages/lang/node-homebridge
rm -rf ./feeds/packages/lang/node-serialport
svn co https://github.com/nxhack/openwrt-node-packages/trunk/node-serialport feeds/packages/lang/node-serialport
rm -rf ./feeds/packages/lang/node-serialport-bindings
svn co https://github.com/nxhack/openwrt-node-packages/trunk/node-serialport-bindings feeds/packages/lang/node-serialport-bindings
rm -rf ./feeds/packages/lang/node-yarn
svn co https://github.com/nxhack/openwrt-node-packages/trunk/node-yarn feeds/packages/lang/node-yarn
ln -sf ../../../feeds/packages/lang/node-yarn ./package/feeds/packages/node-yarn

# 上网 APP 过滤
git clone -b master --depth 1 https://github.com/destan19/OpenAppFilter.git package/new/OpenAppFilter

#R8168驱动
#svn co https://github.com/immortalwrt/immortalwrt/branches/master/package/kernel/r8168 package/new/r8168
git clone -b master --depth 1 https://github.com/BROBIRD/openwrt-r8168.git package/new/r8168
patch -p1 < ../PATCH/r8168/r8168-fix_LAN_led-for_r4s-from_TL.patch

# UPX
sed -i '/patchelf pkgconf/i\tools-y += ucl upx' ./tools/Makefile
sed -i '\/autoconf\/compile :=/i\$(curdir)/upx/compile := $(curdir)/ucl/compile' ./tools/Makefile
svn co https://github.com/immortalwrt/immortalwrt/branches/master/tools/upx tools/upx
svn co https://github.com/immortalwrt/immortalwrt/branches/master/tools/ucl tools/ucl

# LuCI应用，主题和依赖们

#访问控制
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-accesscontrol package/lean/luci-app-accesscontrol
svn co https://github.com/JSZMonkey/OpenWrt-Add/trunk/luci-app-control-weburl package/new/luci-app-control-weburl

#广告过滤 AdGuard
cp -rf ../openwrt-lienol/package/diy/luci-app-adguardhome ./package/new/luci-app-adguardhome
rm -rf ./feeds/packages/net/adguardhome
svn co https://github.com/openwrt/packages/trunk/net/adguardhome feeds/packages/net/adguardhome
sed -i '/\t)/a\\t$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/AdGuardHome' ./feeds/packages/net/adguardhome/Makefile
sed -i '/init/d' feeds/packages/net/adguardhome/Makefile

#Argon 主题
git clone -b master --depth 1 https://github.com/jerrykuku/luci-theme-argon.git package/new/luci-theme-argon
#wget -P ./package/new/luci-theme-argon/htdocs/luci-static/argon/css/ -N https://github.com/msylgj/luci-theme-argon/raw/patch-1/htdocs/luci-static/argon/css/dark.css
#wget -P ./package/new/luci-theme-argon/luasrc/view/themes/argon -N https://github.com/jerrykuku/luci-theme-argon/raw/9fdcfc866ca80d8d094d554c6aedc18682661973/luasrc/view/themes/argon/footer.htm
#wget -P ./package/new/luci-theme-argon/luasrc/view/themes/argon -N https://github.com/jerrykuku/luci-theme-argon/raw/9fdcfc866ca80d8d094d554c6aedc18682661973/luasrc/view/themes/argon/header.htm
git clone -b master --depth 1 https://github.com/jerrykuku/luci-app-argon-config.git package/new/luci-app-argon-config

#ARP 绑定
svn co https://github.com/QiuSimons/OpenWrt_luci-app/trunk/luci-app-arpbind package/lean/luci-app-arpbind

#定时重启
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-autoreboot package/lean/luci-app-autoreboot

#Boost 通用即插即用
svn co https://github.com/QiuSimons/slim-wrt/branches/main/slimapps/application/luci-app-boostupnp package/new/luci-app-boostupnp
rm -rf ./feeds/packages/net/miniupnpd
svn co https://github.com/openwrt/packages/trunk/net/miniupnpd feeds/packages/net/miniupnpd

#内存压缩
#wget -O- https://patch-diff.githubusercontent.com/raw/openwrt/openwrt/pull/2840.patch | patch -p1
wget -O- https://github.com/NoTengoBattery/openwrt/commit/40f1d5.patch | patch -p1
wget -O- https://github.com/NoTengoBattery/openwrt/commit/a83a0b.patch | patch -p1
wget -O- https://github.com/NoTengoBattery/openwrt/commit/6d5fb4.patch | patch -p1
mkdir ./package/new
cp -rf ../NoTengoBattery/feeds/luci/applications/luci-app-compressed-memory ./package/new/luci-app-compressed-memory
sed -i 's,include ../..,include $(TOPDIR)/feeds/luci,g' ./package/new/luci-app-compressed-memory/Makefile
cp -rf ../NoTengoBattery/package/system/compressed-memory ./package/system/compressed-memory

#CPU 控制相关
svn co https://github.com/immortalwrt/luci/trunk/applications/luci-app-cpufreq feeds/luci/applications/luci-app-cpufreq
ln -sf ../../../feeds/luci/applications/luci-app-cpufreq ./package/feeds/luci/luci-app-cpufreq
sed -i 's,1608,1800,g' feeds/luci/applications/luci-app-cpufreq/root/etc/uci-defaults/cpufreq
sed -i 's,2016,2208,g' feeds/luci/applications/luci-app-cpufreq/root/etc/uci-defaults/cpufreq
sed -i 's,1512,1608,g' feeds/luci/applications/luci-app-cpufreq/root/etc/uci-defaults/cpufreq
svn co https://github.com/JSZMonkey/OpenWrt-Add/trunk/luci-app-cpulimit package/lean/luci-app-cpulimit
svn co https://github.com/immortalwrt/packages/trunk/utils/cpulimit feeds/packages/utils/cpulimit
ln -sf ../../../feeds/packages/utils/cpulimit ./package/feeds/packages/cpulimit

# Aliyun动态DNS
svn co https://github.com/kenzok8/openwrt-packages/trunk/luci-app-aliddns feeds/luci/applications/luci-app-aliddns
mv ./feeds/luci/applications/luci-app-aliddns/po/zh_cn ./feeds/luci/applications/luci-app-aliddns/po/zh_Hans
ln -sf ../../../feeds/luci/applications/luci-app-aliddns ./package/feeds/luci/luci-app-aliddns

# EQOS限速
svn co https://github.com/kenzok8/openwrt-packages/trunk/luci-app-eqos package/new/luci-app-eqos

#Docker 容器
sed -i 's/+docker/+docker \\\n\t+dockerd/g' ./feeds/luci/applications/luci-app-dockerman/Makefile

# Dnsfilter
git clone --depth 1 https://github.com/garypang13/luci-app-dnsfilter.git package/new/luci-app-dnsfilter

# Dnsproxy
svn co https://github.com/immortalwrt/packages/trunk/net/dnsproxy feeds/packages/net/dnsproxy
ln -sf ../../../feeds/packages/net/dnsproxy ./package/feeds/packages/dnsproxy
wget -P package/base-files/files/etc/init.d/ https://github.com/JSZMonkey/OpenWrt-Add/raw/master/dnsproxy

#IPSec
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-ipsec-vpnd package/lean/luci-app-ipsec-vpnd

#IPv6 兼容助手
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/ipv6-helper package/lean/ipv6-helper

#回滚通用即插即用
#rm -rf ./feeds/packages/net/miniupnpd
#svn co https://github.com/coolsnowwolf/packages/trunk/net/miniupnpd feeds/packages/net/miniupnpd

#清理内存
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-ramfree package/lean/luci-app-ramfree

#SSRP 依赖
rm -rf ./feeds/packages/net/xray-core
rm -rf ./feeds/packages/net/kcptun
rm -rf ./feeds/packages/net/shadowsocks-libev
rm -rf ./feeds/packages/net/proxychains-ng
#svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/shadowsocksr-libev package/lean/shadowsocksr-libev
svn co https://github.com/fw876/helloworld/trunk/shadowsocksr-libev package/lean/shadowsocksr-libev
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/pdnsd-alt package/lean/pdnsd
#svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/kcptun package/lean/kcptun
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/srelay package/lean/srelay
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/microsocks package/lean/microsocks
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/dns2socks package/lean/dns2socks
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/redsocks2 package/lean/redsocks2
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/proxychains-ng package/lean/proxychains-ng
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/ipt2socks package/lean/ipt2socks
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/simple-obfs package/lean/simple-obfs
svn co https://github.com/coolsnowwolf/packages/trunk/net/shadowsocks-libev package/lean/shadowsocks-libev
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/trojan package/lean/trojan
svn co https://github.com/xiaorouji/openwrt-passwall/trunk/tcping package/lean/tcping
svn co https://github.com/xiaorouji/openwrt-passwall/trunk/v2ray-plugin package/lean/v2ray-plugin
svn co https://github.com/xiaorouji/openwrt-passwall/trunk/xray-core package/lean/xray-core
svn co https://github.com/xiaorouji/openwrt-passwall/trunk/xray-plugin package/lean/xray-plugin
svn co https://github.com/fw876/helloworld/trunk/naiveproxy package/lean/naiveproxy
svn co https://github.com/fw876/helloworld/trunk/v2ray-core package/lean/v2ray-core
svn co https://github.com/immortalwrt/packages/trunk/net/shadowsocks-rust feeds/packages/net/shadowsocks-rust
ln -sf ../../../feeds/packages/net/shadowsocks-rust ./package/feeds/packages/shadowsocks-rust
svn co https://github.com/immortalwrt/packages/trunk/net/kcptun feeds/packages/net/kcptun
ln -sf ../../../feeds/packages/net/kcptun ./package/feeds/packages/kcptun
#SSRP
svn co https://github.com/fw876/helloworld/trunk/luci-app-ssr-plus package/lean/luci-app-ssr-plus
rm -rf ./package/lean/luci-app-ssr-plus/po/zh_Hans
pushd package/lean
#wget -qO - https://github.com/fw876/helloworld/pull/513.patch | patch -p1
#wget -qO - https://github.com/QiuSimons/helloworld-fw876/commit/c1674ad.patch | patch -p1
wget -qO - https://github.com/QiuSimons/helloworld-fw876/commit/5bbf6e7.patch | patch -p1
wget -qO - https://github.com/QiuSimons/helloworld-fw876/commit/323fbf0.patch | patch -p1
popd
pushd package/lean/luci-app-ssr-plus
#sed -i 's,default n,default y,g' Makefile
sed -i 's,Xray:xray ,Xray:xray-core ,g' Makefile
sed -i '/V2ray:v2ray/d' Makefile
sed -i '/plugin:v2ray/d' Makefile
sed -i '/Proxy:naive/d' Makefile
sed -i '/result.encrypt_method/a\result.fast_open = "1"' root/usr/share/shadowsocksr/subscribe.lua
sed -i 's,ispip.clang.cn/all_cn,cdn.jsdelivr.net/gh/QiuSimons/Chnroute@master/dist/chnroute/chnroute,' root/etc/init.d/shadowsocksr
sed -i 's,YW5vbnltb3Vz/domain-list-community/release/gfwlist.txt,Loyalsoldier/v2ray-rules-dat/release/gfw.txt,' root/etc/init.d/shadowsocksr
sed -i '/Clang.CN.CIDR/a\o:value("https://cdn.jsdelivr.net/gh/QiuSimons/Chnroute@master/dist/chnroute/chnroute.txt", translate("QiuSimons/Chnroute"))' luasrc/model/cbi/shadowsocksr/advanced.lua

sed -i 's/443 -j RETURN/443 -j DROP/' root/usr/bin/ssr-rules
sed -i 's/80 -j RETURN/80 -j DROP/' root/usr/bin/ssr-rules

popd
#订阅转换
svn co https://github.com/immortalwrt/packages/trunk/net/subconverter package/new/subconverter
svn co https://github.com/immortalwrt/packages/trunk/libs/jpcre2 package/new/jpcre2
svn co https://github.com/immortalwrt/packages/trunk/libs/rapidjson package/new/rapidjson
svn co https://github.com/immortalwrt/packages/trunk/libs/libcron package/new/libcron
svn co https://github.com/immortalwrt/packages/trunk/libs/quickjspp package/new/quickjspp

#Vlmcsd 激活助手
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-vlmcsd package/lean/luci-app-vlmcsd
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/vlmcsd package/lean/vlmcsd

#网络唤醒
svn co https://github.com/sundaqiang/openwrt-packages/trunk/luci-app-services-wolplus package/new/luci-app-services-wolplus

# 网易云音乐解锁
svn co https://github.com/cnsilvan/luci-app-unblockneteasemusic/trunk/luci-app-unblockneteasemusic package/new/luci-app-unblockneteasemusic
svn co https://github.com/cnsilvan/luci-app-unblockneteasemusic/trunk/UnblockNeteaseMusic package/new/UnblockNeteaseMusic

#流量监视
git clone -b master --depth 1 https://github.com/brvphoenix/wrtbwmon.git package/new/wrtbwmon
git clone -b master --depth 1 https://github.com/brvphoenix/luci-app-wrtbwmon.git package/new/luci-app-wrtbwmon

# USB 打印机
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-usb-printer package/lean/luci-app-usb-printer

# 翻译及部分功能优化
svn co https://github.com/JSZMonkey/OpenWrt-Add/trunk/addition-trans-zh package/lean/lean-translate

# MPTCP
echo '
CONFIG_CRYPTO_SHA256=y
' >> ./target/linux/generic/config-5.4


##最后的收尾工作

#Lets Fuck
mkdir package/base-files/files/usr/bin
wget -P package/base-files/files/usr/bin/ https://github.com/JSZMonkey/OpenWrt-Add/raw/master/fuck
wget -P package/base-files/files/usr/bin/ https://github.com/JSZMonkey/OpenWrt-Add/raw/master/setdns

#最大连接
sed -i 's/16384/65535/g' package/kernel/linux/files/sysctl-nf-conntrack.conf

#生成默认配置及缓存
rm -rf .config

#exit 0
