#!/system/bin/sh

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

id=acc
set -e
[ -f $PWD/${0##*/} ] || cd ${0%/*}
[ -d $id/${id}-init.sh ] && exit 0
tar -xf ${id}*gz
export installDir0="$1"
sh ${id}-*/install-current.sh
rm -rf ${id}-*/
