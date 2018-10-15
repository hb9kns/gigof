#!/bin/sh
# add git gopher user and set up their directories
if test "$1" = ""
then cat <<EOH
usage: $0
EOH
exit
fi
