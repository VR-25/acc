#!/system/bin/sh
# $id initializer
# Copyright 2017-2021, VR25
# License: GPLv3+

id=acc
domain=vr25
TMPDIR=/dev/.$domain/$id
execDir=/data/adb/$domain/$id
dataDir=/data/adb/$domain/${id}-data

[ -f $execDir/disable ] && exit 14

# wait til the lockscreen is ready
until [ .$(getprop init.svc.bootanim 2>/dev/null) = .stopped ]; do
  sleep 10
done

mkdir -p $TMPDIR
export dataDir domain execDir id TMPDIR
. $execDir/setup-busybox.sh
. $execDir/release-lock.sh
exec start-stop-daemon -bx $execDir/${id}d.sh -S -- "$@" || exit 12
