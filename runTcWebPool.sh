#!/bin/bash

THISHOST=$(hostname)
INSTANCE=$(echo $HOSTNAME | cut -d- -f2)

FSC_HOME=$TC_ROOT/fsc

# Tomcat
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

# Pool Manager
$TC_ROOT/pool_manager/confs/tcua12/mgrstart
