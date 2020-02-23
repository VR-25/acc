#!/system/bin/sh
# Zip flasher
# Copyright (c) 2020, VR25 (xda-developers)
# License: GPLv3+
#
# usage: $0 "zip_file"
# the installation log file is stored in the zip_file directory


. ${0%/*}/setup-busybox.sh

# root check
if [ $(id -u) -ne 0 ]; then
  echo "(!) $0 must run as root (su)"
  exit 4
fi

# prepare tmpdir
rm -rf /dev/.install-zip 2>/dev/null
mkdir -p /dev/.install-zip

# verbose
exec 2>"${1}.log"
set -x

# extract update-binary
unzip -o "$1" 'META-INF/*' -d /dev/.install-zip >&2 || exit $?

# flash zip
# $3 == outfd
# $4 == zip_file
clear
sh /dev/.install-zip/META-INF/*/*/*/update-binary dummy 1 "$1"

# cleanup
rm -rf /dev/.install-zip 2>/dev/null
