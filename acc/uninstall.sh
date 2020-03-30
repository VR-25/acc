#!/system/bin/sh -u
# $id uninstaller
# id is set/corrected by build.sh
# Copyright (c) 2019-2020, VR25 (xda-developers)
# License: GPLv3+
#
# devs: triple hashtags (###) mark custom code


id=acc

# set up busybox
#BB#
if [ -d /sbin/.magisk/busybox ]; then
  case $PATH in
    /sbin/.magisk/busybox:*) :;;
    *) PATH=/sbin/.magisk/busybox:$PATH;;
  esac
else
  mkdir -p /dev/.busybox
  chmod 700 /dev/.busybox
  case $PATH in
    /dev/.busybox:*) :;;
    *) PATH=/dev/busybox:$PATH;;
  esac
  [ -x /dev/.busybox/busybox ] || {
    if [ -f /data/adb/magisk/busybox ]; then
      [ -x  /data/adb/magisk/busybox ] || chmod 700 /data/adb/magisk/busybox
      /data/adb/magisk/busybox --install -s /dev/.busybox
    elif which busybox > /dev/null; then
      busybox --install -s /dev/.busybox
    elif [ -f /data/adb/busybox ]; then
      [ -x  /data/adb/busybox ] || chmod 700 /data/adb/busybox
      /data/adb/busybox --install -s /dev/.busybox
    else
      echo "(!) Install busybox or simply place it in /data/adb/"
      exit 3
    fi
  }
fi
#/BB#

exec 2>/dev/null

# interrupt $id processes
pkill -f "/($id|${id}a) (-|--)(calibrate|[Cdef])|/${id}d\.sh" ###

# uninstall $id
rm -rf $(readlink -f /sbin/.$id/$id/) \
  /data/adb/$id \
  /data/adb/${id}-data \
  /data/adb/modules/$id \
  /data/adb/service.d/${id}-*.sh \
  /data/media/0/${id}-logs-*.tar.* \
  /data/data/mattecarra.accapp/files/$id ###

# remove flashable uninstaller
rm ${3:-/data/media/0/${id}-uninstaller.zip}

exit 0
