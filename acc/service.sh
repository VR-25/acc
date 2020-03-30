#!/system/bin/sh
# Almquist Shell Setup
# Copyright (c) 2020, VR25 (xda-developers)
# License: GPLv3+


id=acc
TMPDIR=/sbin/.$id

# prevent unnecessary runs
[ -f $TMPDIR/${id}d-*.log -a -z "$1" ] && exit 0

# set up  working directory and busybox
[ -f $PWD/${0##*/} ] && modPath=$PWD || modPath=${0%/*}
. $modPath/setup-busybox.sh

# prepare Almquist Shell
mkdir -p /dev/.busybox
chmod 700 /dev/.busybox
ln -sf `which busybox` /dev/.busybox/ash

# start the engine
export id modPath PATH TMPDIR
$modPath/init.sh

exit 0
