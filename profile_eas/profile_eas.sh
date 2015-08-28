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

calculate_sched_perf()
{
	if [ -e $RESULT/$1/sched_perf.txt ]; then
		rm $RESULT/$1/sched_perf.txt
	fi

	echo "== ORIGINAL"      > $RESULT/$1/sched_perf.txt
	echo ""                >> $RESULT/$1/sched_perf.txt

	./calc_sched_preformance.py --threads=8 --logprefix=$BASELN/$1/$1-thread0- -o $RESULT/$1/sched_perf.txt

	echo ""                >> $RESULT/$1/sched_perf.txt
	echo "== EAS DIS"      >> $RESULT/$1/sched_perf.txt
	echo ""                >> $RESULT/$1/sched_perf.txt

	./calc_sched_preformance.py --threads=8 --logprefix=$EASDIS/$1/$1-thread0- -o $RESULT/$1/sched_perf.txt

	echo ""                >> $RESULT/$1/sched_perf.txt
	echo "== EAS NDM"      >> $RESULT/$1/sched_perf.txt
	echo ""                >> $RESULT/$1/sched_perf.txt

	./calc_sched_preformance.py --threads=8 --logprefix=$EASNDM/$1/$1-thread0- -o $RESULT/$1/sched_perf.txt

	echo ""                >> $RESULT/$1/sched_perf.txt
	echo "== EAS SCHED"    >> $RESULT/$1/sched_perf.txt
	echo ""                >> $RESULT/$1/sched_perf.txt

	./calc_sched_preformance.py --threads=8 --logprefix=$EASHED/$1/$1-thread0- -o $RESULT/$1/sched_perf.txt
}

calculate_pstate_time()
{
	if [ -e $RESULT/$1/pstate_time.txt ]; then
		rm $RESULT/$1/pstate_time.txt
	fi

	./calc_pstate_time.py --ifile1=$BASELN/$1/report.log --ifile2=$EASDIS/$1/report.log \
			      --ifile3=$EASNDM/$1/report.log --ifile4=$EASHED/$1/report.log \
			      --ofile=$RESULT/$1/pstate_time.txt
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

calculate_sched_perf rt-app-6
calculate_sched_perf rt-app-13
calculate_sched_perf rt-app-19
calculate_sched_perf rt-app-25
calculate_sched_perf rt-app-31
calculate_sched_perf rt-app-38
calculate_sched_perf rt-app-44
calculate_sched_perf rt-app-50

calculate_pstate_time mp3
calculate_pstate_time rt-app-6
calculate_pstate_time rt-app-13
calculate_pstate_time rt-app-19
calculate_pstate_time rt-app-25
calculate_pstate_time rt-app-31
calculate_pstate_time rt-app-38
calculate_pstate_time rt-app-44
calculate_pstate_time rt-app-50
