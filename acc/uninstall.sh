#!/system/bin/sh -u
# $id uninstaller
# id is set/corrected by build.sh
# Copyright (c) 2019, VR25 (xda-developers.com)
# License: GPLv3+

id=acc
[ -f $PWD/${0##*/} ] && modPath=$PWD || modPath=${0%/*}
. $modPath/busybox.sh
pkill -f "/$id (-|--)|/{id}.sh"
rm -rf $(readlink -f $modPath)
rm /data/media/0/${id}-uninstaller.zip 2>/dev/null
exit 0
