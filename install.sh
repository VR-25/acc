#!/system/bin/sh
# ACC installer/updater
# https://raw.githubusercontent.com/Magisk-Modules-Repo/acc/master/install.sh
# Copyright (C) 2019, VR-25 @xda-developers
# License: GPL V3+
#
# Developers: your apps can easily install ACC.
# ACC itself takes care of upgrades.
#
# 1) Run "which acc 1>/dev/null"; if it returns 0, proceed.
# 2) Run "test -f /dev/acc/installed"; if it returns 0, show a reboot dialog; else, proceed.
# 3) Run sh <this script> and show a reboot dialog.


set -euo pipefail

modId=acc
log=/dev/$modId/install-stderr.log

mkdir -p ${log%/*}

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
  curl -L $installer 2>/dev/null > ${log%/*}/update-binary \
    && curl -L $zip 2>/dev/null > ${log%/*}/$modId-$currVer.zip
  # <installScript> <dummy> <outFD> <zip> <stderr log>
  [ $? -eq 0 ] && sh ${log%/*}/update-binary dummy dummy ${log%/*}/$modId-$currVer.zip 2>$log
fi

exit $?
