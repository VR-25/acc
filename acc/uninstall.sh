#!/sbin/sh
# $id uninstaller
# id is set/corrected by build.sh
# Copyright 2019-2020, VR25
# License: GPLv3+
#
# devs: triple hashtags (###) mark non-generic code

set -u
id=acc
domain=vr25
export TMPDIR=/dev/.$domain/$id

# set up busybox
#BB#
[ -x /dev/.busybox/ls ] || {
  mkdir -p /dev/.busybox
  chmod 0700 /dev/.busybox
  if [ -f /data/adb/bin/busybox ]; then
    [ -x /data/adb/bin/busybox ] || chmod -R 0700 /data/adb/bin
    /data/adb/bin/busybox --install -s /dev/.busybox
  elif [ -f /data/adb/magisk/busybox ]; then
    [ -x /data/adb/magisk/busybox ] || chmod 0700 /data/adb/magisk/busybox
    /data/adb/magisk/busybox --install -s /dev/.busybox
  elif which busybox > /dev/null; then
    eval "$(which busybox) --install -s /dev/.busybox"
  else
    echo "(!) Install busybox or simply place it in /data/adb/bin/"
    exit 3
  fi
}
case $PATH in
  /data/adb/bin:*) :;;
  *) export PATH=/data/adb/bin:/dev/.busybox:$PATH;;
esac
#/BB#

exec 2>/dev/null

# terminate/kill $id processes
mkdir -p $TMPDIR
(flock -n 0 || {
  read pid
  kill $pid
  timeout 20 flock 0 || kill -KILL $pid
}) <>$TMPDIR/${id}.lock
###
pgrep -f "/($id|${id}a) (-|--)[det]|/${id}d" > /dev/null && { #legacy
  pkill -f "/($id|${id}a) (-|--)[det]|/${id}d"
  for count in $(seq 10); do
    sleep 2
    [ -z "$(pgrep -f "/($id|${id}a) (-|--)[det]|/${id}d")" ] && break
  done
  pkill -KILL -f "/($id|${id}a) (-|--)[det]|/${id}d"
}

# uninstall $id ###
rm -rf /data/adb/$domain/$id \
  /data/adb/modules/$id \
  /data/adb/service.d/${id}-*.sh \
  /data/data/mattecarra.accapp/files/$id \
  $(test "${1:-}" = install || echo "/sdcard/Documents/$domain/$id")

#legacy
rm -rf $(readlink -f /data/adb/$id) \
  /data/adb/$id \
  /data/adb/${id}-data \
  $(readlink -f /sbin/.$id/$id) \
  /sdcard/${id}-logs-*.tar.* \
  /sdcard/${id}-uninstaller.zip \
  /sdcard/.${id}-config-backup.txt \
  /sdcard/Download/$id \
  /sdcard/$domain \
  /sdcard/Documents/$domain/$id/.acc-config-backup.txt \
  /data/data/com.termux/files/home/.termux/boot/${id}-init.sh 2>/dev/null

exit 0
