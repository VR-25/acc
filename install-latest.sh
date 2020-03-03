#!/system/bin/sh
#
# $id Online Installer
# https://raw.githubusercontent.com/VR-25/$id/$branch/install-latest.sh
#
# Copyright (c) 2019-2020, VR25 (xda-developers)
# License: GPLv3+
#
# Usage: sh install-latest.sh [-c|--changelog] [-f|--force] [-n|--non-interactive] [%install dir%] [reference]
#
# Also refer to README.md > NOTES/TIPS FOR FRONT-END DEVELOPERS for > Exit Codes


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
#BB#
if [ -d /sbin/.magisk/busybox ]; then
  case $PATH in
    /sbin/.magisk/busybox:*) :;;
    *) PATH=/sbin/.magisk/busybox:$PATH;;
  esac
else
  mkdir -p -m 700 /dev/.busybox
  case $PATH in
    /dev/.busybox:*) :;;
    *) PATH=/dev/busybox:$PATH;;
  esac
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


set -euo pipefail 2>/dev/null || :
get_ver() { sed -n 's/^versionCode=//p' ${1:-}; }


reference=$(echo "$@" | sed -E 's/-c|--changelog|-f|--force|-n|--non-interactive| //g')
reference=${reference//%*%/}
: ${reference:=master}

tarball=https://github.com/VR-25/$id/archive/${reference}.tar.gz

installedVersion=$(get_ver /sbin/.$id/$id/module.prop 2>/dev/null || :)

onlineVersion=$(curl -L https://raw.githubusercontent.com/VR-25/$id/${reference}/module.prop | get_ver)


[ -f $PWD/${0##*/} ] || cd ${0%/*}
rm -rf "./${id}-${reference}/" 2>/dev/null || :


if [ ${installedVersion:-0} -lt ${onlineVersion:-0} ] \
  || [[ "$*" == *-f* ]] || [[ "$*" == *--force* ]]
then

  if echo "$@" | grep -Eq '\-\-changelog|\-c'; then
    if echo "$@" | grep -Eq '\-\-non-interactive|\-n'; then
      echo $onlineVersion
      echo "https://github.com/VR-25/$id/blob/${reference}/README.md#latest-changes"
      exit 5 # no update available
    else
      echo
      print_available $id $onlineVersion 2>/dev/null \
        || echo "(i) $id $onlineVersion is available"
      echo "- https://github.com/VR-25/$id/blob/${reference}/README.md#latest-changes"
      print_install_prompt 2>/dev/null \
        || echo -n "- Should I download and install it ([enter]: yes, CTRL-C: no)? "
      read
    fi
  fi

  # download and install tarball
  export installDir0=$(echo "$@" | sed -E "s/-c|--changelog|-f|--force|-n|--non-interactive|%|$reference| //g")
  set +euo pipefail 2>/dev/null || :
  trap - EXIT
  echo
  curl -L $tarball | tar -xz \
    && /system/bin/sh ${id}-${reference}/install-current.sh

else
  echo
  print_no_update 2>/dev/null || echo "(i) No update available"
  exit 6
fi


set -eu
rm -rf "./${id}-${reference}/" 2>/dev/null
exit 0
