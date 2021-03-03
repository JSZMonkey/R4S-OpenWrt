<p align="center">
<img width="768" src="https://raw.githubusercontent.com/QiuSimons/Others/master/YAOF.png" >
</p>
<p align="center">
<img src="https://forthebadge.com/images/badges/built-with-love.svg">
<p>
<p align="center">
<img alt="GitHub All Releases" src="https://img.shields.io/github/downloads/QiuSimons/R2S-R4S-X86-OpenWrt/total?style=for-the-badge">
<img alt="GitHub" src="https://img.shields.io/github/license/QiuSimons/R2S-R4S-X86-OpenWrt?style=for-the-badge">


<h1 align="center">请勿用于商业用途!!!</h1>


### 特性

- 基于原生 OpenWrt 21.02 编译
- 同时支持 SFE/Software Offload （选则其一开启，默认均不开启）
- 内置升级功能可用，物理 Reset 按键可用
- 预配置了部分插件（包括但不限于 DNS 套娃，使用时先将 SSRP 的 DNS 上游提前选成本机5335端口，然后再 ADG 中勾上启用就好，如果要作用于路由器本身，可以把lan和wan的dns都配置成127.0.0.1，dhcp高级里设置下发dns 6,192.168.1.1。注：这里取决于你设定的路由的ip地址）
- 正式 Release 版本将具有可无脑 opkg kmod 的特性
- R4S核心频率2.2/1.8（特调了电压表，兼容5v3a的供电，但建议使用5v4a）
- O2 编译，性能更可靠
- 插件包含：SSRP，AdguardHome，BearDropper，SQM，SmartDNS，网络共享，硬盘休眠，挂载点，网络唤醒，DDNS，UPNP，FullCone(防火墙中开启，默认开启)，流量分载(防火墙中开启)，SFE流量分载(也就是SFE加速，防火墙中开启，且默认开启)，BBR（默认开启），irq优化，无线打印，流量监控，过滤军刀，R2S-OLED，带宽监控，ttyd，Docker，qBittorrent-Enhanced-Edition


### 截图

|                      组件                       |                      流量分载                       |
| :----------------------------------------------------------: | :----------------------------------------------------------: |
| ![主页.png](https://raw.githubusercontent.com/QiuSimons/R4S-OpenWrt/master/PIC/app.png) | ![offload.png](https://raw.githubusercontent.com/QiuSimons/R4S-OpenWrt/master/PIC/offload.png) |

### 鸣谢

|          [CTCGFW](https://github.com/immortalwrt)           |           [coolsnowwolf](https://github.com/coolsnowwolf)            |              [Lienol](https://github.com/Lienol)               |              [NoTengoBattery](https://github.com/NoTengoBattery)               |
| :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: |
| <img width="120" src="https://avatars.githubusercontent.com/u/53193414"/> | <img width="120" src="https://avatars.githubusercontent.com/u/31687149" /> | <img width="120" src="https://avatars.githubusercontent.com/u/23146169" /> | <img width="120" src="https://avatars.githubusercontent.com/u/11285513" /> |
