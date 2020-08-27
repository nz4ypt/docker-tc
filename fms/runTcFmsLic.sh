#!/bin/bash

THISHOST=$(hostname)
INSTANCE=$(echo $HOSTNAME | cut -d- -f2)

FSC_HOME=$TC_ROOT/fsc


echo "Starting SPLM License"
$TC_ROOT/flexlm/splmld_cntl start

echo "FMS Master Daemon"
$TC_ROOT/fsc/rc.ugs.FSC_docker_vol

# Jenkins
echo "Starting jenkins agent @myjenkins"
cd /data/jenkins/agent
java -jar agent.jar -jnlpUrl http://myjenkins:8080/computer/$THISHOST/slave-agent.jnlp -secret @secret-file -workDir "/data/jenkins" > /dev/null 2>&1 &

