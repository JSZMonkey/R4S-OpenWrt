#!/bin/bash
clear

#更换为 ImmortalWrt Uboot 以及 Target
rm -rf ./target/linux/rockchip
svn co https://github.com/immortalwrt/immortalwrt/branches/master/target/linux/rockchip target/linux/rockchip
rm -rf ./package/boot/uboot-rockchip
svn co https://github.com/immortalwrt/immortalwrt/branches/master/package/boot/uboot-rockchip package/boot/uboot-rockchip
svn co https://github.com/immortalwrt/immortalwrt/branches/master/package/boot/arm-trusted-firmware-rk3328 package/boot/arm-trusted-firmware-rk3328

#超频到 2.2/1.8 GHz
rm -rf ./target/linux/rockchip/patches-5.4/992-rockchip-rk3399-overclock-to-2.2-1.8-GHz-for-NanoPi4.patch
cp -f ../PATCH/new/main/991-rockchip-rk3399-overclock-to-2.2-1.8-GHz-for-NanoPi4.patch ./target/linux/rockchip/patches-5.4/991-rockchip-rk3399-overclock-to-2.2-1.8-GHz-for-NanoPi4.patch
cp -f ../PATCH/new/main/213-RK3399-set-critical-CPU-temperature-for-thermal-throttling.patch ./target/linux/rockchip/patches-5.4/213-RK3399-set-critical-CPU-temperature-for-thermal-throttling.patch

#使用特定的优化
sed -i 's,-mcpu=generic,-march=armv8-a+crypto+crc -mabi=lp64,g' include/target.mk
cp -f ../PATCH/new/package/100-Implements-AES-and-GCM-with-ARMv8-Crypto-Extensions.patch ./package/libs/mbedtls/patches/100-Implements-AES-and-GCM-with-ARMv8-Crypto-Extensions.patch
sed -i 's,kmod-r8169,kmod-r8168,g' target/linux/rockchip/image/armv8.mk
#测试性功能
sed -i '/CRYPTO_DEV_ROCKCHIP/d' ./target/linux/rockchip/armv8/config-5.4
sed -i '/HW_RANDOM_ROCKCHIP/d' ./target/linux/rockchip/armv8/config-5.4
echo '
CONFIG_CRYPTO_DEV_ROCKCHIP=y
CONFIG_HW_RANDOM_ROCKCHIP=y
' >> ./target/linux/rockchip/armv8/config-5.4

#IRQ 调优
sed -i '/set_interface_core 20 "eth1"/a\set_interface_core 8 "ff3c0000" "ff3c0000.i2c"' target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity
sed -i '/set_interface_core 20 "eth1"/a\ethtool -C eth0 rx-usecs 1000 rx-frames 25 tx-usecs 100 tx-frames 25' target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity

#翻译及部分功能优化
cp -rf ../PATCH/duplicate/addition-trans-zh ./package/lean/lean-translate
sed -i "/commit luci/a\uci set cpufreq.cpufreq.maxfreq4='2208000'" ./package/lean/lean-translate/files/zzz-default-settings
sed -i "/commit luci/a\uci set cpufreq.cpufreq.maxfreq0='1800000'" ./package/lean/lean-translate/files/zzz-default-settings

#内核加解密模块
echo '
CONFIG_ARM64_CRYPTO=y
CONFIG_CRYPTO_SHA256_ARM64=y
CONFIG_CRYPTO_SHA512_ARM64=y
CONFIG_CRYPTO_SHA1_ARM64_CE=y
CONFIG_CRYPTO_SHA2_ARM64_CE=y
# CONFIG_CRYPTO_SHA512_ARM64_CE is not set
CONFIG_CRYPTO_SHA3_ARM64=y
CONFIG_CRYPTO_SM3_ARM64_CE=y
CONFIG_CRYPTO_SM4_ARM64_CE=y
CONFIG_CRYPTO_GHASH_ARM64_CE=y
# CONFIG_CRYPTO_CRCT10DIF_ARM64_CE is not set
CONFIG_CRYPTO_AES_ARM64=y
CONFIG_CRYPTO_AES_ARM64_CE=y
CONFIG_CRYPTO_AES_ARM64_CE_CCM=y
CONFIG_CRYPTO_AES_ARM64_CE_BLK=y
CONFIG_CRYPTO_AES_ARM64_NEON_BLK=y
CONFIG_CRYPTO_CHACHA20_NEON=y
CONFIG_CRYPTO_POLY1305_NEON=y
CONFIG_CRYPTO_NHPOLY1305_NEON=y
CONFIG_CRYPTO_AES_ARM64_BS=y
' >> ./target/linux/rockchip/armv8/config-5.4


echo '
CONFIG_RC_CORE=y
CONFIG_LIRC=y
CONFIG_RC_DECODERS=y
CONFIG_RC_DEVICES=y
CONFIG_DRM=y
CONFIG_DRM_LOAD_EDID_FIRMWARE=y
CONFIG_DRM_FBDEV_EMULATION=y
CONFIG_DRM_FBDEV_OVERALLOC=100
CONFIG_DRM_BRIDGE=y
CONFIG_HDMI=y
CONFIG_PHY_ROCKCHIP_INNO_HDMI=y
CONFIG_DRM_DW_HDMI=y
CONFIG_DRM_DW_HDMI_CEC=y
CONFIG_ROCKCHIP_DW_HDMI=y
CONFIG_ROCKCHIP_INNO_HDMI=y
CONFIG_ROCKCHIP_DW_MIPI_DSI=y
CONFIG_ROCKCHIP_LVDS=y
CONFIG_DRM_PANEL=y
CONFIG_DRM_PANEL_BRIDGE=y
CONFIG_DRM_PANEL_SIMPLE=y
CONFIG_DRM_VGEM=y
CONFIG_DRM_GEM_CMA_HELPER=y
CONFIG_DRM_LIMA=y
' >> ./target/linux/rockchip/armv8/config-5.4

#R4S 添加GPU驱动
rm -rf ./package/kernel/linux/modules/video.mk
wget -P package/kernel/linux/modules/ https://github.com/immortalwrt/immortalwrt/raw/master/package/kernel/linux/modules/video.mk

#Vermagic
latest_version="$(curl -s https://github.com/openwrt/openwrt/releases |grep -Eo "v[0-9\.]+\-*r*c*[0-9]*.tar.gz" |sed -n '/21/p' |sed -n 1p |sed 's/v//g' |sed 's/.tar.gz//g')"
wget https://downloads.openwrt.org/releases/${latest_version}/targets/rockchip/armv8/packages/Packages.gz
zgrep -m 1 "Depends: kernel (=.*)$" Packages.gz | sed -e 's/.*-\(.*\))/\1/' > .vermagic
sed -i -e 's/^\(.\).*vermagic$/\1cp $(TOPDIR)\/.vermagic $(LINUX_DIR)\/.vermagic/' include/kernel-defaults.mk

#更改默认IP地址
sed -i 's/192.168.1.1/192.168.0.1/g' package/base-files/files/bin/config_generate

#预配置一些插件
cp -rf ../PATCH/R4S/files ./files
chmod -R 755 ./
find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

exit 0
