#!/system/bin/sh
# From-source Installer/Upgrader
# Copyright (c) 2019, VR25 (xda-developers.com)
# License: GPLv3+


echo
trap 'e=$?; echo; exit $e' EXIT

if ! which busybox > /dev/null; then
  if [ -d /sbin/.magisk/busybox ]; then
    PATH=/sbin/.magisk/busybox:$PATH
  elif [ -d /sbin/.core/busybox ]; then
    PATH=/sbin/.core/busybox:$PATH
  else
    echo "(!) Install busybox binary first"
    exit 3
  fi
fi

if [ $(id -u) -ne 0 ]; then
  echo "(!) $0 must run as root (su)"
  exit 4
fi

print() { sed -n "s|^$1=||p" ${2:-$srcDir/module.prop}; }

umask 022
set -euo pipefail

[ -f $PWD/${0##*/} ] && srcDir=$PWD || srcDir=${0%/*}
modId=$(print id)
name=$(print name)
author=$(print author)
version=$(print version)
versionCode=$(print versionCode)
installDir=${installDir0:-/data/data/mattecarra.accapp/files}
config=/data/media/0/$modId/${modId}.conf
[ -f $config ] || mv ${config%/*}/config.txt $config 2>/dev/null || :

# migrate/restore config
if [ -d ${config%/*} ] && [ ! -d /data/adb/${modId}-data ]; then
  mv $config ${config%/*}/config.txt 2>/dev/null || :
  (cd /data/media/0; mv ${config%/*} ${modId}-data
  tar -cf - ${modId}-data | tar -xf - -C /data/adb)
  rm -rf ${modId}-data
fi
config=/data/adb/${modId}-data/config.txt
[ -f $config ] || cp /data/media/0/.${modId}-config-backup.txt $config 2>/dev/null || :

configVer=$(print versionCode $config 2>/dev/null || :)

[ -d $installDir ] || installDir=/sbin/.magisk/modules
[ -d $installDir ] || installDir=/sbin/.core/img
[ -d $installDir ] || installDir=/data/adb
[ -d $installDir ] || { echo "(!) /data/adb/ not found\n"; exit 1; }


cat << CAT
$name $version
Copyright (c) 2017-2019, $author
License: GPLv3+

(i) Installing to $installDir/$modId/...
CAT

(pgrep -f "/$modId (-|--)[def]|/${modId}d.sh" | xargs kill -9 2>/dev/null) || :

rm -rf $(readlink -f /sbin/.$modId/$modId) 2>/dev/null || :
cp -R $srcDir/$modId/ $installDir/
installDir=$installDir/$modId
[ ${installDir0:-x} == x ] && installDir0=/data/data/mattecarra.accapp/files/$modId || installDir0=$installDir0/$modId
cp $srcDir/module.prop $installDir/

mkdir -p ${config%/*}/info
cp -f $srcDir/*.md ${config%/*}/info

case $installDir in
  /data/adb/$modId|$installDir0)
    mv $installDir/service.sh $installDir/${modId}-init.sh;;
  *)
    ln $installDir/service.sh $installDir/post-fs-data.sh;;
esac

chmod -R 0600 $installDir
chmod 0700 $installDir/*.sh

# patch/upgrade config
if [ -f $config ]; then
  if [ ${configVer:-0} -lt 201906230 ] \
      || [ ${configVer:-0} -gt $(print versionCode $installDir/default-config.txt) ]
    then
      rm $config
  else
    if [ $configVer -lt 201906290 ]; then
      echo prioritizeBattIdleMode=false >> $config
      sed -i '/^versionCode=/s/=.*/=201906290/' $config
    fi
    if [ $configVer -lt 201907080 ]; then
      sed -i '/^loopDelay=/s/=.*/=10,30/' $config
      sed -i '/^versionCode=/s/=.*/=201907080/' $config
    fi
    if [ $configVer -lt 201907090 ]; then
      sed -i '/^rebootOnUnplug=/d' $config
      sed -i '/^versionCode=/s/=.*/=201907090/' $config
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
    - Git repository: github.com/VR-25/$modId/
    - Telegram channel: t.me/vr25_xda/
    - Telegram group: t.me/${modId}_magisk/
    - Telegram profile: t.me/vr25xda/
    - XDA thread: forum.xda-developers.com/apps/magisk/module-magic-charging-switch-cs-v2017-9-t3668427/

(i) Important info: https://bit.ly/2TRqRz0

(i) Rebooting is unnecessary.
- $modId can be used right now.
- $modId daemon is already initializing.
CAT


[ $installDir == /data/adb ] && echo -e "\n(i) Use init.d or an app to run $installDir/${modId}-init.sh on boot to initialize ${modId}."

echo
trap - EXIT

if [ -f $installDir/service.sh ]; then
  $installDir/service.sh --override
else
  $installDir/${modId}-init.sh --override
fi

e=$?
[ $e -eq 0 ] || { echo; exit $e; }
exit 0
