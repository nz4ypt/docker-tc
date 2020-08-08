#
export JRE_HOME=/etc/alternatives/jre
export JAVA_HOME=/etc/alternatives/jre
export CATALINA_PID="$CATALINA_BASE/tomcat.pid"

### Env specific settings
export JMX_PORT=8081
export SERVER_NAME=tc-web-pool
export TCENV=/some/placeholder/script.sh
umask 002
# ulimit -c unlimited

### =====================================================
### =======   PLEASE DO NOT CHANGE BELOW LINES   ========
### =====================================================
###
if [ -r "$TCENV" ]; then
  echo "Sourcing Teamcenter configurations..."
  . $TCENV
fi

# Use non-blocking entropy source
export JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom ${JAVA_OPTS}"

export CATALINA_OPTS="-Denv=${SERVER_NAME}"

if [ "x$JMX_PORT" == "x" ]; then
        echo "JMX_PORT is not set"
else
        echo "JMX_PORT is set as $JMX_PORT"
        export CATALINA_OPTS="$CATALINA_OPTS -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=$JMX_PORT -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"
fi

echo -- "----------------------------------"
echo "Using CATALINA_OPTS:"
for arg in $CATALINA_OPTS; do
        echo ">> " $arg
done
echo -- "----------------------------------"
echo "Using JAVA_OPTS:"
for arg in $JAVA_OPTS; do
        echo ">> " $arg
done
echo -- "----------------------------------"

echo "Continue in 5 sec ..."
sleep 5

