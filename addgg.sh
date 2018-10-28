#!/bin/sh
# add git gopher user and set up their directories

# minimal user id for generated accounts
minid=2001
# minimal user name length
minlen=3
# additional group the user will be part of
ggroup=gigofs
# public gopher directory name
pgd=public_gopher
# bare git repo for gopher directory
ggr=gopher.git
# githook for automatic gopher updating
githook=hooks/post-update
# domain for git email address
gitdomain=localhost
# homes
hdir=/home
# initial gophermap, USRN will be replaced by user name
igm="iUSRN's gophermap	
iThis gophermap was created by $0	
ion `date -u`.	"

# # do not change anything below

usage() { cat <<EOH >&2
usage: $0 <username>

Install an account for <username> with a $pgd directory
(which is a git repo with prepared hooks for direct publication
after pushing to the repo), and member of group $ggroup.
If several usernames are given, only the last one will be used.
username must be at least $minlen characters, only lowercase letters
or numbers (but beginning with a lowercase letter),
and will be truncated to 8 characters maximum.
In addition, $ggroup is not allowed as <username>.

STDIN will be read for public ssh keys.
No password access will be possible, only pubkey.
This script needs the 'useradd' tool to be available.

Evidently, this script must be run as root or through sudo.
EOH
}

# common options for useradd
addopts="--create-home --shell /bin/sh --groups $ggroup"

usr=''
while test "$1" != ""
do case $1 in
 -*) echo :: ignoring option $1 ;;
 *) usr=$1 ;;
 esac
 shift
done

# remove all but 0-9a-z, leading numbers, and all after 8 initial characters
usr=`echo $usr | tr -c -d '0-9a-z' | sed -e s'/[0-9]*\(........\).*/\1/'`
if test ${#usr} -lt $minlen -o "$usr" = "$ggroup"
then usage
 exit 9
fi

echo :: usr=$usr

# check for existing user
if id $usr >/dev/null 2>&1
then uid=`id -u $usr 2>/dev/null`
 echo :: user $usr exists, aborting!
 exit 7
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

if test -x useradd
then
 echo :: creating $usr with uid higher than $minid
 UID_MIN=$minid useradd $addopts $usr
 sync
else
 echo :: missing useradd tool, aborting
 exit 5
fi

oldd=`pwd`
if cd $hdir/$usr
then
 echo :: adding public_gopher dir and initial gophermap
 sudo -u $usr mkdir $pgd
 echo "$igm" | sed -e "s/USRN/$usr/g" > $pgd/gophermap
 chmod 755 $pgd
 chown $usr:$ggroup $pgd/gophermap
 chmod 644 $pgd/gophermap
 echo :: setting up git repos
 sudo -u $usr git config --global user.name $usr
 sudo -u $usr git config --global user.email $usr@localhost
 sudo -u $usr git config --global push.default simple
 sudo -u $usr git init $pgd
 sudo -u $usr git init --bare $ggr
 echo :: setting up git hook
 cat <<EOH >$ggr/$githook
#!/bin/sh
# hook installed by $0
echo post-update:
unset GIT_DIR
cd "$hdir/$usr/$pgd" && git pull && git checkout . && chmod a+r *
EOH
 chown $usr:$ggroup $ggr/$githook
 chmod 755 $ggr/$githook
 cd $pgd
 sudo -u $usr git remote add origin ~$usr/$ggr
 sudo -u $usr git add gophermap
 sudo -u $usr git commit -m initial
 sudo -u $usr git push -u origin master
 cd -
 echo :: adding .ssh/authorized_keys
 sudo -u $usr mkdir .ssh
 cd .ssh
 echo "$pubkeys" >> authorized_keys
 chown $usr:$ggroup authorized_keys
 chmod 700 .
 chmod 640 authorized_keys
 cd "$oldd"
else cat <<EOI
:: could not cd to homedir of $usr
::  aborting!
EOI
 exit 3
fi
