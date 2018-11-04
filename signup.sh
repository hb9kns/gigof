#!/bin/sh
# anonymous signup script, may be run as login shell

# submissions log
submit=$HOME/submissions.txt
lockf=$submit.lock

# timeout/seconds
grace=300
# minimal length of new user name
minlen=4

# cleanup after timeout
timeout() {
 echo >&2
 echo "grace period reached, aborting!" >&2
 finish 2
}

# cleanup and end
finish() {
 /bin/rm -f $lockf
 echo >&2
 echo "finished -- good bye!" >&2
 kill $wpid
 exit ${1:-0}
}

# background watchdog
watchdog() {
 echo starting grace time of $grace seconds... >&2
 sleep $grace
 kill -s ALRM $1
 sleep 1
}

trap finish HUP INT TERM QUIT ABRT
trap timeout ALRM

# start watchdog on current PID
watchdog $$ &
wpid=$!

cat <<EOH

Welcome to the application process for new accounts!
You have $grace seconds to finish this;
after that time, the process will abort.

Please enter your desired username!
($minlen to 8 characters, only letters and numbers,
first character must be a letter)
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
 then echo "too short, illegal!"
  newname=''
 fi
done

cat <<EOT

Please enter an ssh public key string (NOT private key)
which will allow you to login with the username $newname.

You may enter it on several lines, which will be concatenated.
End your entry with a single '.' (dot) on a line.
You can start over by entering 'X' (capital X) on a line.

EOT

pubkey=''
pubpart=''
while test "$pubpart" != "."
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
your entered key:
---
$pubkey
---

Thank you for your submission!
Please wait at least 1 day before attempting to log in.
EOT

cat <<EOT >> $submit

# `date -u`
 newname=$newname
 pubkey=$pubkey

-----
EOT

kill $wpid
