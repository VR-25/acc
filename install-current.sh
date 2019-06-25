#!/system/bin/sh
# From-source Installer/Upgrader
# Copyright (C) 2019, VR25 @xda-developers
# License: GPLv3+


# prepend Magisk's busybox to PATH
if [ -d /sbin/.magisk/busybox ]; then
  PATH=/sbin/.magisk/busybox:$PATH
elif [ -d /sbin/.core/busybox ]; then
  PATH=/sbin/.core/busybox:$PATH
fi

which awk > /dev/null || { echo -e "\n(!) Install busybox or similar binary first\n"; exit 1; }

print() { sed -n "s|^$1=||p" ${2:-$srcDir/module.prop}; }

umask 022
set -euo pipefail

[ -f $PWD/${0##*/} ] && srcDir=$PWD || srcDir=${0%/*}
modId=$(print id)
name=$(print name)
author=$(print author)
version=$(print version)
versionCode=$(print versionCode)
installDir=/sbin/.magisk/modules
config=/data/media/0/$modId/acc.conf
[ -f $config ] || mv ${config%/*}/config.txt $config 2>/dev/null || :
configVer=$(print versionCode $config)

[ -d $installDir ] || installDir=/sbin/.core/img
[ -d $installDir ] || installDir=/data/adb
[ -d $installDir ] || { echo -e "\n(!) /data/adb/ not found\n"; exit 1; }


cat << CAT

$name $version
Copyright (C) 2017-2019, $author
License: GPLv3+

(i) Installing to $installDir/$modId/...
CAT

(pgrep -f "/$modId -|/${modId}d.sh" | xargs kill -9 2>/dev/null) || :

rm -rf $installDir/${modId:-_PLACEHOLDER_} 2>/dev/null
cp -R $srcDir/$modId/ $installDir/
installDir=$installDir/$modId
cp $srcDir/module.prop $installDir/

mkdir -p ${config%/*}/info
cp -f $srcDir/*.md ${config%/*}/info

if [ $installDir == /data/adb ]; then
  mv $installDir/service.sh $installDir/${modId}-init.sh
else
  ln $installDir/service.sh $installDir/post-fs-data.sh
  if [ $installDir == /sbin/.core/img ]; then
    sed -i s/\.magisk/\.core/ $installDir/${modId}.sh
    sed -i s/\.magisk/\.core/ $installDir/${modId}d.sh
  fi
fi
chmod 0755 $installDir/*.sh

# patch/upgrade config
if [ -f $config ]; then
  if [ ${configVer:-0} -lt 201906230 ] \
      || [ ${configVer:-0} -gt $(print versionCode $installDir/acc.conf) ]
    then
      rm $config
  fi
fi

chmod -R 0777 ${config%/*}
set +euo pipefail


cat << CAT
- Done

  LATEST CHANGES

CAT


println=false
cat ${config%/*}/info/README.md | while IFS= read -r line; do
  if $println; then
    echo "    $line"
  else
    echo "$line" | grep -q \($versionCode\) && println=true \
      && echo "    $line"
  fi
done


cat << CAT

  LINKS
    - ACC app: github.com/MatteCarra/AccA/
    - Battery University: batteryuniversity.com/learn/article/how_to_prolong_lithium_based_batteries/
    - Donate: paypal.me/vr25xda/
    - Facebook page: facebook.com/VR25-at-xda-developers-258150974794782/
    - Git repository: github.com/VR-25/$MODID/
    - Telegram channel: t.me/vr25_xda/
    - Telegram group: t.me/${MODID}_magisk/
    - Telegram profile: t.me/vr25xda/
    - XDA thread: forum.xda-developers.com/apps/magisk/module-magic-charging-switch-cs-v2017-9-t3668427/

(i) Important info: https://bit.ly/2TRqRz0

(i) Rebooting is unnecessary.
- $modId can be used right now.
- $modId daemon is already initializing.

CAT


[ $installDir == /data/adb ] && echo -e "(i) Use init.d or an app to run $installDir/${modId}-init.sh on boot to initialize ${modId}.\n"

if [ -f $installDir/service.sh ]; then
  $installDir/service.sh --override
else
  $installDir/${modId}-init.sh --override
fi

exit 0
