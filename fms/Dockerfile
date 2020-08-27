
FROM centos:7 as base

# -------------------------------------------------------------
# Env variables
# -------------------------------------------------------------
ENV SIEMENS_DIR=/apps/siemens \
    TCDATA_DIR=/data/tcdata \
    INSTALL_DIR=/apps/installers \
    SETUP_OS_FILE=runOS-fmslic.sh \
    RUN_TC_FILE=runTcFmsLic.sh \
    JAVA_HOME=/etc/alternatives/jre \
    TC_ROOT=/apps/siemens/tc12.2.0.4 \
    TC_DATA=/data/tcdata \
    TC_LOG=/data/tclogs \
    TC_LOGS=/data/tclogs \
    TC_TMP_DIR=/data/tclogs

COPY $SETUP_OS_FILE $INSTALL_DIR/

RUN chmod ug+x $INSTALL_DIR/*.sh && \
    sync && \
    $INSTALL_DIR/$SETUP_OS_FILE && \
    rm -rf $INSTALL_DIR

#EXPOSE 4544
#EXPOSE 28000
#EXPOSE 28001

COPY $RUN_TC_FILE /usr/local/bin/

RUN chown infodba:dba /usr/local/bin/$RUN_TC_FILE && \
    chmod ug+x /usr/local/bin/$RUN_TC_FILE
#
# shared from host
#COPY tcroot
#COPY tcdata

USER infodba
WORKDIR /home/infodba

# Default command for runtime
#CMD $TC_ROOT/flexlm/splmld_cntl start ; $TC_ROOT/fsc/rc.ugs.FSC_docker_vol ; /bin/bash
CMD /usr/local/bin/$RUN_TC_FILE ; /bin/bash


