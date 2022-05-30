#!/bin/bash
clear

### 基础部分 ###

# 使用 O3 级别的优化
sed -i 's/Os/O3 -fno-tree-loop-vectorize -Wl,--gc-sections/g' include/target.mk
wget -qO - https://github.com/openwrt/openwrt/commit/8249a8c.patch | patch -p1
wget -qO - https://github.com/openwrt/openwrt/commit/66fa343.patch | patch -p1

# 更新 Feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 默认开启 Irqbalance
sed -i "s/enabled '0'/enabled '1'/g" feeds/packages/utils/irqbalance/files/irqbalance.config

# 移除 SNAPSHOT 标签
sed -i 's,-SNAPSHOT,,g' include/version.mk
sed -i 's,-SNAPSHOT,,g' package/base-files/image-config.in

# 维多利亚的秘密
rm -rf ./scripts/download.pl
rm -rf ./include/download.mk
wget -P scripts/ https://github.com/immortalwrt/immortalwrt/raw/master/scripts/download.pl
wget -P include/ https://github.com/immortalwrt/immortalwrt/raw/master/include/download.mk
sed -i '/unshift/d' scripts/download.pl
sed -i '/mirror02/d' scripts/download.pl
echo "net.netfilter.nf_conntrack_helper = 1" >>./package/kernel/linux/files/sysctl-nf-conntrack.conf

### 必要的 Patches ###

# offload bug fix
wget -qO - https://github.com/openwrt/openwrt/pull/4849.patch | patch -p1

# introduce "le9" Linux kernel patches
cp -f ../PATCH/backport/995-le9i.patch ./target/linux/generic/hack-5.10/995-le9i.patch
cp -f ../PATCH/backport/290-remove-kconfig-CONFIG_I8K.patch ./target/linux/generic/hack-5.10/290-remove-kconfig-CONFIG_I8K.patch

