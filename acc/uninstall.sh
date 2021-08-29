#!/sbin/sh
# $id uninstaller
# id is set/corrected by build.sh
# Copyright 2019-2021, VR25
# License: GPLv3+
#
# devs: triple hashtags (###) mark non-generic code

set -u
id=acc
domain=vr25
export TMPDIR=/dev/.$domain/$id

# set up busybox
#BB#
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
#/BB#

exec 2>/dev/null

# terminate/kill $id processes
mkdir -p $TMPDIR
(flock -n 0 || {
  read pid
  kill $pid
  #timeout 20 flock 0 || kill -KILL $pid
  echo "(i) If this seems to take too long, plug the charger"
  flock 0
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
  /data/data/mattecarra.accapp/files/$id

[ "${1:-}" = install ] || rm -rf /data/adb/$domain/${id}-data
rmdir /data/adb/$domain

#legacy
rm -rf $(readlink -f /data/adb/$id) \
  /data/adb/$id \
  /data/adb/${id}-data \
  $(readlink -f /sbin/.$id/$id) \
  /data/media/0/${id}-logs-*.tar.* \
  /data/media/0/${id}-uninstaller.zip \
  /data/media/0/.${id}-config-backup.txt \
  /data/media/0/Download/$id \
  /data/media/0/$domain \
  /data/media/0/Documents/$domain/$id \
  /data/data/com.termux/files/home/.termux/boot/${id}-init.sh

exit 0
