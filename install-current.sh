#!/system/bin/sh
# From-source Installer/Upgrader
# Copyright (C) 2019, VR25 @xda-developers
# License: GPLv3+


# enforce absolute path
[[ $0 == /* ]] || exec echo -e "\n(!) You must use the absolute path\n"

# prepend Magisk's busybox to PATH
if [ -d /sbin/.magisk/busybox ]; then
  PATH=/sbin/.magisk/busybox:$PATH
elif [ -d /sbin/.core/busybox ]; then
  PATH=/sbin/.core/busybox:$PATH
fi

which awk > /dev/null || exec echo -e "\n(!) Install busybox first\n"

print() { sed -n "s|^$1=||p" ${2:-$srcDir/module.prop} 2>/dev/null || :; }

srcDir=${0%/*}
modId=$(print id)
name=$(print name)
author=$(print author)
version=$(print version)
versionCode=$(print versionCode)
config=/data/media/0/$modId/config.txt
configVer=$(print versionCode $config)

pgrep -f "/$modId -|/${modId}d.sh" | xargs kill -9 2>/dev/null

cd /sbin/.magisk/modules 2>/dev/null || cd /sbin/.core/img 2>/dev/null \
  || cd /data/adb || exec echo -e "\n(!) /data/adb/ not found\n"


cat << CAT

$name $version
Copyright (C) 2017-2019, $author
License: GPLv3+

(i) Installing to $PWD/$modId/...
CAT


umask 022
rm -rf $modId 2>/dev/null
set -euo pipefail
cp -R $srcDir/$modId/ .
cp $srcDir/module.prop $modId/
mkdir -p ${config%/*}/info
cp -f $srcDir/*.md ${config%/*}/info

if [ $PWD == /data/adb ]; then
  mv $modId/service.sh $modId/${modId}-init.sh
else
  ln $modId/service.sh $modId/post-fs-data.sh
  if [ $PWD == /sbin/.core/img ]; then
    sed -i s/\.magisk/\.core/ $modId/${modId}.sh
    sed -i s/\.magisk/\.core/ $modId/${modId}d.sh
  fi
fi
chmod 0755 $modId/*.sh

# patch/upgrade config
if [ -f $config ]; then
  if [ ${configVer:-0} -lt 201905110 ] \
    || [ ${configVer:-0} -gt $(print versionCode $modId/config.txt) ]
  then
    rm $config
  else
    [ $configVer -lt 201905111 ] \
      && sed -i -e '/CapacityOffset/s/C/c/' -e '/^versionCode=/s/=.*/=201905111/' $config
    [ $configVer -lt 201905130 ] \
      && sed -i -e '/^capacitySync=/s/true/false/' -e '/^versionCode=/s/=.*/=201905130/' $config
    if [ $configVer -lt 201906020 ]; then
      echo >> $config
      grep rebootOnUnplug $modId/config.txt >> $config
      echo >> $config
      grep "toggling interval" $modId/config.txt >> $config
      grep chargingOnOffDelay $modId/config.txt >> $config
      sed -i '/^versionCode=/s/=.*/=201906020/' $config
    fi
    if [ $configVer -lt 201906050 ]; then
      echo >> $config
      grep language $modId/config.txt >> $config
      sed -i '/^versionCode=/s/=.*/=201906050/' $config
    fi
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


[ $PWD == /data/adb ] && echo -e "(i) Use init.d or an app to run /data/adb/$modId/${modId}-init.sh on boot to initialize ${modId}.\n"

if [ -f $modId/service.sh ]; then
  $PWD/$modId/service.sh install
else
  $PWD/$modId/${modId}-init.sh install
fi

exit 0
