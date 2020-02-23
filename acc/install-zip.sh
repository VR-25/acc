#!/system/bin/sh
# Zip flasher
# Copyright (c) 2020, VR25 (xda-developers)
# License: GPLv3+
#
# usage: $0 or $0 "zip_file"
# the installation log file is stored in the zip_file directory


pick_zip() {
  local PS3="
(?) *.zip... "
  select target in $(ls -Ap ${1:-/storage} | grep -Ei '.*.zip$|/$') \< x; do
    cd ${1:-/storage}
    if [ -f "$target" ]; then
     zipFile="$target"; zipPicked=true
    elif [ -d "$target" ]; then
      echo
      pick_zip "$target"
    elif [ "$target" == \< ]; then
     cd ..
     echo
     pick_zip .
    elif [ "$target" == x ]; then
      exit 0
    fi
    break
  done
  [ -n "$zipFile" ] || exit 0
}

zipFile=$1

. ${0%/*}/setup-busybox.sh

# root check
if [ $(id -u) -ne 0 ]; then
  echo "(!) $0 must run as root (su)"
  exit 4
fi

# prepare tmpdir
rm -rf /dev/.install-zip 2>/dev/null
mkdir -p /dev/.install-zip

# call pick_zip() if there's no arg
[ -n "$zipFile" ] || pick_zip

# verbose
exec 2>"${zipFile}.log"
set -x

# extract update-binary
unzip -o "$zipFile" 'META-INF/*' -d /dev/.install-zip >&2 || exit $?

# flash zip
# $3 == outfd
# $4 == zip_file
echo
clear
sh /dev/.install-zip/META-INF/*/*/*/update-binary dummy 1 "$zipFile"

# cleanup
rm -rf /dev/.install-zip 2>/dev/null
