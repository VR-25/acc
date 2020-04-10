#!/system/bin/sh
# ${1:-$id}*gz Installer
# Copyright (c) 2019-2020, VR25 (xda-developers.com)
# License: GPLv3+

id=acc
umask 077

# log
mkdir -p /data/adb/${1:-$id}-data/logs
exec 2>/data/adb/${1:-$id}-data/logs/install-tarball.sh.log
set -x

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
    *) PATH=/dev/.busybox:$PATH;;
  esac
  [ -x /dev/.busybox/busybox ] || {
    if [ -f /data/adb/magisk/busybox ]; then
      [ -x /data/adb/magisk/busybox ] || chmod 700 /data/adb/magisk/busybox
      /data/adb/magisk/busybox --install -s /dev/.busybox
    elif which busybox > /dev/null; then
      busybox --install -s /dev/.busybox
    elif [ -f /data/adb/busybox ]; then
      [ -x /data/adb/busybox ] || chmod 700 /data/adb/busybox
      /data/adb/busybox --install -s /dev/.busybox
    else
      echo "(!) Install busybox or simply place it in /data/adb/"
      exit 3
    fi
  }
fi
#/BB#

# root check
[ $(id -u) -ne 0 ] && {
  echo "(!) $0 must run as root (su)"
  exit 4
}

umask 0
set -e

# get into the target directory
[ -f $PWD/${0##*/} ] || cd ${0%/*}
cd $(readlink -f $PWD)

# this runs on exit if the installer is launched by a front-end app
copy_log() {
  [[ $PWD != /data/data/* ]] || {
    umask 077
    mkdir -p logs

    cp -af /data/adb/${1:-$id}-data/logs/install.log logs/${1:-$id}-install.log 2>/dev/null || return 0

    pkg=$(cd ..; pwd)
    pkg=${pkg##/data*/}

    owner=$(grep $pkg /data/system/packages.list | cut -d ' ' -f 2)
    chown -R $owner:$owner logs
  }
}
trap copy_log EXIT

# extract tarball
rm -rf ${1:-$id}_*/ 2>/dev/null
tar -xf ${1:-$id}_*gz

# install ${1:-$id}
export installDir0="$2"
/system/bin/sh ${1:-$id}_*/install.sh
rm -rf ${1-$id}_*/

exit 0
