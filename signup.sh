#!/bin/sh
# anonymous signup script, may be run as login shell

# submissions log
submit=$HOME/submissions.txt
lockf=$submit.lock
# where submission status will be reported
substat='gopher://dome.circumlunar.space/1/submissions/'
# timeout/seconds
grace=300
mdgrace=$(( 10*$grace/864 ))
# minimal length of new user name
minlen=4
# illegal/reserved names (in addition to those in /etc/passwd and /etc/group)
illnam=${ILLEGNAMES:-/dev/null}
if ! test -r "$illnam"
then illnam=/dev/null
fi

# cleanup after timeout
timeout() {
 echo >&2
 echo "grace period reached, aborting!" >&2
 finish 2
}

# cleanup and end
finish() {
 rm -f $lockf
 sleep 1
 echo releasing workspace >&2
 sleep 1
 echo .....NO CARRIER >&2
 kill $wpid
 exit ${1:-0}
}

# background watchdog
watchdog() {
# echo starting grace time of $grace seconds... >&2
 sleep $grace
 kill -s ALRM $1
 sleep 1
}

# generate random ID
genid(){
 local tid
 if env uuidgen >/dev/null 2>&1
 then tid=`uuidgen | tr -c -d 0-9`
 else tid="`date +%s`$$"
 fi
 echo $tid | sed -e 's/$/ 925737%74263+p/'|dc
}

trap finish HUP INT TERM QUIT ABRT
trap timeout ALRM

# start watchdog on current PID
watchdog $$ &
wpid=$!

echo BUILDING LINK...
sleep 1
echo CARRIER DETECTED. SYNCHRONIZING LOCAL OSCILLATOR...
sleep 1

subid=`genid`

cat <<EOH

SID $subid
Welcome to the application process for new accounts!
You have $mdgrace millidays to finish,
then the process will abort.
You can abort at any time with ^C (CTRL-C).

Please enter your desired username!
($minlen to 8 characters, only letters and numbers,
first character must be a letter,
checked for collision with existing ones,
but final decision will be made during backend processing)
EOH

newname=''
while test "$newname" = ""
do
 echo
 printf "new user name? "
 read newname
 newname=`echo "$newname" | tr A-Z a-z | tr -c -d '0-9a-z'`
 newname=`echo "$newname" | sed -e 's/^[0-9]*//;s/\(........\).*/\1/'`
 echo "your input is sanitized as follows: $newname"
 if test ${#newname} -lt $minlen
 then echo 'too short, illegal!'
  newname=''
 else if grep "^$newname[:-]" /etc/passwd /etc/group "$illnam" >/dev/null 2>&1
  then echo 'reserved name, illegal!'
  newname=''
  fi
 fi
done

cat <<EOT

Please enter one or several ssh public key strings (NOT private key)
which will allow you to login with the username $newname.

You may enter them on several lines.  They will be read by a human,
therefore you can be quite generous with the formatting. However, they
have to be valid pubkeys, otherwise the account will be created but
login will simply be impossible.
You may also add comments for the account request procedure.
Entry will abort if more than about 9 kB of text is received.

End your entry with a single '.' (dot) on a line.
You can start over by entering 'X' (capital X) on a line.

EOT

pubkey=''
pubpart=''
while test "$pubpart" != "." -a ${#pubkey} -lt 9999
do read pubpart
 case $pubpart in
  X) pubkey=''
   echo "starting over with empty buffer"
   ;;
  .) echo "finished" ;;
  *) pubkey="$pubkey$pubpart" ;;
 esac
done

cat <<EOT
 user name: '$newname'
 pubkey data:
$pubkey

 Please confirm correctness of submitted information with "ok"
 (without quotes)!
EOT

read pubpart
if test "$pubpart" = "ok" -o "$pubpart" = "OK"
then cat <<EOT >> $submit

# `date -u`
 SSH_CLIENT=$SSH_CLIENT=
 newname=$newname=
 subid=$subid=
 pubkey=$pubkey

-----
EOT
 cat <<EOT
Thank you for your submission! It will be reviewed as soon as possible.
Status report of submission can be requested at
 $substat
with submission ID $subid -- please save for future reference!

EOT
else echo submission process aborted
fi

finish
