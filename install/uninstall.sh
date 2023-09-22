#!/sbin/sh
# $id uninstaller
# id is set/corrected by build.sh
# Copyright 2019-2023, VR25
# License: GPLv3+
#
# devs: triple hashtags (###) mark non-generic code

set -u
id=acc
domain=vr25
export TMPDIR=/dev/.$domain/$id

# set up busybox
#BB#
bin_dir=/data/adb/vr25/bin
busybox_dir=/dev/.vr25/busybox
magisk_busybox="/data/adb/ksu/bin/busybox /data/adb/magisk/busybox"
[ -x $busybox_dir/ls ] || {
  mkdir -p $busybox_dir
  chmod 0755 $busybox_dir $bin_dir/busybox 2>/dev/null || :
  for f in $bin_dir/busybox $magisk_busybox /system/*bin/busybox*; do
    [ ! -f $f ] || {
      $f --install -s $busybox_dir/
      break
    }
  done
  [ -x $busybox_dir/ls ] || {
    echo "Install busybox or simply place it in $bin_dir/"
    echo
    exit 3
  }
}
case $PATH in
  $bin_dir:*) ;;
  *) export PATH="$bin_dir:$busybox_dir:$PATH";;
esac
unset f bin_dir busybox_dir magisk_busybox
#/BB#

exec 2>/dev/null

# terminate/kill $id processes
mkdir -p $TMPDIR
(flock -n 0 || {
  read pid
  kill $pid
  timeout 10 flock 0
  kill -KILL $pid >/dev/null 2>&1
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
  /data/data/mattecarra.accapp/files/$id \
  /data/local/tmp/${id}[-_]*

[ "${1:-}" = install ] || rm -rf /data/adb/$domain/${id}-data
rmdir /data/adb/$domain

#legacy
rm -rf $(readlink -f /data/adb/$id) \
  /data/adb/$id \
  /data/adb/${id}-data \
  $(readlink -f /sbin/.$id/$id) \
  /data/media/0/${id}-logs-*.tar.* \
  /data/media/0/${id}[-_]*uninstaller.zip \
  /data/media/0/.${id}-config-backup.txt \
  /data/media/0/Download/$id \
  /data/media/0/$domain \
  /data/media/0/Documents/$domain/$id \
  /data/data/com.termux/files/home/.termux/boot/${id}-init.sh

exit 0
