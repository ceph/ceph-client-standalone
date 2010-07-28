#!/bin/sh


if [ "$1" = "" ]
then
	echo "Usage: $0 <kernelver>"
	exit
fi

MODROOT="/lib/modules/$1"

if ! [ -f /etc/debian_version ]
then
	echo "Info: runs only on Debian and derivates"
	exit
fi


if [ -d "$MODROOT" ]
then
	if [ -f "$MODROOT/kernel/fs/ceph/ceph.ko" ] 
	then
		if  ! [ -f "$MODROOT/kernel/fs/ceph/ceph.ko.dpkg-divert-by-ceph-dkms" ]
		then
			dpkg-divert --rename --package ceph-dkms --divert "$MODROOT/kernel/fs/ceph/ceph.ko.dpkg-divert-by-ceph-dkms" --add "$MODROOT/kernel/fs/ceph/ceph.ko"
		else
			echo "Warning: $MODROOT/kernel/fs/ceph/ceph.ko  and diverted $MODROOT/kernel/fs/ceph/ceph.ko.dpkg-divert-by-ceph-dkms exist both!"
		fi
	fi
else 
	echo "Warning: $MODROOT is not a directory"
fi
