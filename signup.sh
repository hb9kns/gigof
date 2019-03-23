#!/bin/sh
# anonymous signup script, may be run as login shell

# must correspond to newuser's gopher root seen from outside:
statusprefix=gopher://dome.circumlunar.space:70/0/~$USER
# must correspond to contents of accdir in instsign.sh script:
subdir=accounts
statusprefix=$statusprefix/$subdir

gophdir=$HOME/public_gopher
mkdir -p $gophdir
chmod a+rx $gophdir
gophdir=$gophdir/$subdir
mkdir -p $gophdir
chmod a+rx $gophdir

# timeout/seconds
grace=333
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
# arg.1=errcode
finish() {
 echo
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
 echo $tid | sed -e 's/$/ 9851927347%74201683+p/'|dc
}

trap finish HUP INT TERM QUIT ABRT
trap timeout ALRM

# start watchdog on current PID
watchdog $$ &
wpid=$!

echo BUILDING LINK...
sleep 1
echo CARRIER DETECTED
echo CONNECTION ENDPOINTS: $SSH_CONNECTION

subid=`genid`

cat <<EOH

SID=$subid=

Welcome to the application process for new accounts!
You have $grace seconds to finish, then the process will abort.
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
  *) pubkey="$pubkey;;;$pubpart" ;;
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
then cat <<EOT > $gophdir/$subid.txt
# `date -u`
 SSH_CLIENT=$SSH_CLIENT=
 =$subid= :NEW: SUBMISSION LOGGED `date -u`
 <$newname>
 $pubkey

EOT
 chmod a+r $gophdir/$subid.txt
 cat <<EOT
Thank you for your submission! It will be reviewed as soon as possible.
See the following document for status report about your submission:
  $statusprefix/$subid.txt
(NB: save this for further reference!)

EOT
else echo submission process aborted
fi

# block directory listing by (re)setting explicit gophermap
cat <<EOI >$gophdir/gophermap
!Account submission status
iSubmission status can be requested by getting the file from	
ithis directory with name identical to the submission id	
iand the extension '.txt' e.g	
i $statusprefix/12345678.txt	
iwhere 12345678 must be replaced by the id given	
iduring the submission process.	
.
EOI
chmod a+r $gophdir/gophermap

finish
