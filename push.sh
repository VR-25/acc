#!/usr/bin/env sh
# Push and Install Zip
# Copyright 2022-2024, VR25
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

one=${1-}

_adb() {
  if [ -n "${one-}" ]; then
    adb -s $one "$@"
  else
    adb "$@"
  fi
}

if _adb shell su -c "which apd >/dev/null"; then
  install="apd module install $dest"
elif _adb shell su -c "which ksud >/dev/null"; then
  install="ksud module install $dest"
elif _adb shell su -c "which magisk >/dev/null"; then
  install="magisk --install-module $dest"
else
  install=
fi

[ -z "$install" ] || _adb push $zip $dest && _adb shell su -c "$install" || :
