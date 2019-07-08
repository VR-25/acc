#!/system/bin/sh
#
# $modId Installer/Upgrader/Downgrader
# https://raw.githubusercontent.com/VR-25/$modId/$branch/install-latest.sh
#
# Copyright (c) 2019, VR25 (xda-developers.com)
# License: GPLv3+
#
# Usage: sh install-latest.sh [-c|--changelog|-f|--force|-n|--non-interactive] [reference]
#
# Refer to README.md > NOTES/TIPS FOR FRONT-END DEVELOPERS for exit codes


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
    exit 3
  fi
fi

if [ $(id -u) -ne 0 ]; then
  echo "(!) $0 must run as root (su)"
  exit 4
fi

set -euo pipefail
get_ver() { sed -n 's/^versionCode=//p' ${1:-}; }

reference="$(echo "$*" | sed -E 's/-c|--changelog|-f|--force|-n|--non-interactive|%.*%| //g')"
tarball=https://github.com/VR-25/$modId/archive/${reference:-master}.tar.gz
instVer=$(get_ver /sbin/.$modId/$modId/module.prop 2>/dev/null || :)
currVer=$(wget https://raw.githubusercontent.com/VR-25/$modId/${reference:-master}/module.prop --output-document - | get_ver)

set +euo pipefail

if [ ${instVer:-0} -lt ${currVer:-0} ] && [[ "$*" != *-*f* ]] \
  && echo && wget $tarball --output-document - | tar -xz
then
  echo
  trap - EXIT
  if [[ "$*" != *-*c* ]]; then
    if [[ "$*" != *-*n* ]]; then
      echo "(i) $modId $currVer is available"
      echo "- Changelog: https://github.com/VR-25/$modId/blob/${reference:-master}/README.md#latest-changes"
      echo "- Would you like to download and install it now (Y/n)?"
      read ans
      [[ ${ans:-y} == [nN]* ]] && exit 0
    else
      echo $currVer
      echo "https://github.com/VR-25/$modId/blob/${reference:-master}/README.md#latest-changes"
      exit 5
    fi
  fi
  export installDir0="$(echo "$*" | sed -E "s/-c|--changelog|-f|--force|-n|--non-interactive|%|$reference| //g")"
  sh ${modId}-${reference:-master}/install-current.sh
else
  echo
  echo "(i) No update available"
  exit 6
fi

exit 0
