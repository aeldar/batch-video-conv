#!/bin/sh
#


SOURCEDIR="/tmp/video/source"
WORKDIR="/tmp/video/processing"
RESULTDIR="/tmp/video/result"
FINISHDIR="$SOURCEDIR/finished"
HANDBRAKE="/usr/bin/HandBrakeCLI"
ACTION="$HANDBRAKE -e x264 -q 22 -r 25 -B 64 -X 720 -O"
PIDFILE="/var/run/video-convert.pid"

# Directory check and create
[ -d "$SOURCEDIR" ] || { echo "Cannot reach $SOURCEDIR. Is it exists?" && exit 1; }
[ -d "$WORKDIR" ] || mkdir -p $WORKDIR || { echo "Cannot create work dir $WORKDIR" && exit 1; }
[ -d "$RESULTDIR" ] || mkdir -p $RESULTDIR || { echo "Cannot create result dir $RESULTDIR" && exit 1; }
[ -d "$FINISHDIR" ] || mkdir -p $FINISHDIR || { echo "Cannot create finished dir $FINISHDIR" && exit 1; }

# check if already running
[ -r $PIDFILE ] && exit 1

# create pid file
echo $$ > $PIDFILE

# cleanup before exit
cleanup() {
  rm -f $PIDFILE
}

# interruption handlling
trap 'cleanup; exit 1;' HUP INT TERM

## Do something here
echo "Start processing directory $SOURCEDIR"
for FULLFILENAME in $SOURCEDIR/*
do
  [ -d "$FULLFILENAME" ] && continue
  DATE=`date +%s`
  FILENAME=`basename $FULLFILENAME | tr '.' '_'`
  OUT="${WORKDIR}/${FILENAME}_${DATE}.mp4"
  echo "$ACTION -i $FULLFILENAME -o $OUT"

done

# before exit
cleanup
exit 0

