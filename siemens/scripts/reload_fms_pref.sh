#!/bin/bash

#source tcProfile.sh
source tcprofile

preferences_manager -u=infodba -p=infodba -g=dba -mode=import -scope=SITE -file=./prefs.xml -action=OVERRIDE

