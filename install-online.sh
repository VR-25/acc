#!/system/bin/sh
#
# $id Online Installer
# https://raw.githubusercontent.com/VR-25/$id/$branch/install-online.sh
#
# Copyright 2019-2020, VR25
# License: GPLv3+
#
# Usage: sh install-online.sh [-c|--changelog] [-f|--force] [-k|--insecure] [-n|--non-interactive] [%install dir%] [reference]
#
# Also refer to README.md > NOTES/TIPS FOR FRONT-END DEVELOPERS for > Exit Codes


set +x
echo
id=acc
umask 0077

# log
[ -z "${LINENO-}" ] || export PS4='$LINENO: '
mkdir -p /data/adb/${id}-data/logs
exec 2>/data/adb/${id}-data/logs/install-online.sh.log
set -x

trap 'e=$?; echo; exit $e' EXIT


# set up busybox
#BB#
[ -x /dev/.busybox/ls ] || {
  mkdir -p /dev/.busybox
  chmod 0700 /dev/.busybox
  if [ -f /data/adb/bin/busybox ]; then
    [ -x /data/adb/bin/busybox ] || chmod -R 0700 /data/adb/bin
    /data/adb/bin/busybox --install -s /dev/.busybox
  elif [ -f /data/adb/magisk/busybox ]; then
    [ -x /data/adb/magisk/busybox ] || chmod 0700 /data/adb/magisk/busybox
    /data/adb/magisk/busybox --install -s /dev/.busybox
  elif which busybox > /dev/null; then
    eval "$(which busybox) --install -s /dev/.busybox"
  else
    echo "(!) Install busybox or simply place it in /data/adb/bin/"
    exit 3
  fi
}
case $PATH in
  /data/adb/bin:*) :;;
  *) export PATH=/data/adb/bin:/dev/.busybox:$PATH;;
esac
#/BB#


# root check
[ $(id -u) -ne 0 ] && {
  echo "(!) $0 must run as root (su)"
  exit 4
}


set -eu
get_ver() { sed -n 's/^versionCode=//p' ${1:-}; }


! test -f /data/adb/bin/curl || {
  test -x /data/adb/bin/curl \
    || chmod -R 0700 /data/adb/bin
}


case "$@" in
  *--insecure*|*-k*) insecure=--insecure;;
  *) insecure=;;
esac


reference=$(echo "$*" | sed -E 's/%.*%|-c|--changelog|-f|--force|-k|--insecure|-n|--non-interactive| //g')
: ${reference:=master}

tarball=https://github.com/VR-25/$id/archive/${reference}.tar.gz

installedVersion=$(get_ver /data/adb/$id/module.prop 2>/dev/null || :)

onlineVersion=$(curl -L $insecure https://raw.githubusercontent.com/VR-25/$id/${reference}/module.prop | get_ver)


[ -f $PWD/${0##*/} ] || cd ${0%/*}
rm -rf "./${id}-${reference}/" 2>/dev/null || :


if [ ${installedVersion:-0} -lt ${onlineVersion:-0} ] \
  || [[ "$*" = *-f* ]] || [[ "$*" = *--force* ]]
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
  : ${installDir:=$(echo "$@" | sed -E "s/-c|--changelog|-f|--force|-k|--insecure|-n|--non-interactive|%|$reference| //g")}
  export installDir
  set +eu
  trap - EXIT
  echo
  curl -L $insecure $tarball | tar -xz \
    && ash ${id}-${reference}/install.sh

else
  echo
  print_no_update 2>/dev/null || echo "(i) No update available"
  exit 6
fi


set -eu
rm -rf "./${id}-${reference}/" 2>/dev/null
exit 0
