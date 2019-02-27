#!/system/bin/sh
# ACC installer/updater
# https://raw.githubusercontent.com/Magisk-Modules-Repo/acc/master/common/upgrade.sh
# Copyright (C) 2019, VR-25 @xda-developers
# License: GPL V3+

# Developers: your apps can easily check whether acc is installed, and install it if it's not.
# That's as simple as running "which acc 1>/dev/null || sh <this script>" as root, on app startup.


set -euo pipefail

modId=acc
log=/dev/$modId/install-stderr.log

mkdir -p ${log%/*}
touch $log

modPath=/system/etc/$modId
[ -f $modPath/module.prop ] || modPath=/sbin/.core/img/$modId
[ -f $modPath/module.prop ] || modPath=/sbin/.magisk/img/$modId
 
which awk 1>/dev/null || PATH=$(echo $modPath | sed 's|/img/.*|/busybox|'):$PATH
 
get_ver() { sed -n 's/^versionCode=//p' ${1:-} 2>/dev/null || :; }
 
instVer=$(get_ver $modPath/module.prop)
baseUrl=https://github.com/Magisk-Modules-Repo/$modId
rawUrl=https://raw.githubusercontent.com/Magisk-Modules-Repo/$modId/master
currVer=$(curl -L $rawUrl/module.prop 2>/dev/null | get_ver)
installer=$rawUrl/META-INF/com/google/android/update-binary
zip=$baseUrl/releases/download/$currVer/$modId-$currVer.zip

set +euo pipefail

if [ ${instVer:-0} -lt ${currVer:-0} ]; then
  curl -L $installer 2>/dev/null > /dev/$modId/install.sh \
    && curl -L $zip 2>/dev/null > /dev/$modId/$modId-$currVer.zip
  # <installScript> <dummy> <outFD> <zip> <stderr log>
  [ $? -eq 0 ] && sh /dev/$modId/install.sh dummy dummy /dev/$modId/$modId-$currVer.zip 2>/dev/$modId/install-stderr.log
fi

exit $?
