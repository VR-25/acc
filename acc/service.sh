#!/system/bin/sh
# $id initializer
# Copyright 2017-present, VR25
# License: GPLv3+

id=acc
domain=vr25
TMPDIR=/dev/.$domain/$id
execDir=/data/adb/$domain/$id

umask 0077
mkdir -p $TMPDIR
export domain execDir id TMPDIR

. $execDir/setup-busybox.sh
. $execDir/release-lock.sh
exec start-stop-daemon -bx $execDir/${id}d.sh -S -- "$@" || exit 12
