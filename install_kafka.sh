#!/bin/bash
main() {
    workdir=`dirname ${0}`
    cd $workdir
    while [[ $# >0 ]]; do
        key=$1
        shift
        case $key in
            -id)
                broker_id=$1
                shift
                ;;
            -s1)
                server1=$1
                shift
                ;;
            -s2)
                server2=$1
                shift
                ;;
            -s3)
                server3=$1
                shift
                ;;
            -p)
                port=$1
                shift
                ;;
             *)
                echo "ERROR: Unrecognized parameter(s): $*"
                usage
                exit 1
                ;;
        esac
    done
    if [ -z "$server1" ] || [ -z "$server2" ] || [ -z "$server3" ];then
        usage
        exit 2
    fi
    if [ -z "$port" ];then
        port=2181
    fi
    deploy_kafka
}
usage() {
    echo -e "\n Deploy kafka"
    echo " Usage: $0 [OPTIONS]...[AGES]\n"
    echo "   -id   broker_id, Unique in the cluster"
    echo "   -s1   zookeeper server 1"
    echo "   -s2   zookeeper server 2"
    echo "   -s3   zookeeper server 3"
    echo -e "   -p   this port is zookeeper connect port, the default is 2181\n"
    echo -e " example: $0 -id 0 -s1 192.168.1.10 -s2 192.168.1.11 -s3 192.168.1.12 \n "
}
deploy_kafka() {
tar -zxf kafka_2.11-1.1.0.tgz -C /opt/
if [ -d "/kafkalogs" ];then #根据实际机器挂载磁盘修改
    rm -fr /kafkalogs
fi
mkdir /kafkalogs #根据实际机器挂载磁盘修改
#KAFKA_HOME=/opt/kafka_2.11-1.1.0


sed -i '/^log.dirs=/d' /opt/kafka_2.11-1.1.0/config/server.properties
sed -i '/^broker.id/d' /opt/kafka_2.11-1.1.0/config/server.properties
sed -i '/^zookeeper.connect=/d' /opt/kafka_2.11-1.1.0/config/server.properties
sed -i '/^offsets.topic.replication.factor=1/d' /opt/kafka_2.11-1.1.0/config/server.properties
sed -i '/log.retention.bytes=/d' /opt/kafka_2.11-1.1.0/config/server.properties
sed -i '/log.retention.hours=/d' /opt/kafka_2.11-1.1.0/config/server.properties

echo -e  "\nbroker.id=$broker_id" >> /opt/kafka_2.11-1.1.0/config/server.properties
echo -e "zookeeper.connect=$server1:$port,$server2:$port,$server3:$port" >> /opt/kafka_2.11-1.1.0/config/server.properties
echo -e "offsets.topic.replication.factor=3" >> /opt/kafka_2.11-1.1.0/config/server.properties
IP=`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`
echo -e  "advertised.listeners=PLAINTEXT://$IP:9092" >> /opt/kafka_2.11-1.1.0/config/server.properties #根据实际机器开放端口修改
echo "log.dirs=/kafkalogs" >> /opt/kafka_2.11-1.1.0/config/server.properties #根据实际机器挂载磁盘修改
echo "log.retention.bytes=1073741824" >> /opt/kafka_2.11-1.1.0/config/server.properties
echo "log.retention.hours=72" >> /opt/kafka_2.11-1.1.0/config/server.properties
echo "log.cleanup.policy=delete" >> /opt/kafka_2.11-1.1.0/config/server.properties
echo "delete.topic.enable=true" >> /opt/kafka_2.11-1.1.0/config/server.properties
echo "auto.create.topics.enable=true" >> /opt/kafka_2.11-1.1.0/config/server.properties
/opt/kafka_2.11-1.1.0/bin/kafka-server-start.sh -daemon /opt/kafka_2.11-1.1.0/config/server.properties 
status=`jps | grep Kafka | wc -l`
    if [ $status = 1 ];then
	    echo "export KAFKA_HOME=/opt/kafka_2.11-1.1.0" >> /etc/profile
        echo "export PATH=\$PATH:\$KAFKA_HOME/bin" >> /etc/profile
        echo "kafka installed successfuly on $IP"
    else
        echo "installed failed on $IP"
    fi


}
main "$@"
