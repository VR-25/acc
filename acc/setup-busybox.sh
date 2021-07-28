# Busybox Setup
# Copyright 2019-2020, VR25
# License: GPLv3+
#
# Usage: . $0


[ -x /dev/.vr25/busybox/ls ] || {
  mkdir -p /dev/.vr25/busybox
  chmod 0700 /dev/.vr25/busybox
  if [ -f /data/adb/vr25/bin/busybox ]; then
    [ -x /data/adb/vr25/bin/busybox ] || chmod -R 0700 /data/adb/vr25/bin
    /data/adb/vr25/bin/busybox --install -s /dev/.vr25/busybox
  elif [ -f /data/adb/magisk/busybox ]; then
    [ -x /data/adb/magisk/busybox ] || chmod 0700 /data/adb/magisk/busybox
    /data/adb/magisk/busybox --install -s /dev/.vr25/busybox
  elif which busybox > /dev/null; then
    eval "$(which busybox) --install -s /dev/.vr25/busybox"
  else
    echo "(!) Install busybox or simply place it in /data/adb/vr25/bin/"
    exit 3
  fi
}

case $PATH in
  /data/adb/vr25/bin:*) :;;
  *) export PATH=/data/adb/vr25/bin:/dev/.vr25/busybox:$PATH;;
esac
