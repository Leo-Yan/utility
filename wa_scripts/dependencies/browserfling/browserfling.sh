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

BROWSER="icecat"

#BROWSERAPP="org.gnu.icecat"
#BROWSERACTIVITY='org.gnu.icecat/org.mozilla.gecko.BrowserApp'

BROWSERAPP="com.android.browser"
BROWSERACTIVITY='com.android.browser/.BrowserActivity'
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
	downCount=1
	upCount=1
	UP="1000 400 1000 800 $flingtime"
	DOWN="1000 800 1000 400 $flingtime";;
(shamu|hammerhead)
	flingtime=300
	downCount=2
	upCount=6
	UP="70 400 70 100 $flingtime"
	DOWN="70 100 70 400 $flingtime";;
(bullhead)
	flingtime=200
	downCount=5
	upCount=5
	UP="500 1200 500 550 $flingtime"
	DOWN="500 550 500 1200 $flingtime";;
(volantis)
	flingtime=400
	downCount=5
	upCount=6
	UP="70 400 70 70 $flingtime"
	DOWN="70 70 70 400 $flingtime";;
(juno)
	flingtime=150
	downCount=4
	upCount=4
	UP="270 600 270 200 $flingtime"
	DOWN="270 200 270 600 $flingtime";;
(*)
	echo "Error: No display information available for $DEVICE"
	exit 1;;
esac

if [ $startapps -gt 0 ]; then

	echo Starting $BROWSER ...
	$AM_FORCE_START -n $BROWSERACTIVITY "file:////data/wa-working/browserfling/testpage/testpage.html"
	sleep 40
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

echo "Fling page..."
echo $BROWSERAPP
resetJankyFrames $BROWSERAPP

while [ $cur -le $iterations ]
do
	if [ $capturesystrace -gt 0 ]; then
		${ADB}atrace --async_start -z -c -b 16000 freq gfx view idle sched
	fi

	sleep 0.5
	swipe "$UP" $upCount
	sleep 1
	swipe "$DOWN" $downCount
	sleep 1
	swipe "$UP" $upCount
	sleep 1
	swipe "$DOWN" $downCount
	sleep 1
	if [ $capturesystrace -gt 0 ]; then
		${ADB}atrace --async_dump -z -c -b 16000 freq gfx view idle sched > trace.${cur}.out
	fi

	sleep 0.5

	set -- $(getJankyFrames) $BROWSERAPP
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
	resetJankyFrames $BROWSERAPP

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
