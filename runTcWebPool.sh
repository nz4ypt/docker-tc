#!/bin/bash

THISHOST=$(hostname)
INSTANCE=$(echo $HOSTNAME | cut -d- -f2)

FSC_HOME=$TC_ROOT/fsc

# Tomcat
rm -f $WEBAPPS_DIR/tomcat/tomcat.pid 2>/dev/null
$WEBAPPS_DIR/tomcat/bin/startup.sh

# FSC Slave
if [ "$INSTANCE" == "tcserver1" ]; then
    echo "This is tcserver1, good to go."
    $FSC_HOME/rc.ugs.FSC_tcserver1_vol
else
    echo "Generating FSC configuration for $INSTANCE"
    sed "s/tcserver1/$INSTANCE/" $FSC_HOME/rc.ugs.FSC_tcserver1_vol > $FSC_HOME/rc.ugs.FSC_${INSTANCE}_vol
    sed "s/tcserver1/$INSTANCE/" $FSC_HOME/FSC_tcserver1_vol.xml > $FSC_HOME/FSC_${INSTANCE}_vol.xml
    chmod ug+x $FSC_HOME/rc.ugs.FSC_${INSTANCE}_vol
    $FSC_HOME/rc.ugs.FSC_${INSTANCE}_vol
fi

# Prep Pool configuration

TMPL=tcua12
cd $TC_ROOT/pool_manager/confs

if [ ! -d $INSTANCE ]; then
    cp -r $TMPL $INSTANCE
    mv $INSTANCE/rc.tc.mgr_${TMPL}_PoolA $INSTANCE/rc.tc.mgr_${INSTANCE}_PoolA
    for f in mgrstart mgrstop tcenv rc.tc.mgr_${INSTANCE}_PoolA; do
        sed -i -e "s|$TMPL|$INSTANCE|g" $INSTANCE/$f
    done
    rm $INSTANCE/tecs.out
    rm -rf $INSTANCE/logs/*
else
    echo "$INSTANCE already exists"
fi
 

# Jenkins
echo "Starting jenkins agent @myjenkins"
cd /data/jenkins/agent
java -jar agent.jar -jnlpUrl http://myjenkins:8080/computer/$THISHOST/slave-agent.jnlp -secret @secret-file -workDir "/data/jenkins" > /dev/null 2>&1 &

cd ~
$TC_ROOT/pool_manager/confs/$INSTANCE/rc.tc.mgr_${INSTANCE}_PoolA start
