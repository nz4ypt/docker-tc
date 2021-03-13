#!/bin/bash

#THISHOST=$(hostname)
#INSTANCE=$(echo $HOSTNAME | cut -d- -f2)
INSTANCE="tcdev12"

FSC_HOME=$TC_ROOT/fsc

## Tomcat
#if [ ! -f $WEBAPPS_DIR/tomcat/conf/ldap.config ]; then
#cat << EOF > $WEBAPPS_DIR/tomcat/conf/ldap.config
#MgmtLdapConfig {
#    com.sun.security.auth.module.LdapLoginModule REQUIRED
#        userProvider="ldap://tmc:15389/ou=Users,ou=Management,ou=JETI,dc=Teamcenter,dc=PLM,o=Siemens"
#        authIdentity="uid={USERNAME},ou=Users,ou=Management,ou=JETI,dc=Teamcenter,dc=PLM,o=Siemens"
#        authzIdentity=controlRole
#        useSSL=false
#        debug=false;
#    };
#EOF
#fi

# Start fsc 
#chmod ug+x $FSC_HOME/rc.ugs.FSC_${INSTANCE}_vol
#$FSC_HOME/rc.ugs.FSC_${INSTANCE}_vol
chmod ug+x $FSC_HOME/rc.ugs.FSC_Master_infodba
$FSC_HOME/rc.ugs.FSC_Master_infodba 

# Prep Pool configuration

cd $TC_ROOT/pool_manager/confs

rm $INSTANCE/tecs.out
rm -rf $INSTANCE/logs/*
[ ! -d $TC_LOGS ] || mkdir -p $TC_LOGS 2>/dev/null
 
# run clearlocks 
/apps/scripts/run_clearlocks.sh

cd ~


rm -f $TC_ROOT/pool_manager/confs/$INSTANCE/mgr.tmp 2>/dev/null
#$TC_ROOT/pool_manager/confs/$INSTANCE/rc.tc.mgr_${INSTANCE}_PoolA start
$TC_ROOT/pool_manager/confs/$INSTANCE/mgrstart

