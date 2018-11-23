#!/bin/sh
adir=/var/local/accounts

sleep 1

# sanitize input
sid=`echo "$QUERY_STRING"|tr -c -d 0-9`
# dummy, if no input
sid=${sid:-NIL}
# get info from submission file
ssub=`grep "=$sid=" $adir/submissions.txt 2>/dev/null | sed -e 's/=[^=]*= //'`
# get info from manual process file
sman=`grep "=$sid=" $adir/processed.txt | sed -e 's/=[^=]*= //'`
# manual status overrides submission status
stat=${sman:-$ssub}
stat=${stat:-no information listed}

cat <<EOT
 SID=$sid
STAT=$stat
DATE=`date -u`
EOT
