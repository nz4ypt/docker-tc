#!/bin/bash

ORACLE_SID="`grep $ORACLE_HOME /etc/oratab | cut -d: -f1`"
OPEN_MODE="READ WRITE"
ORAENV_ASK=NO
DUMPFILE=infodba_tc12_lnx_ootb.dmp
source oraenv

while ! $($ORACLE_BASE/checkDBStatus.sh > /dev/null); do
    echo "Wait for PDB $ORACLE_PDB to open..."
    sleep 5
done

echo "PDB $ORACLE_PDB is $OPEN_MODE, executing custom scripts..."

sqlplus / as sysdba << EOF
    PROMPT SWITCHING TO PDB $ORACLE_PDB;
    ALTER SESSION SET CONTAINER=$ORACLE_PDB;
    PROMPT CREATING TEAMCENTER TABLESPACES;
    -- CREATE TABLESPACE IDATA DATAFILE '/opt/oracle/oradata/$ORACLE_SID/$ORACLE_PDB/IDATA.dat' SIZE 2024M AUTOEXTEND ON NEXT 50M;
    -- CREATE TABLESPACE INDX  DATAFILE '/opt/oracle/oradata/$ORACLE_SID/$ORACLE_PDB/INDX.dat'  SIZE 2024M AUTOEXTEND ON NEXT 50M;
    -- CREATE TABLESPACE ILOG  DATAFILE '/opt/oracle/oradata/$ORACLE_SID/$ORACLE_PDB/ILOG.dat'  SIZE   50M AUTOEXTEND ON NEXT 10M;
    CREATE TABLESPACE IDATA DATAFILE '/opt/oracle/oradata/$ORACLE_SID/$ORACLE_PDB/IDATA.dat' SIZE 50M AUTOEXTEND ON NEXT 10M;
    CREATE TABLESPACE INDX  DATAFILE '/opt/oracle/oradata/$ORACLE_SID/$ORACLE_PDB/INDX.dat'  SIZE 50M AUTOEXTEND ON NEXT 10M;
    CREATE TABLESPACE ILOG  DATAFILE '/opt/oracle/oradata/$ORACLE_SID/$ORACLE_PDB/ILOG.dat'  SIZE 50M AUTOEXTEND ON NEXT 10M
    PROMPT CREATING INFODBA ACCOUNT AND GRANTING PRIVILEGES;
    GRANT CONNECT, CREATE TABLE, CREATE TABLESPACE, CREATE PROCEDURE, CREATE VIEW, CREATE SEQUENCE, SELECT_CATALOG_ROLE, ALTER USER, ALTER SESSION, CREATE TRIGGER TO INFODBA IDENTIFIED BY infodba;
    PROMPT SETTING DEFAULT TABLESPACES FOR THE INFODBA ACCOUNT;
    ALTER USER INFODBA DEFAULT TABLESPACE IDATA TEMPORARY TABLESPACE TEMP;
    ALTER USER INFODBA QUOTA UNLIMITED ON IDATA QUOTA UNLIMITED ON ILOG QUOTA UNLIMITED ON INDX;
    GRANT WRITE, READ ON DIRECTORY DATA_PUMP_DIR TO INFODBA; 
    exit;
EOF

ret=$?

if [ $ret -eq 0 ]; then
    echo "Custom scripts completed."
    echo "Start importing data pump dump files..."
    
    dpdir=`sqlplus -s infodba/infodba@$ORACLE_PDB << EOF
set heading off;
set pagesize 0;
SELECT DIRECTORY_PATH FROM DBA_DIRECTORIES WHERE DIRECTORY_NAME='DATA_PUMP_DIR';
exit;
EOF`
    
    echo "Data Pump directory is: $dpdir"
    cp $ORACLE_BASE/scripts/setup/$DUMPFILE $dpdir/

    echo "Importing TC12 OOTB schema"
    # assumes IDATA, ILOG, INDX, and SCHEMA INFODBA. no Mapping.
    impdp infodba/infodba@$ORACLE_PDB directory=DATA_PUMP_DIR dumpfile=$DUMPFILE logfile=import.log transform=disable_archive_logging:y

    echo "Tc12 schema imported."

    echo "Update Volume Server."
sqlplus infodba/infodba@$ORACLE_PDB << EOF
    UPDATE PIMANVOLUME SET PNODE_NAME='docker-fmslic'; 
       COMMIT; 
    exit;
EOF
    echo "Volume server updated."
else
    echo "Failed to execute custom scripts."
fi
