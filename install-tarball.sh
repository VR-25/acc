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
  [[ $PATH == /sbin/.magisk/busybox:* ]] || PATH=/sbin/.magisk/busybox:$PATH
else
  mkdir -p -m 700 /dev/.busybox
  [[ $PATH == /dev/.busybox:* ]] || PATH=/dev/.busybox:$PATH
  if [ ! -x /dev/.busybox/busybox ]; then
    if [ -f /data/adb/magisk/busybox ]; then
      chmod 700 /data/adb/magisk/busybox
      /data/adb/magisk/busybox --install -s /dev/.busybox
    elif which busybox > /dev/null; then
      busybox --install -s /dev/.busybox
    elif [ -f /data/adb/busybox ]; then
      chmod 700 /data/adb/busybox
      /data/adb/busybox --install -s /dev/.busybox
    else
      echo "(!) Install busybox binary first"
      exit 3
    fi
  fi
fi
#/BB#

# root check
if [ $(id -u) -ne 0 ]; then
  echo "(!) $0 must run as root (su)"
  exit 4
fi

umask 0
set -e

# get into the target directory
[ -f $PWD/${0##*/} ] || cd ${0%/*}
cd $(readlink -f $PWD)

# this runs on exit if the installer is launched by a front-end app
copy_log() {
  if [[ $PWD == /data/data/* ]]; then
    umask 077
    mkdir -p logs

    cp -af /data/adb/${1:-$id}-data/logs/install.log logs/${1:-$id}-install.log

    pkg=$(cd ..; pwd)
    pkg=${pkg##/data*/}

    owner=$(grep $pkg /data/system/packages.list | cut -d ' ' -f 2)
    chown -R $owner:$owner logs
  fi
}
trap copy_log EXIT

# extract tarball
rm -rf ${1:-$id}-*/ 2>/dev/null
tar -xf ${1:-$id}*gz

# install ${1:-$id}
export installDir0="$2"
/system/bin/sh ${1:-$id}-*/install-current.sh
rm -rf ${1:-$id}-*/

exit 0
