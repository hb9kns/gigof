#!/bin/sh
# externally visible git-daemon hostname
hn=dome.circumlunar.space
# common and user repo directories
common=/var/local
urep=r
# see 'git help daemon'
gitexp=git-daemon-export-ok

cat <<EOH
# repositories on $hn

## common repositories

EOH
cd $common
for nn in */.git/$gitexp
do if test -f $nn
 then echo "git://$hn/${nn%/*/*}"
 fi
done

cat <<EOH

## user repositories

EOH
cd /home
for uu in *
do udir=''
 for nn in $uu/$urep/*.git/$gitexp
 do if test -f $nn
  then echo "git://$hn/~${nn%.git/*}" | sed -e "s,/$urep/,/,"
  fi
 done
done

cat <<EOF

---

(`date -u`)
EOF
