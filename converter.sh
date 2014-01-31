#!/bin/sh
#


SOURCEDIR=""
WORKDIR=""
RESULTDIR=""
PIDFILE="/var/run/video-convert.pid"

# check if already running
[ -r $PIDFILE ] && exit 1

echo $$ > $PIDFILE

cleanup() {
  rm -f $PIDFILE
}

trap 'cleanup; exit 1;' HUP INT TERM

echo "START"
sleep 10
echo "END"

## Do something here

cleanup
