#!/bin/bash
main() {
    workdir=`dirname ${0}`
    cd $workdir
    while [[ $# >0 ]]; do
        key=$1
        shift
        case $key in
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
            -p1)
                port1=$1
                shift
                ;;
            -p2)
                port2=$1
                shift
                ;;
            -p3)
               port3=$1
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
    if [ -z "$port1" ];then
        port1=2888
    fi
    if [ -z "$port2" ];then
        port2=3888
    fi
    if [ -z "$port3" ];then
        port3=2181
    fi
    deploy_zk
}
usage() {
    echo -e "\n Deploy zookeeper"
    echo " Usage: $0 [OPTIONS]...[AGES]\n"
    echo "   -s1   zookeeper server 1"
    echo "   -s2   zookeeper server 2"
    echo "   -s3   zookeeper server 3"
    echo "   -p1   this port is a communication between master and slave port, the default is 2888"
    echo -e "   -p2   this port is the port of the leader election, the default is 3888"
    echo -e "   -p3   this port is the port of the zookeeper listen on, the default is 2181"
    echo -e " example: $0 -s1 192.168.1.10 -s2 192.168.1.11 -s3 192.168.1.12 \n"
}
deploy_zk() {
    tar -zxf ./zookeeper-3.4.12.tar.gz -C /opt/
    ZK_HOME="/opt/zookeeper-3.4.12"
    #echo "export ZK_HOME=/opt/zookeeper-3.4.12" >> /etc/profile
    #echo "export PATH=$ZK_HOME/bin:$PATH" >> /etc/profile
    #source /etc/profile
    if [ -d "/zookeeperData" ];then
        rm -fr /zookeeperData
    fi
    if [ -d "/zookeeperDataLog" ];then
        rm -fr /zookeeperDataLog
    fi
    mkdir /zookeeperData
    mkdir /zookeeperDataLog
    echo -e "tickTime=2000\ninitLimit=10\nsyncLimit=5\ndataDir=/zookeeperData\ndataLogDir=/zookeeperDataLog\nclientPort=$port3\nserver.1=$server1:$port1:$port2\nserver.2=$server2:$port1:$port2\nserver.3=$server3:$port1:$port2" > $ZK_HOME/conf/zoo.cfg
    IP=`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`
    if [ $IP = $server1 ];then
        echo 1 > /zookeeperData/myid
    fi
    if [ $IP = $server2 ];then
        echo 2 > /zookeeperData/myid
    fi
    if [ $IP = $server3 ];then
        echo 3 > /zookeeperData/myid
    fi

    $ZK_HOME/bin/zkServer.sh start
    status=`jps | grep QuorumPeerMain | wc -l`
    if [ $status = 1 ];then
	    echo "export ZK_HOME=/opt/zookeeper-3.4.12" >> /etc/profile
        echo "export PATH=\$ZK_HOME/bin:\$PATH" >> /etc/profile
        echo "zk installed successfuly on $IP."
    else
        echo "installed failed on $IP."
    fi
}
main "$@"
