#!/bin/bash

src_repo=/home/leoy/Work/disk/eas/andriod-aosp
src_base=b92472cd7902f045b6732b03162fd640bcd5c076

if [ -e /tmp/sync_repo ]; then
	echo "It's syncing?!"
	exit
fi

mkdir /tmp/sync_repo
mkdir /tmp/sync_repo/src
mkdir /tmp/sync_repo/dst

pushd $src_repo
git format-patch $src_base -o /tmp/sync_repo/src
popd

pushd /tmp/sync_repo/src

for i in $(ls)
do
	cat $i 2> /dev/null | grep -e "kernel/sched" -e "include/linux/sched.h" -e "arch/arm/kernel/topology.c" \
		-e "arch/arm64/kernel/topology.c" -e "Morten Rasmussen" -e "Juri Lelli" -e "Patrick Bellasi" \
		-e "Robin Randhawa"  -e "Chris Redpath" -e "Vincent Guittot" -e "Steve Muckle" > /dev/null 2>&1
	#echo $?
	STATUS=$?
	if [ $STATUS -eq 0 ] ; then
		cp $i /tmp/sync_repo/dst/
		echo $i
	fi
done

popd
