#!/bin/sh
groupadd -g 1000 dba  && \
useradd -u 1000 -g 1000 -s /bin/bash -d /home/infodba -m infodba && \
yum -y install epel-release && \
yum -y install ksh csh libaio libgomp unzip openssl tomcat-native java-11-openjdk git && \
echo "install nodejs 12 for aw5.1" && \
yum -y remove nodejs && \ 
curl -sL https://rpm.nodesource.com/setup_12.x | bash && \
yum clean all && yum makecache fast && \
yum install -y gcc-c++ make && \
yum install -y nodejs && \
mkdir -p $SIEMENS_DIR && \
mkdir -p $TCDATA_DIR && \
mkdir -p /data/tclogs/tcorcl && \
chown infodba:dba $SIEMENS_DIR $TCDATA_DIR
