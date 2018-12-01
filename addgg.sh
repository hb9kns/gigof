#!/bin/sh
info='addgg.sh/gigof // 18-12-01 // HB9KNS'
# add git-only gopher user and set up their directories

# minimal user id for generated accounts
minid=2001
# minimal user name length
minlen=4
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
iautomatically created by $info	
ion `date -u`.	"

# # do not change anything below

# find git-shell
gitshell=`command -v git-shell`
if test "$gitshell" = ""
then echo :: cannot find git-shell, aborting!
 exit 11
fi

usage() { cat <<EOH >&2
($info)

usage: $0 [-b] [-s|-l <git-shell-dir>] <username>

Install account for <username> with a '$pgd' directory
(git repo with prepared hooks for direct publication after
pushing to the repo), and member of group '$ggroup'.
Bare repo '$ggr' will be installed in the user's home,
which can be pulled/pushed and will update '$pgd'.

<username> must be at least $minlen characters, only lowercase letters
or numbers (but beginning with a lowercase letter),
and will be truncated to 8 characters maximum.
In addition, '$ggroup' is not allowed as <username>.

STDIN will be read for public ssh keys; No password access, only pubkey.
The user's shell will be '$gitshell',
and if <git-shell-dir> is readable, then the contained scripts
will be made available for interactive login:
with '-s' they will be copied, with '-l' a symbolic link will be installed.
NB: <git-shell-dir> should be absolute, for safety reasons!

With '-b', repo '$ggr' will be bare and '$pgd' will be empty,
allowing for pushing an existing external repo.

This script needs the 'useradd' tool to be available,
and evidently must be run as root or through sudo.
EOH
}

# common options for useradd
addopts="--create-home --shell $gitshell --groups $ggroup"

# username empty, symlink flag cleared, prepopulated repo
usr=''
gslink=no
barep=no

while test "$1" != ""
do case $1 in
# option for copied command directory
 -s) gsdir="$2"
    gslink=no
    echo :: git-shell-dir=$gsdir
    shift ;;
# option for symlinked command directory
 -l) gsdir="$2"
    gslink=yes
    echo :: git-shell-dir-link=$gsdir
    shift ;;
# option for bare repo (not populated with gophermap)
 -b) barep=yes
    ;;
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

echo :: reading pubkeys, end with CTRL-D ...

npbk=0
pubkeys=''
while read pbk
do echo :: adding pubkey ...${pbk##* }
 pubkeys="$pubkeys
$pbk"
 npbk=$(( $npbk+1 ))
done
if test $npbk -le 0
then echo :: no pubkey defined, will have to be added manually
fi

# find useradd
usradd=`command -v useradd`
if test "$usradd" = ""
then echo :: cannot find useradd, aborting!
 exit 6
fi

if test -x $usradd
then
 echo :: creating $usr with uid higher than $minid
# specific Linux!
 UID_MIN=$minid $usradd $addopts $usr
 sync
else
 echo :: missing useradd tool, aborting
 exit 5
fi

# save current working directory
oldd=`pwd`
# try to cd to new user homedir
if cd $hdir/$usr
then
 echo :: adding public_gopher dir and initial gophermap
 sudo -u $usr mkdir $pgd
 chmod 755 $pgd
 if test $barep = no
 then
  echo "$igm" | sed -e "s/USRN/$usr/g" > $pgd/gophermap
  chown $usr:$ggroup $pgd/gophermap
  chmod 644 $pgd/gophermap
 fi
 echo :: setting up git config
# generate privacy-protecting user info
 sudo -u $usr git config --global user.name $usr
 sudo -u $usr git config --global user.email $usr@localhost
# set usual push behavior
 sudo -u $usr git config --global push.default simple
 echo :: setting up git repos
 sudo -u $usr git init $pgd
 sudo -u $usr git init --bare $ggr
 chmod 700 $pgd/.git
 chmod 700 $ggr
 echo :: setting up git hook
# hook script in bare repo: pull updated content into working directory
# and make everything world readable
 cat <<EOH >$ggr/$githook
#!/bin/sh
# hook installed by $0
echo post-update:
unset GIT_DIR
cd "$hdir/$usr/$pgd" && git pull origin master && git checkout . && chmod -R a+r *
find . -type f -execdir chmod a-x {} '+'
EOH
# prevent githook from being modified
 chown root:$ggroup $ggr/$githook
 chmod 755 $ggr/$githook
 if test $gslink = yes
 then
  echo :: installing git-shell-commands link to $gsdir
  ln -s "$gsdir" git-shell-commands
 else
  if test -d "$gsdir" -a -r "$gsdir" -a -x "$gsdir"
  then echo :: installing git-shell-commands directory with contents of $gsdir
   mkdir git-shell-commands
# prevent scripts from being modified
   chown root:$ggroup git-shell-commands
   chmod 3755 git-shell-commands
   /bin/cp "$gsdir"/* git-shell-commands/
   chmod 755 git-shell-commands/*
  else echo :: no readable git-shell-commands template found
  fi
 fi
 echo :: initializing working gopher directory
 cd $pgd
# link working to bare repo
 sudo -u $usr git remote add origin ~$usr/$ggr
 if test $barep = no
 then
  sudo -u $usr git add gophermap
  sudo -u $usr git commit -m "initial by $info"
  sudo -u $usr git push -u origin master
 fi
 cd -
 echo :: adding .ssh/authorized_keys
 sudo -u $usr mkdir .ssh
 cd .ssh
 echo "$pubkeys" >> authorized_keys
 chown $usr:$ggroup authorized_keys
 chmod 700 .
 chmod 644 authorized_keys
 cd "$oldd"
else cat <<EOI
:: could not cd to homedir of $usr
::  aborting!
EOI
 exit 3
fi
