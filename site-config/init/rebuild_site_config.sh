#!/bin/sh

if [ -z "${WWPDB_SITE_LOC}" -o -z "${WWPDB_SITE_ID}" ]
then 
  echo "$0 - No runtime configuration, need to set WWPDB_SITE_ID and WWPDB_SITE_LOC - exit"
  echo "WWPDB_SITE_LOC: ${WWPDB_SITE_LOC}"
  echo "WWPDB_SITE_ID: ${WWPDB_SITE_ID}"
  exit 1
fi

set -e
MYDIR="$( builtin cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd ${MYDIR}
unset SSH_ASKPASS
git pull

python3 -m wwpdb.utils.config.ConfigInfoFileExec --writecache --locid=$WWPDB_SITE_LOC --siteid=$WWPDB_SITE_ID
