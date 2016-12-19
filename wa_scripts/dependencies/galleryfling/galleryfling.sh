#
# Script to start a set of apps, switch to recents and fling it back and forth.
# For each iteration, Total frames and janky frames are reported.
#
# Options are described below.
#
# Works for volantis, shamu, and hammerhead. Can be pushed and executed on
# the device.
#
iterations=10
startapps=1
capturesystrace=0

GALLERYAPP="com.android.gallery3d"
GALLERYACTIVITY='com.android.gallery3d/.app.GalleryActivity'
function processLocalOption {
	ret=0
	case "$1" in
	(-N) startapps=0;;
	(-A) unset appList;;
	(-L) appList=$2; shift; ret=1;;
	(-T) capturesystrace=1;;
	(*)
		echo "$0: unrecognized option: $1"
		echo; echo "Usage: $0 [options]"
		echo "-A : use all known applications"
		echo "-L applist : list of applications"
		echo "   default: $appList"
		echo "-N : no app startups, just fling"
		echo "-g : generate activity strings"
		echo "-i iterations"
		echo "-T : capture systrace on each iteration"
		exit 1;;
	esac
	return $ret
}

CMDDIR=$(dirname $0 2>/dev/null)
CMDDIR=${CMDDIR:=.}
. $CMDDIR/defs.sh

case $DEVICE in
(hikey)
	flingtime=100
	rightCount=1
	leftCount=1
	RIGHT="1700 400 1000 400 $flingtime"
	LEFT="300 400 1000 400 $flingtime"
	SELECT="1000 600";;
(juno)
	flingtime=120
	rightCount=1
	leftCount=1
	RIGHT="1000 400 400 400 $flingtime"
	LEFT="400 400 1000 400 $flingtime"
	SELECT="640 300";;
(*)
	echo "Error: No display information available for $DEVICE"
	exit 1;;
esac

if [ $startapps -gt 0 ]; then

	$AM_FORCE_START -n $GALLERYACTIVITY
	sleep 5
	# You'll need to tune this for your device unfortunately...
	input tap $SELECT
	sleep 5
fi

function swipe {
	count=0
	while [ $count -lt $2 ]
	do
		doSwipe $1
		((count=count+1))
	done
}

cur=1
frameSum=0
jankSum=0
latency90Sum=0
latency95Sum=0
latency99Sum=0

resetJankyFrames $GALLERYAPP

while [ $cur -le $iterations ]
do
	if [ $capturesystrace -gt 0 ]; then
		${ADB}atrace --async_start -z -c -b 16000 freq gfx view idle sched
	fi

	sleep 0.5
	swipe "$RIGHT" $rightCount
	sleep 1
	swipe "$LEFT" $leftCount
	sleep 1
	swipe "$RIGHT" $rightCount
	sleep 1
	swipe "$LEFT" $leftCount
	sleep 1
	if [ $capturesystrace -gt 0 ]; then
		${ADB}atrace --async_dump -z -c -b 16000 freq gfx view idle sched > trace.${cur}.out
	fi

	sleep 0.5

	set -- $(getJankyFrames) $GALLERYAPP
	totalDiff=$1
	jankyDiff=$2
	latency90=$3
	latency95=$4
	latency99=$5
	if [ ${totalDiff:=0} -eq 0 ]; then
		echo Error: could not read frame info with \"dumpsys gfxinfo\"
		exit 1
	fi

	((frameSum=frameSum+totalDiff))
	((jankSum=jankSum+jankyDiff))
	((latency90Sum=latency90Sum+latency90))
	((latency95Sum=latency95Sum+latency95))
	((latency99Sum=latency99Sum+latency99))
	if [ "$totalDiff" -eq 0 ]; then
		echo Error: no frames detected. Is the display off?
		exit 1
	fi
	((jankPct=jankyDiff*100/totalDiff))
	resetJankyFrames $GALLERYAPP

	echo Frames: $totalDiff latency: $latency90/$latency95/$latency99 Janks: $jankyDiff\(${jankPct}%\)
	((cur=cur+1))
done
doKeyevent HOME
((aveJankPct=jankSum*100/frameSum))
((aveJanks=jankSum/iterations))
((aveFrames=frameSum/iterations))
((aveLatency90=latency90Sum/iterations))
((aveLatency95=latency95Sum/iterations))
((aveLatency99=latency99Sum/iterations))
echo AVE: Frames: $aveFrames latency: $aveLatency90/$aveLatency95/$aveLatency99 Janks: $aveJanks\(${aveJankPct}%\)
