#!/bin/bash
workdir=`dirname ${0}`
cd $workdir
bahs -lc "java -version"
if [ $? = 0 ];then
    echo "Java is installed"
    exit 1
else
    echo "installing Java...."
    tar -zxf ./jdk-8u65-linux-x64.tar.gz -C /opt/
    JAVA_HOME="/opt/jdk1.8.0_65"
	sed -i '/^export JAVA_HOME=/d' /etc/profile
	sed -i '/^export CLASSPATH=/d' /etc/profile
	sed -i '/^export PATH=$JAVA_HOME/d' /etc/profile
    echo "export JAVA_HOME=/opt/jdk1.8.0_65" >> /etc/profile
    echo "export CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar" >> /etc/profile
    echo "export PATH=\$JAVA_HOME/bin:$PATH" >> /etc/profile
    sleep 1
    source /etc/profile
    echo "installed successful"
fi
