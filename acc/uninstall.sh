#!/system/bin/sh
# $id uninstaller
# id is set/corrected by build.sh
# Copyright (c) 2019-2020, VR25 (xda-developers)
# License: GPLv3+
#
# devs: triple hashtags (###) mark custom code


set -u
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
  chmod 0700 /dev/.busybox
  case $PATH in
    /dev/.busybox:*) :;;
    *) PATH=/dev/.busybox:$PATH;;
  esac
  [ -x /dev/.busybox/busybox ] || {
    if [ -f /data/adb/magisk/busybox ]; then
      [ -x /data/adb/magisk/busybox ] || chmod 0700 /data/adb/magisk/busybox
      /data/adb/magisk/busybox --install -s /dev/.busybox
    elif which busybox > /dev/null; then
      busybox --install -s /dev/.busybox
    elif [ -f /data/adb/busybox ]; then
      [ -x /data/adb/busybox ] || chmod 0700 /data/adb/busybox
      /data/adb/busybox --install -s /dev/.busybox
    else
      echo "(!) Install busybox or simply place it in /data/adb/"
      exit 3
    fi
  }
fi
#/BB#

exec 2>/dev/null

# terminate/kill $id processes ###
pkill -f "/($id|${id}a) (-|--)[deft]|/${id}d\.sh"
for count in 1 2 3 4 5; do
  sleep 1
  [ -z "$(pgrep -f "/($id|${id}a) (-|--)[deft]|/${id}d\.sh")" ] && break
done
pkill -9 -f "/($id|${id}a) (-|--)[deft]|/${id}d\.sh"

# uninstall $id
rm -rf $(readlink -f /sbin/.$id/$id/) \
  /data/adb/$id \
  /data/adb/modules/$id \
  /data/adb/service.d/${id}-*.sh \
  /data/media/0/${id}-logs-*.tar.* \
  /data/data/mattecarra.accapp/files/$id \
  /data/data/com.termux/files/home/.termux/boot/${id}-init.sh \
  $([ "${1:-}" == install ] || echo "/data/adb/${id}-data") ###

# remove flashable uninstaller
rm ${3:-/data/media/0/${id}-uninstaller.zip}

touch /dev/.acc-removed
exit 0
