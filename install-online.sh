#!/system/bin/sh
#
# $id Online Installer
# https://raw.githubusercontent.com/VR-25/$id/$branch/install-online.sh
#
# Copyright (c) 2019-2020, VR25 (xda-developers)
# License: GPLv3+
#
# Usage: sh install-online.sh [-c|--changelog] [-f|--force] [-k|--insecure] [-n|--non-interactive] [%install dir%] [reference]
#
# Also refer to README.md > NOTES/TIPS FOR FRONT-END DEVELOPERS for > Exit Codes


set +x
echo
id=acc
umask 077

# log
mkdir -p /data/adb/${id}-data/logs
exec 2>/data/adb/${id}-data/logs/install-online.sh.log
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


set -euo pipefail 2>/dev/null || :
get_ver() { sed -n 's/^versionCode=//p' ${1:-}; }


case "$@" in
  *--insecure*|*-k*) insecure=--insecure;;
  *) insecure=;;
esac


reference=$(echo "$@" | sed -E 's/%.*%|-c|--changelog|-f|--force|-k|--insecure|-n|--non-interactive| //g')
: ${reference:=master}

tarball=https://github.com/VR-25/$id/archive/${reference}.tar.gz

installedVersion=$(get_ver /sbin/.$id/$id/module.prop 2>/dev/null || :)

onlineVersion=$(curl -L $insecure https://raw.githubusercontent.com/VR-25/$id/${reference}/module.prop | get_ver)


[ -f $PWD/${0##*/} ] || cd ${0%/*}
rm -rf "./${id}-${reference}/" 2>/dev/null || :


if [ ${installedVersion:-0} -lt ${onlineVersion:-0} ] \
  || [[ "$*" == *-f* ]] || [[ "$*" == *--force* ]]
then

  ! echo "$@" | grep -Eq '\-\-changelog|\-c' || {
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
  }

  # download and install tarball
  export installDir0=$(echo "$@" | sed -E "s/-c|--changelog|-f|--force|-k|--insecure|-n|--non-interactive|%|$reference| //g")
  set +euo pipefail 2>/dev/null || :
  trap - EXIT
  echo
  curl -L $insecure $tarball | tar -xz \
    && /system/bin/sh ${id}-${reference}/install.sh

else
  echo
  print_no_update 2>/dev/null || echo "(i) No update available"
  exit 6
fi


set -eu
rm -rf "./${id}-${reference}/" 2>/dev/null
exit 0
