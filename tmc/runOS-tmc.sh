#!/bin/sh
groupadd -g 1000 dba  && \
useradd -u 1000 -g 1000 -s /bin/bash -d /home/infodba -m infodba && \
yum -y install epel-release && \
yum -y install ksh csh unzip java-11-openjdk git && \
mkdir -p $SIEMENS_DIR && \
chown infodba:dba $SIEMENS_DIR
