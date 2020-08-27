#!/bin/bash

#THISHOST=$(hostname)
#INSTANCE=$(echo $HOSTNAME | cut -d- -f2)

TMC_HOME=$TC_ROOT/mgmt_console

# Jenkins
#echo "Starting jenkins agent @myjenkins"
#cd /data/jenkins/agent
#java -jar agent.jar -jnlpUrl http://myjenkins:8080/computer/$THISHOST/slave-agent.jnlp -secret @secret-file -workDir "/data/jenkins" > /dev/null 2>&1 &

cd ~
$TMC_HOME/container/bin/start
