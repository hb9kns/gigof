#!/bin/sh
# add git gopher user and set up their directories
if test "$1" = ""
then cat <<EOH
usage: $0 [-f] [-l] <username>

install an account for <username> with a public_gopher
being a git repo with prepared hooks for direct publication
after pushing to the repo; if several <username> are given,
only the last one will be used

STDIN will be read for a public ssh key, and STDOUT will
return a random password for the account if created

option -f will force account generation even if <username>
is already existing, and option -l will permit login through
/bin/sh (otherwise, /bin/nologin will be set)

Evidently, this script must to be run as root or with sudo.
EOH
exit
fi

force=no
login=no
while test "$1" != ""
do case $1 in
 -f) force=yes ;;
 -l) login=yes ;;
 *) usr=$1 ;;
 esac
 shift
done

echo :: usr=$usr force=$force login=$login

if id $usr 2>/dev/null && test $force = no
then cat <<EOI
:: user $usr exists but no '-f' option given,
:: aborting!
EOI
 exit 9
fi
