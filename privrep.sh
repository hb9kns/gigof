#!/bin/sh
permf=allow-private-repos
urep=r
gitexp=git-daemon-export-ok

if test "$1" = ""
then cat <<EOH
usage: $0 <user>
 will install a file '$permf'
 in user's repo directory '$urep'
 activating the option in the git-shell "repos" script
 permitting to remove '$gitexp' in repos

 Note: must be run as root or through sudo!
EOH
 exit 1
fi

if id -u $1 >/dev/null
then
 echo :: creating $permf in home dir of $1
 date -u > /home/$1/$permf
else
 echo :: aborting
 exit 2
fi
