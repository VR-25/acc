#!/usr/bin/env sh
# Push and Install Zip
# Copyright 2022-2023, VR25
# License: GPLv3+
#
# usage: $0 [k] [adb device]
# k is for KaiOS

id=$(sed -n "s/^id=//p" module.prop)
version="$(sed -n 1p changelog.md | sed 's/[*()]//g')"
versionCode=${version#* }
version=${version% *}
zip=${id}_${version}_$versionCode
zip=$(echo _builds/$zip/$zip*zip)
dest=/sdcard/Download/acc.zip

[ ".${1-}" != .k ] || {
  dest=/data/usbmsc_mnt/acc.zip
  shift
}

adb $([ -z "${1-}" ] || echo "-s $1") push $zip $dest \
  && adb $([ -z "${1-}" ] || echo "-s $1") shell su -c magisk --install-module $dest || :
