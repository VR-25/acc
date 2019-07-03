#!/system/bin/sh
#
# $modId installer/upgrader
# https://raw.githubusercontent.com/VR-25/$modId/$branch/install-latest.sh
#
# Copyright (c) 2019, VR25 @xda-developers
# License: GPLv3+
#
# Usage: sh install-latest.sh <branch>


echo
modId=acc
trap 'e=$?; echo; exit $e' EXIT

if ! which busybox > /dev/null; then
  if [ -d /sbin/.magisk/busybox ]; then
    PATH=/sbin/.magisk/busybox:$PATH
  elif [ -d /sbin/.core/busybox ]; then
    PATH=/sbin/.core/busybox:$PATH
  else
    echo "(!) Install busybox binary first"
    exit 1
  fi
fi

if [ $(id -u) -ne 0 ]; then
  echo "(!) $0 must run as root (su)"
  exit 1
fi

rm -rf /dev/${modId}-tmp 2>/dev/null
mkdir -p /dev/${modId}-tmp
cd /dev/${modId}-tmp

set -euo pipefail
get_ver() { sed -n 's/^versionCode=//p' ${1:-}; }

instVer=$(get_ver /sbin/.$modId/$modId/module.prop 2>/dev/null || :)
currVer=$(wget https://raw.githubusercontent.com/VR-25/$modId/${1:-master}/module.prop --output-document - | get_ver)
tarball=https://github.com/VR-25/$modId/archive/${1:-master}.tar.gz

set +euo pipefail

if [ ${instVer:-0} -lt ${currVer:-0} ] \
  && echo && wget $tarball --output-document - | tar -xz
then
  echo
  trap - EXIT
  sh ${modId}-${1:-master}/install-current.sh
else
  echo
  echo "(i) No update available"
fi

exit 0
