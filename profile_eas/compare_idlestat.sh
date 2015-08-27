#!/bin/bash

BASELN=/home/leoy/Work/tools/tunning/easv5/round2/result_mainline_0826
EASDIS=/home/leoy/Work/tools/tunning/easv5/round2/result_eas_dis_0826
EASNDM=/home/leoy/Work/tools/tunning/easv5/round2/result_eas_ndm_0826
EASHED=/home/leoy/Work/tools/tunning/easv5/round2/result_eas_sched_0826
RESULT=/home/leoy/Work/tools/tunning/easv5/round2/parse

compare_trace_file()
{
	if [ -z $1 ]; then
		echo "Please input module name"
		exit 1
	fi

	echo "== ORIGINAL"      > $RESULT/$1/idlestat_compare.txt
	echo ""                >> $RESULT/$1/idlestat_compare.txt

	./idlestat --import -f $BASELN/$1/trace.log -b $BASELN/$1/trace.log -r comparison >> $RESULT/$1/idlestat_compare.txt

	echo "== EAS DIS"      >> $RESULT/$1/idlestat_compare.txt
	echo ""                >> $RESULT/$1/idlestat_compare.txt

	./idlestat --import -f $EASDIS/$1/trace.log -b $BASELN/$1/trace.log -r comparison >> $RESULT/$1/idlestat_compare.txt

	echo "== EAS NDM"      >> $RESULT/$1/idlestat_compare.txt
	echo ""                >> $RESULT/$1/idlestat_compare.txt

	./idlestat --import -f $EASNDM/$1/trace.log -b $BASELN/$1/trace.log -r comparison >> $RESULT/$1/idlestat_compare.txt

	echo "== EAS SCHED"    >> $RESULT/$1/idlestat_compare.txt
	echo ""                >> $RESULT/$1/idlestat_compare.txt

	./idlestat --import -f $EASHED/$1/trace.log -b $BASELN/$1/trace.log -r comparison >> $RESULT/$1/idlestat_compare.txt
}

calculate_idle_diff()
{
	./calc_idle_diff.py --ifile=$RESULT/$1/idlestat_compare.txt --ofile=$RESULT/$1/idlestat_diff.txt
}

compare_trace_file mp3
compare_trace_file rt-app-6
compare_trace_file rt-app-13
compare_trace_file rt-app-19
compare_trace_file rt-app-25
compare_trace_file rt-app-31
compare_trace_file rt-app-38
compare_trace_file rt-app-44
compare_trace_file rt-app-50

calculate_idle_diff mp3
calculate_idle_diff rt-app-6
calculate_idle_diff rt-app-13
calculate_idle_diff rt-app-19
calculate_idle_diff rt-app-25
calculate_idle_diff rt-app-31
calculate_idle_diff rt-app-38
calculate_idle_diff rt-app-44
calculate_idle_diff rt-app-50
