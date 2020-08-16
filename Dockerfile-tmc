
FROM centos:7 as base

# -------------------------------------------------------------
# Env variables
# -------------------------------------------------------------
ENV SIEMENS_DIR=/apps/siemens \
    INSTALL_DIR=/apps/installers \
    SETUP_OS_FILE=runOS-tmc.sh \
    RUN_TC_FILE=runTcConsole.sh \
    JAVA_HOME=/etc/alternatives/jre \
    TC_ROOT=/apps/siemens/tc12.2.0.4 \
    TC_LOG=/data/tclogs \
    TC_LOGS=/data/tclogs \
    TC_TMP_DIR=/data/tclogs

COPY $SETUP_OS_FILE $INSTALL_DIR/

RUN chmod ug+x $INSTALL_DIR/*.sh && \
    sync && \
    $INSTALL_DIR/$SETUP_OS_FILE && \
    rm -rf $INSTALL_DIR

#EXPOSE 8083


COPY $RUN_TC_FILE /usr/local/bin/

RUN chown infodba:dba /usr/local/bin/$RUN_TC_FILE && \
    chmod ug+x /usr/local/bin/$RUN_TC_FILE

# shared from host
#COPY tcroot

USER infodba
WORKDIR /home/infodba

# Default command for runtime
#CMD $WEBAPPS_DIR/tomcat/bin/startup.sh ; $TC_ROOT/pool_manager/confs/tcua12/mgrstart ; /bin/bash
CMD /usr/local/bin/$RUN_TC_FILE ; /bin/bash


