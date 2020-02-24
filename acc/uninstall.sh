#!/system/bin/sh -u
# $id uninstaller
# id is set/corrected by build.sh
# Copyright (c) 2019-2020, VR25 (xda-developers)
# License: GPLv3+
#
# devs: triple hashtags (###) mark custom code

id=acc

[ -f $PWD/${0##*/} ] && modPath=$PWD || modPath=${0%/*}

. $modPath/setup-busybox.sh
pkill -f "/$id (-|--)[def]|/${id}d\.sh" ###

exec > /dev/null 2>&1

rm -rf $(readlink -f $modPath) \
  /data/adb/$id \
  /data/adb/${id}-data \
  /data/adb/modules/$id \
  /data/adb/service.d/${id}-*.sh \
  /data/media/0/${id}-logs-*.tar.*

###
pm uninstall mattecarra.accapp \
  || rm -rf /data/*/mattecarra.accapp

exit 0
