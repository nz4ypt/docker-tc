#!/bin/bash

THISHOST=$(hostname)
INSTANCE=$(echo $HOSTNAME | cut -d- -f2)

FSC_HOME=$TC_ROOT/fsc

# Tomcat
if [ ! -f $WEBAPPS_DIR/tomcat/conf/ldap.config ]; then
cat << EOF > $WEBAPPS_DIR/tomcat/conf/ldap.config
MgmtLdapConfig {
 com.sun.security.auth.module.LdapLoginModule REQUIRED
   userProvider="ldap://docker-tmc:15389/ou=Users,ou=Management,ou=JETI,
dc=Teamcenter,dc=PLM,o=Siemens"
   authIdentity="uid={USERNAME},ou=Users,ou=Management,ou=JETI,
dc=Teamcenter,dc=PLM,o=Siemens"		
   authzIdentity=controlRole
   useSSL=false
   debug=false;
};
EOF
fi


# clean up ROOT deployment
rm -rf $WEBAPPS_DIR/tomcat/webapps/ROOT/* >/dev/null 2>&1
mkdir $WEBAPPS_DIR/tomcat/webapps/ROOT/WEB-INF
cat << EOF > $WEBAPPS_DIR/tomcat/webapps/ROOT/WEB-INF/web.xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app>
  <display-name>Welcome to Tomcat</display-name>
  <description>
     Welcome to Teamcenter 12 in Docker
  </description>
  <welcome-file-list>  
     <welcome-file>index.html</welcome-file>  
     <welcome-file>index.htm</welcome-file>  
  </welcome-file-list>  
</web-app>
EOF

cat << EOF > $WEBAPPS_DIR/tomcat/webapps/ROOT/index.html
<h3>Welcome to Teamcenter 12 in Docker</h3>
<h4>Application URLs</h4>
<ul>
<li><a href=http://docker-lb/awc>Active Workspace &nbsp;&nbsp;(infodba/infodba)</a></li>
<li><a href=http://docker-lb:8083/mgmt/console>Management Console &nbsp;&nbsp;(admin/infodba)</a></li>
<li><a href=http://docker-lb:81>Jenkins &nbsp;&nbsp;(jenkins/jenkins)</a></li>
</ul>
<h4>Application Heartbeat</h4>
<ul> 
<li><a href=http://docker-lb/tc/controller/test>WEB Heartbeat</a></li>
<li><a href=http://docker-lb/awc/tc/controller/test>AWC Heartbeat</a></li>
<li><a href=http://docker-lb:4544/configAvailableFSCsRequest>FMS Heartbeat</a></li>
</ul>
<br><br>
<pre>
Note: Assuming you have docker host entry added
as docker-lb.
i.e. in /etc/hosts
192.168.1.15  docker-lb
</pre>
EOF


# clean up default apps
rm -rf $WEBAPPS_DIR/tomcat/webapps/host-manager >/dev/null 2>&1
rm -rf $WEBAPPS_DIR/tomcat/webapps/manager >/dev/null 2>&1
rm -rf $WEBAPPS_DIR/tomcat/webapps/docs >/dev/null 2>&1
rm -rf $WEBAPPS_DIR/tomcat/webapps/examples >/dev/null 2>&1


# Clean up existing PID and start tomcat
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
rm -f $TC_ROOT/pool_manager/confs/$INSTANCE/mgr.tmp 2>/dev/null
$TC_ROOT/pool_manager/confs/$INSTANCE/rc.tc.mgr_${INSTANCE}_PoolA start
