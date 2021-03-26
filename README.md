自定义自用固件
<code>
sed -i 's/port: 5335/port: 5333/g' /etc/config/AdGuardHome.yaml
/etc/init.d/AdGuardHome restart
<code>