# ZSTD
cp -rf ../PATCH/backport/ZSTD/* ./target/linux/generic/hack-5.10/

# Futex
cp -rf ../PATCH/futex/* ./target/linux/generic/hack-5.10/

# Patch arm64 型号名称
wget -P target/linux/generic/hack-5.10/ https://github.com/immortalwrt/immortalwrt/raw/master/target/linux/generic/hack-5.10/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch

# BBRv2
cp -rf ../PATCH/BBRv2/kernel/* ./target/linux/generic/hack-5.10/
cp -rf ../PATCH/BBRv2/openwrt/package ./
wget -qO - https://github.com/openwrt/openwrt/commit/7db9763.patch | patch -p1

# Haproxy
rm -rf ./feeds/packages/net/haproxy
svn export https://github.com/openwrt/packages/trunk/net/haproxy feeds/packages/net/haproxy
pushd feeds/packages
wget -qO - https://github.com/openwrt/packages/commit/a09cbcd.patch | patch -p1
popd

# OPENSSL
wget -P package/libs/openssl/patches/ https://github.com/openssl/openssl/pull/11895.patch
wget -P package/libs/openssl/patches/ https://github.com/openssl/openssl/pull/14578.patch
wget -P package/libs/openssl/patches/ https://github.com/openssl/openssl/pull/16575.patch

### Fullcone-NAT 部分 ###

# Patch Kernel 以解决 FullCone 冲突
pushd target/linux/generic/hack-5.10
wget https://github.com/coolsnowwolf/lede/raw/master/target/linux/generic/hack-5.10/952-net-conntrack-events-support-multiple-registrant.patch
popd

# Patch FireWall 以增添 FullCone 功能
mkdir package/network/config/firewall4/patches
wget 'https://git.openwrt.org/?p=project/firewall4.git;a=patch;h=38423fae' -O package/network/config/firewall4/patches/990-unconditionally-allow-ct-status-dnat.patch
wget -P package/network/config/firewall4/patches/ https://github.com/wongsyrone/lede-1/raw/master/package/network/config/firewall4/patches/999-01-firewall4-add-fullcone-support.patch
sed -i 's/-1,3 +1,5/-2,3 +2,5/g' package/network/config/firewall4/patches/999-01-firewall4-add-fullcone-support.patch
mkdir package/libs/libnftnl/patches
wget -P package/libs/libnftnl/patches/ https://github.com/wongsyrone/lede-1/raw/master/package/libs/libnftnl/patches/999-01-libnftnl-add-fullcone-expression-support.patch
sed -i '/PKG_LICENSE_FILES/a PKG_FIXUP:=autoreconf' package/libs/libnftnl/Makefile
mkdir package/network/utils/nftables/patches
wget -P package/network/utils/nftables/patches/ https://github.com/wongsyrone/lede-1/raw/master/package/network/utils/nftables/patches/999-01-nftables-add-fullcone-expression-support.patch

# FW3
mkdir package/network/config/firewall/patches
wget -P package/network/config/firewall/patches/ https://github.com/immortalwrt/immortalwrt/raw/openwrt-21.02/package/network/config/firewall/patches/fullconenat.patch
wget -qO- https://github.com/msylgj/R2S-R4S-OpenWrt/raw/master/PATCHES/001-fix-firewall3-flock.patch | patch -p1

# Patch LuCI 以增添 FullCone 开关
patch -p1 <../PATCH/firewall/luci-app-firewall_add_fullcone.patch

# FullCone PKG
git clone --depth 1 https://github.com/fullcone-nat-nftables/nft-fullcone package/new/nft-fullcone
svn export https://github.com/Lienol/openwrt/trunk/package/network/fullconenat package/lean/openwrt-fullconenat

### 获取额外的基础软件包 ###

# 更换为 ImmortalWrt Uboot 以及 Target
rm -rf ./target/linux/rockchip
svn export https://github.com/coolsnowwolf/lede/trunk/target/linux/rockchip target/linux/rockchip
wget -qO - https://github.com/immortalwrt/immortalwrt/commit/af93561.patch | patch -p1
rm -rf ./target/linux/rockchip/Makefile
wget -P target/linux/rockchip/ https://github.com/openwrt/openwrt/raw/openwrt-22.03/target/linux/rockchip/Makefile
rm -rf ./target/linux/rockchip/patches-5.10/002-net-usb-r8152-add-LED-configuration-from-OF.patch
rm -rf ./target/linux/rockchip/patches-5.10/003-dt-bindings-net-add-RTL8152-binding-documentation.patch
rm -rf ./package/boot/uboot-rockchip
svn export https://github.com/coolsnowwolf/lede/trunk/package/boot/uboot-rockchip package/boot/uboot-rockchip
svn export https://github.com/immortalwrt/immortalwrt/branches/master/package/boot/arm-trusted-firmware-rockchip-vendor package/boot/arm-trusted-firmware-rockchip-vendor
rm -rf ./package/kernel/linux/modules/video.mk
wget -P package/kernel/linux/modules/ https://github.com/immortalwrt/immortalwrt/raw/master/package/kernel/linux/modules/video.mk
sed -i '/GOV_ONDEMAND/d' target/linux/rockchip/armv8/config-5.10
sed -i '/DEVFREQ_THERMAL/d' target/linux/rockchip/armv8/config-5.10
echo '
CONFIG_DEVFREQ_THERMAL=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
' >>./target/linux/rockchip/armv8/config-5.10

# LRNG
cp -rf ../PATCH/LRNG/* ./target/linux/generic/hack-5.10/

# ImmortalWrt Uboot TMP Fix
wget -qO- https://github.com/coolsnowwolf/lede/commit/0104258.patch | patch -REtp1

# Disable Mitigations
sed -i 's,rootwait,rootwait mitigations=off,g' target/linux/rockchip/image/mmc.bootscript
sed -i 's,rootwait,rootwait mitigations=off,g' target/linux/rockchip/image/nanopi-r2s.bootscript
sed -i 's,rootwait,rootwait mitigations=off,g' target/linux/rockchip/image/nanopi-r4s.bootscript
sed -i 's,noinitrd,noinitrd mitigations=off,g' target/linux/x86/image/grub-efi.cfg
sed -i 's,noinitrd,noinitrd mitigations=off,g' target/linux/x86/image/grub-iso.cfg
sed -i 's,noinitrd,noinitrd mitigations=off,g' target/linux/x86/image/grub-pc.cfg

# AutoCore
svn export https://github.com/immortalwrt/immortalwrt/branches/master/package/emortal/autocore package/lean/autocore
sed -i 's/"getTempInfo" /"getTempInfo", "getCPUBench", "getCPUUsage" /g' package/lean/autocore/files/generic/luci-mod-status-autocore.json
rm -rf ./feeds/packages/utils/coremark
svn export https://github.com/immortalwrt/packages/trunk/utils/coremark feeds/packages/utils/coremark

# 更换 Nodejs 版本
rm -rf ./feeds/packages/lang/node
svn export https://github.com/nxhack/openwrt-node-packages/trunk/node feeds/packages/lang/node
rm -rf ./feeds/packages/lang/node-arduino-firmata
svn export https://github.com/nxhack/openwrt-node-packages/trunk/node-arduino-firmata feeds/packages/lang/node-arduino-firmata
rm -rf ./feeds/packages/lang/node-cylon
svn export https://github.com/nxhack/openwrt-node-packages/trunk/node-cylon feeds/packages/lang/node-cylon
rm -rf ./feeds/packages/lang/node-hid
svn export https://github.com/nxhack/openwrt-node-packages/trunk/node-hid feeds/packages/lang/node-hid
rm -rf ./feeds/packages/lang/node-homebridge
svn export https://github.com/nxhack/openwrt-node-packages/trunk/node-homebridge feeds/packages/lang/node-homebridge
rm -rf ./feeds/packages/lang/node-serialport
svn export https://github.com/nxhack/openwrt-node-packages/trunk/node-serialport feeds/packages/lang/node-serialport
rm -rf ./feeds/packages/lang/node-serialport-bindings
svn export https://github.com/nxhack/openwrt-node-packages/trunk/node-serialport-bindings feeds/packages/lang/node-serialport-bindings
rm -rf ./feeds/packages/lang/node-yarn
svn export https://github.com/nxhack/openwrt-node-packages/trunk/node-yarn feeds/packages/lang/node-yarn
ln -sf ../../../feeds/packages/lang/node-yarn ./package/feeds/packages/node-yarn
svn export https://github.com/nxhack/openwrt-node-packages/trunk/node-serialport-bindings-cpp feeds/packages/lang/node-serialport-bindings-cpp
ln -sf ../../../feeds/packages/lang/node-serialport-bindings-cpp ./package/feeds/packages/node-serialport-bindings-cpp

# R8168驱动
git clone -b master --depth 1 https://github.com/BROBIRD/openwrt-r8168.git package/new/r8168
patch -p1 <../PATCH/r8168/r8168-fix_LAN_led-for_r4s-from_TL.patch

# R8152驱动
svn export https://github.com/immortalwrt/immortalwrt/branches/master/package/kernel/r8152 package/new/r8152

# UPX 可执行软件压缩
sed -i '/patchelf pkgconf/i\tools-y += ucl upx' ./tools/Makefile
sed -i '\/autoconf\/compile :=/i\$(curdir)/upx/compile := $(curdir)/ucl/compile' ./tools/Makefile
svn export https://github.com/coolsnowwolf/lede/trunk/tools/ucl tools/ucl
svn export https://github.com/coolsnowwolf/lede/trunk/tools/upx tools/upx

### 获取额外的 LuCI 应用、主题和依赖 ###

# 更换 golang 版本
rm -rf ./feeds/packages/lang/golang
svn export https://github.com/openwrt/packages/trunk/lang/golang feeds/packages/lang/golang

# 访问控制
svn export https://github.com/coolsnowwolf/luci/trunk/applications/luci-app-accesscontrol package/lean/luci-app-accesscontrol
svn export https://github.com/QiuSimons/OpenWrt-Add/trunk/luci-app-control-weburl package/new/luci-app-control-weburl

# Argon 主题
git clone -b master --depth 1 https://github.com/jerrykuku/luci-theme-argon.git package/new/luci-theme-argon
rm -rf ./package/new/luci-theme-argon/htdocs/luci-static/argon/background/README.md
git clone -b master --depth 1 https://github.com/jerrykuku/luci-app-argon-config.git package/new/luci-app-argon-config

# MAC 地址与 IP 绑定
svn export https://github.com/immortalwrt/luci/trunk/applications/luci-app-arpbind feeds/luci/applications/luci-app-arpbind
ln -sf ../../../feeds/luci/applications/luci-app-arpbind ./package/feeds/luci/luci-app-arpbind

# 定时重启
svn export https://github.com/coolsnowwolf/luci/trunk/applications/luci-app-autoreboot package/lean/luci-app-autoreboot

# Boost 通用即插即用
svn export https://github.com/QiuSimons/slim-wrt/branches/main/slimapps/application/luci-app-boostupnp package/new/luci-app-boostupnp
rm -rf ./feeds/packages/net/miniupnpd
git clone -b main --depth 1 https://github.com/msylgj/miniupnpd.git feeds/packages/net/miniupnpd

# EQOS限速
svn co https://github.com/kenzok8/openwrt-packages/trunk/luci-app-eqos package/new/luci-app-eqos

# CPU 控制相关
svn export https://github.com/immortalwrt/luci/trunk/applications/luci-app-cpufreq feeds/luci/applications/luci-app-cpufreq
ln -sf ../../../feeds/luci/applications/luci-app-cpufreq ./package/feeds/luci/luci-app-cpufreq
sed -i 's,1608,1800,g' feeds/luci/applications/luci-app-cpufreq/root/etc/uci-defaults/10-cpufreq
sed -i 's,2016,2208,g' feeds/luci/applications/luci-app-cpufreq/root/etc/uci-defaults/10-cpufreq
sed -i 's,1512,1608,g' feeds/luci/applications/luci-app-cpufreq/root/etc/uci-defaults/10-cpufreq
svn export https://github.com/QiuSimons/OpenWrt-Add/trunk/luci-app-cpulimit package/lean/luci-app-cpulimit
svn export https://github.com/immortalwrt/packages/trunk/utils/cpulimit feeds/packages/utils/cpulimit
ln -sf ../../../feeds/packages/utils/cpulimit ./package/feeds/packages/cpulimit

# 动态DNS
svn export https://github.com/kenzok8/openwrt-packages/trunk/luci-app-aliddns feeds/luci/applications/luci-app-aliddns
ln -sf ../../../feeds/luci/applications/luci-app-aliddns ./package/feeds/luci/luci-app-aliddns

# Docker 容器
rm -rf ./feeds/luci/applications/luci-app-dockerman
svn export https://github.com/lisaac/luci-app-dockerman/trunk/applications/luci-app-dockerman feeds/luci/applications/luci-app-dockerman
sed -i '/auto_start/d' feeds/luci/applications/luci-app-dockerman/root/etc/uci-defaults/luci-app-dockerman
pushd feeds/packages
wget -qO- https://github.com/openwrt/packages/commit/ed7396a.patch | patch -p1
popd
rm -rf ./feeds/luci/collections/luci-lib-docker
svn export https://github.com/lisaac/luci-lib-docker/trunk/collections/luci-lib-docker feeds/luci/collections/luci-lib-docker
sed -i '/sysctl.d/d' feeds/packages/utils/dockerd/Makefile
sed -i 's,# CONFIG_BLK_CGROUP_IOCOST is not set,CONFIG_BLK_CGROUP_IOCOST=y,g' target/linux/generic/config-5.10

# DiskMan
mkdir -p package/new/luci-app-diskman && \
wget https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/applications/luci-app-diskman/Makefile -O package/new/luci-app-diskman/Makefile
mkdir -p package/new/parted && \
wget https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/Parted.Makefile -O package/new/parted/Makefile

# IPSec
svn export https://github.com/coolsnowwolf/luci/trunk/applications/luci-app-ipsec-server package/lean/luci-app-ipsec-server

# IPv6 兼容助手
svn export https://github.com/coolsnowwolf/lede/trunk/package/lean/ipv6-helper package/lean/ipv6-helper

# Mosdns
svn export https://github.com/QiuSimons/openwrt-mos/trunk/mosdns package/new/mosdns
svn export https://github.com/QiuSimons/openwrt-mos/trunk/luci-app-mosdns package/new/luci-app-mosdns
svn export https://github.com/QiuSimons/openwrt-mos/trunk/v2ray-geodata package/new/v2ray-geodata

# 上网 APP 过滤
git clone -b master --depth 1 https://github.com/destan19/OpenAppFilter.git package/new/OpenAppFilter
pushd package/new/OpenAppFilter
wget -qO - https://github.com/QiuSimons/OpenAppFilter-destan19/commit/9088cc2.patch | patch -p1
wget https://destan19.github.io/assets/oaf/open_feature/feature-06-18.cfg -O ./open-app-filter/files/feature.cfg
popd

# OLED 驱动程序
git clone -b master --depth 1 https://github.com/NateLol/luci-app-oled.git package/new/luci-app-oled

# 清理内存
svn export https://github.com/coolsnowwolf/luci/trunk/applications/luci-app-ramfree package/lean/luci-app-ramfree

# ShadowsocksR Plus+ 依赖
rm -rf ./feeds/packages/net/kcptun
rm -rf ./feeds/packages/net/shadowsocks-libev
rm -rf ./feeds/packages/net/xray-core
svn export https://github.com/coolsnowwolf/packages/trunk/net/shadowsocks-libev package/lean/shadowsocks-libev
svn export https://github.com/xiaorouji/openwrt-passwall/trunk/shadowsocksr-libev package/lean/shadowsocksr-libev
svn export https://github.com/xiaorouji/openwrt-passwall/trunk/pdnsd-alt package/lean/pdnsd
svn export https://github.com/coolsnowwolf/lede/trunk/package/lean/srelay package/lean/srelay
svn export https://github.com/xiaorouji/openwrt-passwall/trunk/microsocks package/lean/microsocks
svn export https://github.com/xiaorouji/openwrt-passwall/trunk/dns2socks package/lean/dns2socks
svn export https://github.com/coolsnowwolf/packages/trunk/net/redsocks2 package/lean/redsocks2
svn export https://github.com/xiaorouji/openwrt-passwall/trunk/ipt2socks package/lean/ipt2socks
svn export https://github.com/xiaorouji/openwrt-passwall/trunk/trojan package/lean/trojan
svn export https://github.com/xiaorouji/openwrt-passwall/trunk/tcping package/lean/tcping
svn export https://github.com/fw876/helloworld/trunk/simple-obfs package/lean/simple-obfs
svn export https://github.com/fw876/helloworld/trunk/naiveproxy package/lean/naiveproxy
svn export https://github.com/fw876/helloworld/trunk/v2ray-core package/lean/v2ray-core
svn export https://github.com/zxlhhyccc/bf-package-master/trunk/ctcgfw/sagernet-core package/lean/sagernet-core
svn export https://github.com/fw876/helloworld/trunk/xray-core package/lean/xray-core
svn export https://github.com/fw876/helloworld/trunk/v2ray-plugin package/lean/v2ray-plugin
svn export https://github.com/fw876/helloworld/trunk/xray-plugin package/lean/xray-plugin
svn export https://github.com/xiaorouji/openwrt-passwall/trunk/shadowsocks-rust feeds/packages/net/shadowsocks-rust
ln -sf ../../../feeds/packages/net/shadowsocks-rust ./package/feeds/packages/shadowsocks-rust
svn export https://github.com/immortalwrt/packages/trunk/net/kcptun feeds/packages/net/kcptun
ln -sf ../../../feeds/packages/net/kcptun ./package/feeds/packages/kcptun

# ShadowsocksR Plus+
svn export https://github.com/fw876/helloworld/trunk/luci-app-ssr-plus package/lean/luci-app-ssr-plus
rm -rf ./package/lean/luci-app-ssr-plus/po/zh_Hans
pushd package/lean
wget -qO - https://github.com/fw876/helloworld/commit/5bbf6e7.patch | patch -p1
popd
pushd package/lean/luci-app-ssr-plus
sed -i '/Clang.CN.CIDR/a\o:value("https://gh.404delivr.workers.dev/https://github.com/QiuSimons/Chnroute/raw/master/dist/chnroute/chnroute.txt", translate("QiuSimons/Chnroute"))' luasrc/model/cbi/shadowsocksr/advanced.lua
popd

# v2raya
git clone --depth 1 https://github.com/zxlhhyccc/luci-app-v2raya.git package/new/luci-app-v2raya
rm -rf ./feeds/packages/net/v2raya
svn export https://github.com/openwrt/packages/trunk/net/v2raya feeds/packages/net/v2raya
ln -sf ../../../feeds/packages/net/v2raya ./package/feeds/packages/v2raya

# socat
svn export https://github.com/Lienol/openwrt-package/trunk/luci-app-socat package/new/luci-app-socat

# 订阅转换
svn export https://github.com/immortalwrt/packages/trunk/net/subconverter feeds/packages/net/subconverter
ln -sf ../../../feeds/packages/net/subconverter ./package/feeds/packages/subconverter
svn export https://github.com/immortalwrt/packages/trunk/libs/jpcre2 feeds/packages/libs/jpcre2
ln -sf ../../../feeds/packages/libs/jpcre2 ./package/feeds/packages/jpcre2
svn export https://github.com/immortalwrt/packages/trunk/libs/rapidjson feeds/packages/libs/rapidjson
ln -sf ../../../feeds/packages/libs/rapidjson ./package/feeds/packages/rapidjson
svn export https://github.com/immortalwrt/packages/trunk/libs/libcron feeds/packages/libs/libcron
ln -sf ../../../feeds/packages/libs/libcron ./package/feeds/packages/libcron
svn export https://github.com/immortalwrt/packages/trunk/libs/quickjspp feeds/packages/libs/quickjspp
ln -sf ../../../feeds/packages/libs/quickjspp ./package/feeds/packages/quickjspp
svn export https://github.com/immortalwrt/packages/trunk/libs/toml11 feeds/packages/libs/toml11
ln -sf ../../../feeds/packages/libs/toml11 ./package/feeds/packages/toml11

# ucode
svn export https://github.com/openwrt/openwrt/trunk/package/utils/ucode package/utils/ucode

# USB 打印机
svn export https://github.com/coolsnowwolf/luci/trunk/applications/luci-app-usb-printer package/lean/luci-app-usb-printer

# KMS 激活助手
svn export https://github.com/coolsnowwolf/luci/trunk/applications/luci-app-vlmcsd package/lean/luci-app-vlmcsd
svn export https://github.com/coolsnowwolf/packages/trunk/net/vlmcsd package/lean/vlmcsd

# 网络唤醒
svn export https://github.com/zxlhhyccc/bf-package-master/trunk/zxlhhyccc/luci-app-services-wolplus package/new/luci-app-services-wolplus

# 流量监视
git clone -b master --depth 1 https://github.com/brvphoenix/wrtbwmon.git package/new/wrtbwmon
git clone -b master --depth 1 https://github.com/brvphoenix/luci-app-wrtbwmon.git package/new/luci-app-wrtbwmon

# 翻译及部分功能优化
svn export https://github.com/JSZMonkey/OpenWrt-Add/trunk/addition-trans-zh package/lean/lean-translate
sed -i 's,iptables-mod-fullconenat,iptables-nft +kmod-nft-fullcone,g' package/lean/lean-translate/Makefile

### 最后的收尾工作 ###

# Lets Fuck
mkdir package/base-files/files/usr/bin
wget -P package/base-files/files/usr/bin/ https://github.com/JSZMonkey/OpenWrt-Add/raw/master/fuck

# 最大连接数
sed -i 's/16384/65535/g' package/kernel/linux/files/sysctl-nf-conntrack.conf

# 生成默认配置及缓存
rm -rf .config

echo '
CONFIG_RESERVE_ACTIVEFILE_TO_PREVENT_DISK_THRASHING=y
CONFIG_RESERVE_ACTIVEFILE_KBYTES=65536
CONFIG_RESERVE_INACTIVEFILE_TO_PREVENT_DISK_THRASHING=y
CONFIG_RESERVE_INACTIVEFILE_KBYTES=65536
CONFIG_LRNG=y
# CONFIG_LRNG_OVERSAMPLE_ENTROPY_SOURCES is not set
CONFIG_LRNG_IRQ=y
CONFIG_LRNG_CONTINUOUS_COMPRESSION_ENABLED=y
# CONFIG_LRNG_CONTINUOUS_COMPRESSION_DISABLED is not set
CONFIG_LRNG_ENABLE_CONTINUOUS_COMPRESSION=y
# CONFIG_LRNG_SWITCHABLE_CONTINUOUS_COMPRESSION is not set
# CONFIG_LRNG_COLLECTION_SIZE_32 is not set
# CONFIG_LRNG_COLLECTION_SIZE_256 is not set
# CONFIG_LRNG_COLLECTION_SIZE_512 is not set
CONFIG_LRNG_COLLECTION_SIZE_1024=y
# CONFIG_LRNG_COLLECTION_SIZE_2048 is not set
# CONFIG_LRNG_COLLECTION_SIZE_4096 is not set
# CONFIG_LRNG_COLLECTION_SIZE_8192 is not set
CONFIG_LRNG_COLLECTION_SIZE=1024
# CONFIG_LRNG_HEALTH_TESTS is not set
CONFIG_LRNG_IRQ_ENTROPY_RATE=256
# CONFIG_LRNG_JENT is not set
CONFIG_LRNG_CPU=y
CONFIG_LRNG_CPU_ENTROPY_RATE=8
# CONFIG_LRNG_DRNG_SWITCH is not set
# CONFIG_LRNG_TESTING_MENU is not set
# CONFIG_LRNG_SELFTEST is not set
# CONFIG_IR_SANYO_DECODER is not set
# CONFIG_IR_SHARP_DECODER is not set
# CONFIG_IR_MCE_KBD_DECODER is not set
# CONFIG_IR_XMP_DECODER is not set
# CONFIG_IR_IMON_DECODER is not set
# CONFIG_IR_RCMM_DECODER is not set
# CONFIG_IR_SPI is not set
# CONFIG_IR_GPIO_TX is not set
# CONFIG_IR_PWM_TX is not set
# CONFIG_IR_SERIAL is not set
# CONFIG_IR_SIR is not set
# CONFIG_RC_XBOX_DVD is not set
# CONFIG_IR_TOY is not set
' >>./target/linux/generic/config-5.10

### Shortcut-FE 部分 ###

# Patch Kernel 以支持 Shortcut-FE
wget -P target/linux/generic/hack-5.10/ https://github.com/coolsnowwolf/lede/raw/master/target/linux/generic/hack-5.10/953-net-patch-linux-kernel-to-support-shortcut-fe.patch

# Patch LuCI 以增添 Shortcut-FE 开关
patch -p1 < ../PATCH/firewall/luci-app-firewall_add_sfe_switch.patch

# Shortcut-FE 相关组件
svn export https://github.com/coolsnowwolf/lede/trunk/package/lean/shortcut-fe/fast-classifier package/lean/fast-classifier
svn export https://github.com/coolsnowwolf/lede/trunk/package/lean/shortcut-fe/shortcut-fe package/lean/shortcut-fe
svn export https://github.com/coolsnowwolf/lede/trunk/package/lean/shortcut-fe/simulated-driver package/lean/simulated-driver

