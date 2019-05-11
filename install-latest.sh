#!/system/bin/sh
#
# ACC installer/upgrader
# https://raw.githubusercontent.com/VR-25/acc/master/install-latest.sh
#
# Copyright (C) 2019, VR25 @xda-developers
# License: GPLv3+
#
# Run "test -f /dev/acc/modPath/acc || sh <this script>" to install ACC.

set -euo pipefail

modId=acc
log=/dev/$modId/install-stderr.log
which awk >/dev/null || PATH=/sbin/.magisk/busybox:$PATH

get_ver() { sed -n 's/^versionCode=//p' ${1:-}; }

instVer=$(get_ver /dev/$modId/modPath/module.prop 2>/dev/null)
baseUrl=https://github.com/Magisk-Modules-Repo/$modId
rawUrl=https://raw.githubusercontent.com/Magisk-Modules-Repo/$modId/master
currVer=$(curl -L $rawUrl/module.prop 2>/dev/null | get_ver)
updateBin=$rawUrl/META-INF/com/google/android/update-binary
zipFile=$baseUrl/releases/download/$currVer/$modId-$currVer.zip

set +euo pipefail

if [ ${instVer:-0} -lt ${currVer:-0} ] \
  && curl -L $updateBin 2>/dev/null > ${log%/*}/update-binary \
  && curl -L $zipFile 2>/dev/null > ${log%/*}/$modId-$currVer.zip
then
  sh ${log%/*}/update-binary dummy outFD ${log%/*}/$modId-$currVer.zip 2>$log
fi

exit $?
