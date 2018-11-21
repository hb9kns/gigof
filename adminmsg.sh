#!/bin/sh
info='adminmsg.sh/gigof // 18-11-21 // HB9KNS'
inbox=inbox
outbox=outbox
outflag="$outbox.flag"
homes=/home
tmpf=$HOME/.admmsg.tmp
pager=${PAGER:-more}
editor=${EDITOR:-ed}

echo $info

if test `id -u` -gt 0
then cat <<EOH

- communicate with users through ~/$inbox and ~/$outbox
- must be run as root / with sudo !

EOH
exit 1
fi

# search homes for outbox flags
scanh() {
 local i
 i=1
 for hd in $homes/*
 do if test -f $hd/$outflag
 then echo "+ $i $hd"
 else echo "- $i $hd"
 fi
 i=$(( $i+1 ))
 done
}

# list homes, return selected dir if arg=dir
selecth() {
 local msg
 echo "#	msg	user" >&2
 scanh >$tmpf
 cat $tmpf | { while read flg ind usr
 do
  if test "$flg" = "+"
  then msg=yes
  else msg=no
  fi
  echo "$ind	$msg	${usr##*/}" >&2
 done
 }
 if test "$1" = "dir"
 then
  echo ' selection?' >&2
  read ind
  grep " $ind " $tmpf | sed -e 's/.* .* //'
 fi
}

cmd=''
while test "$cmd" != "q"
do
 ud=`selecth dir`
 if test "$ud" != ""
 then
  cat $ud/$outbox | sed -e 's/^/> /' >$tmpf
  echo :: userdir=$ud
  $pager $tmpf
  echo :: userdir=$ud
  echo '(w)rite/(r)ead/(clear) user inbox?'
  read cmd
  case $cmd in
  w*) echo 'calling $editor'
   $editor $tmpf
   $pager $tmpf
   echo 'ok to write to user'
   read cmd
   if test "$cmd" = "ok"
   then cat <<EOT >>$ud/$inbox

----------------------------------------------
From: $USER
Date: `date`

EOT
    cat $tmpf >>$ud/$inbox
    rm -f $ud/$outflag
    echo 'written and outbox flag reset'
   else echo "aborting -- still saved in $tmpf"
   fi
   ;;
  i*) $pager $ud/$inbox
   ;;
  clear) date -u '+cleared on %c' >$ud/$inbox
   ;;
  esac
  echo '(q)uit?'
  read cmd
 else cmd=q
 fi
done
