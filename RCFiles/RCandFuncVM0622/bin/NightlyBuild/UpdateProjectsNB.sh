#!/bin/bash
# Sets path for ccm to work, starts Synergy, and updates proj and deps folders.
# Note: remove the # next to -q to suppress Synergy output(quiet mode)

export PATH=$PATH:/usr/local/ccm_7.1/bin
MSERVER="http://wcssyn02.mapf01.gd-ais.com:8400"
MDB="/db/database/wcsu"
MUSER="nathan.caron"

#password has been saved and encrypted with ccm set_password 
ccm start -s $MSERVER -d $MDB -u $MUSER #-q
ccm update -r -p deps=NightlyBuild
ccm update -r -p proj=NightlyBuild
ccm stop
