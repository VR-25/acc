# Busybox Setup
# Copyright (c) 2019, VR25 (xda-developers)
# License: GPLv3+

if [ -d /sbin/.magisk/busybox ]; then
  [[ $PATH == /sbin/.magisk/busybox* ]] || PATH=/sbin/.magisk/busybox:$PATH
elif [ -d /sbin/.core/busybox ]; then
  [[ $PATH == /sbin/.core/busybox* ]] || PATH=/sbin/.core/busybox:$PATH
else
  [[ $PATH == /dev/.busybox* ]] || PATH=/dev/.busybox:$PATH
  if ! mkdir -m 700 /dev/.busybox 2>/dev/null; then
    if [ -x /data/adb/magisk/busybox ]; then
      /data/adb/magisk/busybox --install -s /dev/.busybox
    elif which busybox > /dev/null; then
      busybox --install -s /dev/.busybox
    else
      echo "(!) Install busybox binary first"
      exit 3
    fi
  fi
fi
