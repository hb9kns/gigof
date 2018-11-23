#!/bin/sh
# install signup account

# account name
newuser=new
# login shell path
lish=/var/local/gigof/signup.sh
# options for useradd
# shell must be absolute path into installation directory of gigof
addopts="--shell $lish --create-home --gid nogroup --system"

if test `id -u` -gt 0
then cat <<EOT

::: must be root or run with sudo, aborting! :::

This script sets up a system account '$newuser'
with login shell '$lish'
for accepting new user requests.

EOT
 exit 9
fi
if id $newuser >/dev/null 2>&1
then echo "$newuser already exists, aborting!"
 exit 8
fi

# find useradd
usradd=`command -v useradd`
if test "$usradd" = ""
then echo :: cannot find useradd, aborting!
 exit 6
fi

if test -x $usradd
then
 echo ":: creating system user '$newuser'"
# specific Linux!
 $usradd $addopts $newuser
 sync
else
 echo :: missing useradd tool, aborting
 exit 5
fi

cat <<EOT
$newuser is installed: `id $newuser`
please set password according to your system requirements!
done.
EOT
