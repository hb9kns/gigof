#!/bin/sh
adir=/var/local/accounts
ssub=$adir/submissions.txt
sman=$adir/processed.txt

if test "$1" = ""
then cat <<EOT
usage: $0 <sid> <status>
 set <status> (free text) for submission ID <sid> in
 manual status file $sman

 Note: <status> should not contain strings of pattern =[0-9]*=
 as they are used for submission IDs
EOT
 exit 1
fi

sid=$1
shift
stat=`date -u '+(%c UTC)'`
stat=`echo "$* $stat" | tr a-z A-Z`

if grep "=$sid=" $ssub
then echo :: SID =$sid= old status:
 grep "=$sid=" $sman
 cat <<EOT
:: setting SID =$sid= to
:: status '$stat'
EOT
 nonsid=`grep -v "=$sid=" $sman`
 echo "$nonsid" >$sman
 echo "=$sid= $stat" >>$sman
else echo :: no submission found for SID =$sid=
fi
