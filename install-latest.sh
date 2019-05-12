#!/system/bin/sh
#
# ACC installer/upgrader
# https://raw.githubusercontent.com/VR-25/acc/master/install-latest.sh
#
# Copyright (C) 2019, VR25 @xda-developers
# License: GPLv3+
#
# Run "which acc > /dev/null || sh <this script>" to install ACC.

set -euo pipefail
echo
echo "Downloading [module.prop], [update-binary] and [acc-*.zip]..."

modId=acc
log=/sbin/_$modId/install-stderr.log
[[ $PATH == "*magisk/busybox*" ]] || PATH=/sbin/.magisk/busybox:$PATH

get_ver() { sed -n 's/^versionCode=//p' ${1:-}; }

instVer=$(get_ver /sbin/_$modId/acc/module.prop 2>/dev/null || :)
baseUrl=https://github.com/VR-25/$modId
rawUrl=https://raw.githubusercontent.com/VR-25/$modId/master
currVer=$(curl -#L $rawUrl/module.prop | get_ver)
updateBin=$rawUrl/META-INF/com/google/android/update-binary
zipFile=$baseUrl/releases/download/$currVer/$modId-$currVer.zip

set +euo pipefail

if [ ${instVer:-0} -lt ${currVer:-0} ] \
  && curl -#L $updateBin > ${log%/*}/update-binary \
  && curl -#L $zipFile > ${log%/*}/$modId-$currVer.zip
then
  sh ${log%/*}/update-binary dummy outFD ${log%/*}/$modId-$currVer.zip 2>$log
fi

echo
exit 0
