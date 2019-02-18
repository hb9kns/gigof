#!/bin/sh
# a simple gitdaemon wrapper adapted to standard gigof configuration
opts=--verbose
basp=/var/local
usrp=r
exec git daemon $opts --base-path=$basp --user-path=$usrp
