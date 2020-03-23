# Busybox Setup
# Copyright (c) 2019-2020, VR25 (xda-developers)
# License: GPLv3+
#
# Usage: . $0


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
  if [ ! -x /dev/.busybox/busybox ]; then
    if [ -f /data/adb/magisk/busybox ]; then
      chmod 700 /data/adb/magisk/busybox
      /data/adb/magisk/busybox --install -s /dev/.busybox
    elif which busybox > /dev/null; then
      # need absolute busybox path
      BUSYBOX=$(which busybox)
      $BUSYBOX --install -s /dev/.busybox
    elif [ -f /data/adb/busybox ]; then
      chmod 700 /data/adb/busybox
      /data/adb/busybox --install -s /dev/.busybox
    else
      echo "(!) Install busybox binary first"
      exit 3
    fi
  fi
fi
