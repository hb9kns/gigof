#!/bin/sh
# add git gopher user and set up their directories

# minimal user id for generated accounts
minid=2000
# group the user will be part of
ggroup=gigofs
# adduser arguments prohibiting login
addunologin="--firstuid $minid --ingroup $ggroup --disabled-login"
# adduser arguments permitting login
adduwidlogin="--firstuid $minid --ingroup $ggroup"

usage() { cat <<EOH
usage: $0 [-f] [-l] <username>

Install an account for <username> with a public_gopher directory
(which is a git repo with prepared hooks for direct publication
after pushing to the repo), and group $ggroup.
If several usernames are given, only the last one will be used.
username must be at least 4 characters, only lowercase letters,
and will be truncated to 8 characters maximum.

STDIN will be read for public ssh keys.

Option -f will force account generation even if <username>
is already existing (iff the user ID is higher than $minid),
and option -l will permit ssh login through /bin/sh but not
with password authentication (only ssh pubkey).

(Evidently, this script must be run as root or through sudo.)
EOH
}

forceadd=no
allowlogin=no
usr=''
while test "$1" != ""
do case $1 in
 -f) forceadd=yes ;;
 -l) allowlogin=yes ;;
 *) usr=$1 ;;
 esac
 shift
done

# remove all but a-z, and all after 8 initial characters
usr=`echo $usr | tr -c -d 'a-z' | sed -e s'/\(........\).*/\1/'`
if test "${#usr}" -lt 4
then usage
 exit 9
fi

echo :: forceadd=$forceadd allowlogin=$allowlogin usr=$usr

# check for existing user or -f option
if id $usr 2>/dev/null
then uid=`id -u $usr 2>/dev/null`
 if test $forceadd = no
 then cat <<EOI
:: user $usr($uid) exists but no '-f' option given,
:: aborting!
EOI
  exit 7
 else cat <<EOI
:: user $usr($uid) exists and '-f' option given,
:: but not yet implemented, therefore aborting anyway!
EOI
 fi
fi

echo :: reading pubkeys ...

npbk=0
pubkeys=''
while read pbk
do echo :: adding pubkey ...${pbk##* }
 pubkeys="$pbk
"
 npbk=$(( $npbk+1 ))
done
if test $npbk -le 0
then echo :: no pubkey defined, will have to be added manually
fi

if test $allowlogin = yes
then adduser $adduwidlogin $usr
else adduser $addunologin $usr
fi

if cd ~$usr
then echo :: adding .ssh/authorized_keys
 mkdir .ssh
 cd .ssh
 echo "$pubkeys" >> authorized_keys
 chown $usr.$ggroup . authorized_keys
 chmod 700 .
 chmod 640 .
 cd - >/dev/null
else cat <<EOI
:: could not cd to homedir of $usr
::  aborting!
EOI
 exit 5
fi

