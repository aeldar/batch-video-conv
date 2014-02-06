#!/bin/sh
#

# Params
# TODO Convert to aommand line params
SOURCEDIR="/tmp/video/source"
WORKDIR="/tmp/video/processing"
RESULTDIR="/tmp/video/result"
FINISHDIR="$SOURCEDIR/finished"
HANDBRAKE="/usr/bin/HandBrakeCLI"
ACTION="$HANDBRAKE -e x264 -q 22 -r 25 -B 64 -X 720 -O"
PIDFILE="/var/run/video-convert.pid"

# Directory check and create
# TODO Check if they writable
[ -d "$SOURCEDIR" ] || { echo "Cannot reach $SOURCEDIR. Is it exists?" && exit 1; }
[ -d "$WORKDIR" ] || mkdir -p $WORKDIR || { echo "Cannot create work dir $WORKDIR" && exit 1; }
[ -d "$RESULTDIR" ] || mkdir -p $RESULTDIR || { echo "Cannot create result dir $RESULTDIR" && exit 1; }
[ -d "$FINISHDIR" ] || mkdir -p $FINISHDIR || { echo "Cannot create finished dir $FINISHDIR" && exit 1; }

# check if already running
[ -r $PIDFILE ] && exit 1

# create pid file
echo $$ > $PIDFILE
[ "$?" -eq 0 ] || { echo "Cannot create pidfile. Exit!" && exit 1; }

# cleanup before exit
cleanup() {
  rm -f $PIDFILE
}

# interruption handlling
trap 'cleanup; exit 1;' HUP INT TERM

## Do something here
echo "Starting to process directory $SOURCEDIR..."
for FULLFILENAME in $SOURCEDIR/*
do
  [ -d "$FULLFILENAME" ] && continue
  [ -w "$FULLFILENAME" ] || { echo "Cannot move $FULLFILENAME. Ignoring it (no convert) and continue." && continue; }
  DATE=`date +%s`
  FILENAME=`basename $FULLFILENAME | tr '.' '_'`
  OUT="${WORKDIR}/${FILENAME}_${DATE}.mp4"
  echo "Trying to convert `basename $FULLFILENAME` to `basename $OUT`"
  $ACTION -i $FULLFILENAME -o $OUT > /dev/null 2>&1
  if [ "$?" -eq 0 ]
    then
      mv $FULLFILENAME $FINISHDIR
      if [ -f $OUT ]
        then
          mv $OUT $RESULTDIR
          echo "Successfully converted `basename $FULLFILENAME` to $RESULTDIR/`basename $OUT`"
        else
          echo "Cannot find the result of converting `basename $FULLFILENAME`. Probably, it was not a video file. Ignoring it and continue anyway."
      fi
    else
      echo "Failed. Something went wrong with HandBrake. Shit. But I am going to continue with the rest of files anyway."
  fi
done

# before exit
cleanup
exit 0

