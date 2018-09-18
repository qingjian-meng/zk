#!/bin/bash
sed -i '/usr/local/zabbix/sbin/zabbix_agentd/d' /etc/init.d/boot.local
echo "/usr/local/zabbix/sbin/zabbix_agentd -c /usr/local/zabbix/etc/zabbix_agentd.conf" >> /etc/init.d/boot.local

chmod +x /etc/init.d/boot.local
