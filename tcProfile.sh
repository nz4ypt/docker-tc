#!/bin/bash

export JAVA_HOME=/etc/alternatives/jre
export JRE_HOME=/etc/alternatives/jre
export JRE64_HOME=/etc/alternatives/jre

export TC_ROOT=/apps/siemens/tc12.2.0.4
export FMS_HOME=$TC_ROOT/tccs

export TC_LOG=/data/tclogs
export TC_LOGS=/data/tclogs
export TC_TMP_DIR=/data/tclogs
export TC_DATA=/data/tcdata

. $TC_DATA/tc_profilevars

export TC_KEEP_SYSTEM_LOG=Y

echo TC_ROOT=$TC_ROOT
echo TC_DATA=$TC_DATA
echo TC_DB_CONNECT=$TC_DB_CONNECT
