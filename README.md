自定义自用固件


### 特性
- R4S 集成 GPU 驱动（支持 Jellyfin 硬解）
- 基于原生 OpenWrt 21.02 编译，默认管理地址192.168.0.1
- 插件包含：SSRP，AdguardHome，SQM，网络唤醒，AliDNS，UPNP，FullCone(防火墙中开启，默认开启)，流量分载，SFE流量分载，irq优化，过滤军刀，挂载点，网络共享，硬盘休眠，终端，网速控制
- ss协议在armv8上实现了aes硬件加速（请<b>仅使用aead加密</b>的连接方式）
- 如有任何问题，请先尝试ssh进入后台，输入fuck后回车，等待机器重启后确认问题是否已经解决
- 使用dnsfilter作为广告过滤手段，使用dnsproxy作为dns分流措施，海外端口5335，国内端口6050，无GUI，自行琢磨使用。或可尝试ssh进入后台，输入setdns后回车，使用预设的dns方案)
