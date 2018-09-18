#!/bin/bash
sed -i '/JAVA_HOME=/d' /etc/init.d/boot.local
sed -i '/zkServer.sh/d' /etc/init.d/boot.local
sed -i '/kafka_2.11-1.1.0/d' /etc/init.d/boot.local
echo "export JAVA_HOME=/opt/jdk1.8.0_65" >> /etc/init.d/boot.local
echo "/opt/zookeeper-3.4.12/bin/zkServer.sh start" >> /etc/init.d/boot.local
echo "/opt/kafka_2.11-1.1.0/bin/kafka-server-start.sh -daemon /opt/kafka_2.11-1.1.0/config/server.properties" >> /etc/init.d/boot.local
chmod +x /etc/init.d/boot.local

