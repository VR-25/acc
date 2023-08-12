#!/usr/bin/env sh
# Push and Install Zip
# Copyright 2022, VR25
# License: GPLv3+
#
# usage: $0 [adb device]

id=$(sed -n "s/^id=//p" module.prop)
version="$(sed -n 1p changelog.md | sed 's/[*()]//g')"
versionCode=${version#* }
version=${version% *}
zip=${id}_${version}_$versionCode
zip=$(echo _builds/$zip/$zip*zip)
dest=/sdcard/Download/acc.zip

adb $([ -z "${1-}" ] || echo "-s $1") push $zip $dest \
  && adb $([ -z "${1-}" ] || echo "-s $1") shell su -c magisk --install-module $dest || :
