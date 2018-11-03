#!/bin/sh
# anonymous signup script, may be run as login shell
submit=$HOME/submissions.txt
lockf=$submit.lock
grace=15

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
(4 to 8 characters, only letters and numbers,
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
 if test ${#newname} -lt 4
 then echo "too short, illegal!"
  newname=''
 fi
done

kill $wpid
