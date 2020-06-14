#!/system/bin/sh
# Advanced Charging Controller (ACC) Initializer
# © 2017-2020, VR25 (xda-developers)
# License: GPLv3+


id=acc
TMPDIR=/dev/.$id
execDir=/data/adb/$id

umask 0077
mkdir -p $TMPDIR
export id execDir TMPDIR

. $execDir/setup-busybox.sh
$execDir/release-lock.sh
exec start-stop-daemon -bx $execDir/${id}d.sh -S -- "$@" || exit 12
