#!/bin/sh
groupadd -g 1000 dba  && \
useradd -u 1000 -g 1000 -s /bin/bash -d /home/infodba -m infodba && \
yum -y install lsb ksh csh libaio unzip openssl java-11-openjdk git && \
mkdir -p $SIEMENS_DIR && \
mkdir -p /data/tclogs/tcorcl && \
chown infodba:dba $SIEMENS_DIR
