#!/system/bin/sh
#
# $id Installer/Upgrader/Downgrader
# https://raw.githubusercontent.com/VR-25/$id/$branch/install-latest.sh
#
# Copyright (c) 2019, VR25 (xda-developers.com)
# License: GPLv3+
#
# Usage: sh install-latest.sh [-c|--changelog] [-f|--force] [-n|--non-interactive] [%install dir%] [reference]
#
# Refer to README.md > NOTES/TIPS FOR FRONT-END DEVELOPERS for exit codes


set +x
echo
id=acc
umask 077

# log
mkdir -p /data/adb/${id}-data/logs
exec 2>/data/adb/${id}-data/logs/install-latest.sh.log
set -x

trap 'e=$?; echo; exit $e' EXIT

# set up busybox
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

# root check
if [ $(id -u) -ne 0 ]; then
  echo "(!) $0 must run as root (su)"
  exit 4
fi

set -euo pipefail
get_ver() { sed -n 's/^versionCode=//p' ${1:-}; }

reference="$(echo "$*" | sed -E 's/-c|--changelog|-f|--force|-n|--non-interactive|%.*%| //g')"
tarball=https://github.com/VR-25/$id/archive/${reference:-master}.tar.gz
instVer=$(get_ver /sbin/.$id/$id/module.prop 2>/dev/null || :)
currVer=$(wget https://raw.githubusercontent.com/VR-25/$id/${reference:-master}/module.prop --output-document - | get_ver)

[ -f $PWD/${0##*/} ] || cd ${0%/*}
rm -rf "./${id}-${reference:-master}/" 2>/dev/null || :

if [ ${instVer:-0} -lt ${currVer:-0} ] || [[ "$*" == *-f* ]] || [[ "$*" == *--force* ]]; then
  case $* in
    *--changelog*|*-c*)
      case $* in
        *--non-interactive*|*-n*)
          echo $currVer
          echo "https://github.com/VR-25/$id/blob/${reference:-master}/README.md#latest-changes"
          exit 5
        ;;
        *)
          echo
          echo "(i) $id $currVer is available"
          echo "- Changelog: https://github.com/VR-25/$id/blob/${reference:-master}/README.md#latest-changes"
          echo "- Would you like to download and install it now (Y/n)?"
          read ans
          [[ ${ans:-y} == [nN]* ]] && exit 0
        ;;
      esac
    ;;
  esac
  export installDir0="$(echo "$*" | sed -E "s/-c|--changelog|-f|--force|-n|--non-interactive|%|$reference| //g")"
  set +euo pipefail
  trap - EXIT
  echo
  wget $tarball --output-document - | tar -xz \
    && sh ${id}-${reference:-master}/install-current.sh
else
  echo
  echo "(i) No update available"
  exit 6
fi

set -eu
rm -rf $0 "./${id}-${reference:-master}/"
exit 0
