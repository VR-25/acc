#!/system/bin/sh
# Advanced Charging Controller (ACC) Initializer
# Copyright 2017-2020, VR25
# License: GPLv3+
#
# devs: triple hashtags (###) mark non-generic code


id=acc
TMPDIR=/dev/.$id
execDir=/data/adb/vr25/$id

umask 0077
mkdir -p $TMPDIR
export id execDir TMPDIR

. $execDir/setup-busybox.sh
$execDir/release-lock.sh
exec start-stop-daemon -bx $execDir/${id}d.sh -S -- "$@" || exit 12 ###
