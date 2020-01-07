#!/bin/bash

src_repo=/home/leoy/Work2/Develop/SE/LCE2/u-boot-linaro-lces2
src_base=a705ebc81b7f91bbd0ef7c634284208342901149

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
	cat $i 2> /dev/null | grep -e "dfu" -e "DFU" -e "usb" \
		-e "USB" > /dev/null 2>&1

	#echo $?
	STATUS=$?
	if [ $STATUS -eq 0 ] ; then
		cp $i /tmp/sync_repo/dst/
		echo $i
	fi
done

popd
