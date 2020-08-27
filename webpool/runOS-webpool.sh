#!/bin/sh
groupadd -g 1000 dba  && \
useradd -u 1000 -g 1000 -s /bin/bash -d /home/infodba -m infodba && \
yum -y install epel-release && \
yum -y install ksh csh libaio libgomp unzip openssl tomcat-native java-11-openjdk git && \
mkdir -p $WEBAPPS_DIR && \
mkdir -p $SIEMENS_DIR && \
mkdir -p $TCDATA_DIR && \
mkdir -p /data/tclogs/tcorcl && \
chown infodba:dba $WEBAPPS_DIR $SIEMENS_DIR $TCDATA_DIR
