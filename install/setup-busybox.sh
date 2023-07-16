# Busybox Setup
# Copyright 2019-2023, VR25
# License: GPLv3+
#
# Usage: . $0


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
