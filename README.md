
<h1 align="center">请勿用于商业用途!!!</h1>


### 特性

- 基于原生 OpenWrt 21.02 编译，默认管理地址192.168.0.1
- 同时支持 SFE/Software Offload （选则其一开启，默认均不开启）
- 内置升级功能可用，物理 Reset 按键可用
- 预配置了部分插件（包括但不限于 DNS 套娃，使用时先将 SSRP 的 DNS 上游提前选成本机5335端口，然后再 ADG 中勾上启用就好*“管理账户root，密码admin”，如果要作用于路由器本身，可以把lan和wan的dns都配置成127.0.0.1，dhcp高级里设置下发dns 6,192.168.0.1。注：这里取决于你设定的路由的ip地址）
- 正式 Release 版本将具有可无脑 opkg kmod 的特性
- R4S核心频率2.2/1.8（特调了电压表，兼容5v3a的供电，但建议使用5v4a）
- O2 编译，性能更可靠
- 插件包含：SSRP，AdguardHome，BearDropper，SQM，SmartDNS，网络共享，硬盘休眠，挂载点，网络唤醒，DDNS，UPNP，FullCone(防火墙中开启，默认开启)，流量分载(防火墙中开启)，SFE流量分载(也就是SFE加速，防火墙中开启，且默认开启)，BBR（默认开启），irq优化，无线打印，流量监控，过滤军刀，R2S-OLED，带宽监控，ttyd，Docker，qBittorrent-Enhanced-Edition

- 如有任何问题，请先尝试ssh进入后台，输入fuck后回车，等待机器重启后确认问题是否已经解决
