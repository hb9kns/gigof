#!/bin/sh
opts=--verbose
common=/var/local
usrp=r
exec git daemon $opts --base-path=$common --user-path=$usrp
