#!/bin/sh
#
# File:  env.sh
# Date:  11-May-2016  Jdw
#
# Update:
#      13-May-2016  jdw  simplified for Bourne shell
#      28-Jul-2016  jdw  add usage details -
#       5-Dec-2016  jdw  add validation and database options
#
PYTHON="python3"

MYDIR="$( builtin cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#
if [ -z $TOP_WWPDB_SITE_CONFIG_DIR ]
then
    TOP_WWPDB_SITE_CONFIG_DIR="$MYDIR/../"
fi
OK=0
DEBUG=""
MYHOSTNAME=""
SITE_ID=""
SITE_LOC=""
OPT_ENV="--shell"
NO_CACHE=""
THIS_SCRIPT="${BASH_SOURCE[0]}"
USAGE="Usage: ${THIS_SCRIPT} -h|--host <host> -s|--siteid <siteId> -l|--location <siteLoc> --shell --httpd --install --validation --database --nocache"
#
while [[ $# > 0 ]]
do
    key="$1"
    case $key in
        -h|--host)
        MYHOSTNAME="$2"
        shift # past argument
        ;;
        -s|--siteid)
        SITE_ID="$2"
        shift # past argument
        ;;
        -l|--location|--locid)
        SITE_LOC="$2"
        shift # past argument
        ;;
        --httpd)
        OPT_ENV="--httpd"
        ;;
        --validation)
        OPT_ENV="--validation"
        ;;
        --database)
        OPT_ENV="--database"
        ;;
        --install)
        OPT_ENV="--install"
        ;;
        --shell)
        OPT_ENV="--shell"
        ;;
        --nocache)
        NO_CACHE="--nocache"
        ;;
        -d|--debug)
        DEBUG="YES"
        ;;
       --help)
            echo ${USAGE}
            OK=1
        ;;

        *)
            # unknown option
            #echo ${USAGE}
            OK=1
        ;;
    esac
    shift # past argument or value
done
#
if [ -n "${DEBUG}" ]
then
    echo HOSTNAME  = "${MYHOSTNAME}"
    echo SITE_ID   = "${SITE_ID}"
    echo SITE_LOC  = "${SITE_LOC}"
    echo OPT_ENV   = "${OPT_ENV}"
    echo DEBUG     = "${DEBUG}"
    echo MYDIR     = "${MYDIR}"
    echo NO_CACHE  = "${NO_CACHE}"
fi
#
if [ -n "$MYHOSTNAME" ]
then
    IFS='
'
    for line in `${PYTHON} -E ${MYDIR}/ConfigInfoShellExec.py --configpath=${TOP_WWPDB_SITE_CONFIG_DIR} --host=${MYHOSTNAME} ${OPT_ENV} ${NO_CACHE}`
    do
      if [ -n "${DEBUG}" ]
      then
            echo $line
      else
          eval $line
      fi
    done

elif [[ -n "${SITE_ID}" ]] && [[ -n "${SITE_LOC}" ]]
then
    IFS='
'
    COMMAND="${PYTHON} -E ${MYDIR}/ConfigInfoShellExec.py -v --configpath=${TOP_WWPDB_SITE_CONFIG_DIR} --locid=${SITE_LOC} --siteid=${SITE_ID} ${OPT_ENV} ${NO_CACHE}"
    echo $COMMAND
    for line in `${PYTHON} -E ${MYDIR}/ConfigInfoShellExec.py -v --configpath=${TOP_WWPDB_SITE_CONFIG_DIR} --locid=${SITE_LOC} --siteid=${SITE_ID} ${OPT_ENV} ${NO_CACHE}`
    do
        if [ -n "${DEBUG}" ]
        then
            echo $line
        else
            eval $line
        fi
    done
else
    echo ${USAGE}
    OK=1
fi
if [ $OK == 0 ]
then
    echo "+env.sh - Site id $WWPDB_SITE_ID tools path: $TOOLS_DIR"
    umask 022
fi
#

