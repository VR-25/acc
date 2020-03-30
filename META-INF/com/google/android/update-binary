#!/system/bin/sh
# $id Installer/Upgrader
# Copyright (c) 2019-2020, VR25 (xda-developers)
# License: GPLv3+
#
# devs: triple hashtags (###) mark custom code


set +x

# override the official Magisk module installer
SKIPUNZIP=1

echo
id=acc
umask 077

# log
mkdir -p /data/adb/${id}-data/logs
exec 2>/data/adb/${id}-data/logs/install.log
set -x

trap 'e=$?; echo; exit $e' EXIT

# set up busybox
#BB#
if [ -d /sbin/.magisk/busybox ]; then
  case $PATH in
    /sbin/.magisk/busybox:*) :;;
    *) PATH=/sbin/.magisk/busybox:$PATH;;
  esac
else
  mkdir -p /dev/.busybox
  chmod 700 /dev/.busybox
  case $PATH in
    /dev/.busybox:*) :;;
    *) PATH=/dev/busybox:$PATH;;
  esac
  [ -x /dev/.busybox/busybox ] || {
    if [ -f /data/adb/magisk/busybox ]; then
      [ -x  /data/adb/magisk/busybox ] || chmod 700 /data/adb/magisk/busybox
      /data/adb/magisk/busybox --install -s /dev/.busybox
    elif which busybox > /dev/null; then
      busybox --install -s /dev/.busybox
    elif [ -f /data/adb/busybox ]; then
      [ -x  /data/adb/busybox ] || chmod 700 /data/adb/busybox
      /data/adb/busybox --install -s /dev/.busybox
    else
      echo "(!) Install busybox or simply place it in /data/adb/"
      exit 3
    fi
  }
fi
#/BB#

# root check
[ $(id -u) -ne 0 ] && {
  echo "(!) $0 must run as root (su)"
  exit 4
}

get_prop() { sed -n "s|^$1=||p" ${2:-$srcDir/module.prop}; }

set_perms() {
  local owner=${2:-0} perms=600 target=$(readlink -f $1)
  if echo $target | grep -q '.*\.sh$' || [ -d $target ]; then perms=700; fi
  chmod $perms $target
  chown $owner:$owner $target
  restorecon $target > /dev/null 2>&1 || :
}

set_perms_recursive() {
  local owner=${2:-0} target=""
  find $1 2>/dev/null | while read target; do set_perms $target $owner; done
}

set -euo pipefail 2>/dev/null || :

# set source code directory
[ -f $PWD/${0##*/} ] && srcDir=$PWD || srcDir=${0%/*}
srcDir=${srcDir/#"${0##*/}"/"."}

# unzip flashable zip if source code is unavailable
[ -f $srcDir/module.prop ] || {
  srcDir=/dev/.tmp
  rm -rf $srcDir 2>/dev/null || :
  mkdir $srcDir
  unzip ${ZIP:-${3-}} -d $srcDir/ >&2
}

name=$(get_prop name)
author=$(get_prop author)
version=$(get_prop version)
versionCode=$(get_prop versionCode)
installDir=${installDir0:=/data/data/mattecarra.${id}app/files} ###
config=/data/adb/${id}-data/config.txt

# check/set parent installation directory
[ -d $installDir ] || installDir=/sbin/.magisk/modules
[ -d $installDir ] || installDir=/data/adb
[ -d $installDir ] || { echo "(!) /data/adb/ not found\n"; exit 1; }


###
echo "$name $version ($versionCode)
Copyright (c) 2017-2020, $author
License: GPLv3+

(i) Installing in $installDir/$id/..."


# install
cp $config /data/.${id}-config-bkp 2>/dev/null || :
/system/bin/sh $srcDir/$id/uninstall.sh
mv /data/.${id}-config-bkp $config 2>/dev/null || :
cp -R $srcDir/$id/ $installDir/
installDir=$(readlink -f $installDir/$id)
installDir0=$installDir0/$id
[ ! -d $installDir0 ] || installDir0=$(readlink -f $installDir0)
cp $srcDir/module.prop $installDir/
mkdir -p ${config%/*}/info
cp -f $srcDir/*.md ${config%/*}/info
[ $installDir == /data/adb/$id ] || ln -s $installDir /data/adb/


if [ $installDir != /sbin/.magisk/modules/$id ]; then
  mv $installDir/service.sh $installDir/${id}-init.sh

  # enable upgrading through Magisk Manager
  ln -s $installDir /sbin/.magisk/modules/$id 2>/dev/null || :

  [ ! -d /data/adb/service.d ] || {

# alternate initialization script
echo "#!/system/bin/sh
# alternate $id initializer
(until [ -d /storage/emulated/0/?ndroid ]; do sleep 10; done
if [ -f $installDir/${id}-init.sh ]; then
  $installDir/${id}-init.sh
else
  rm \$0
fi
exit 0 &) &
exit 0" > /data/adb/service.d/${id}-init.sh

# post-uninstall cleanup script
echo "#!/system/bin/sh
# $id post-uninstall cleanup
(until [ -d /storage/emulated/0/?ndroid ]; do sleep 15; done
if [ ! -f $installDir/module.prop ]; then
  rm /data/adb/$id /data/adb/${id}-data /data/adb/modules/$id \$0 2>/dev/null
fi
exit 0 &) &
exit 0"  > /data/adb/service.d/${id}-cleanup.sh

    chmod 700 /data/adb/service.d/${id}-*.sh
  }

else
  # workaround for Magisk "forgetting service.sh" issue
  ln $installDir/service.sh $installDir/post-fs-data.sh
fi


# disable magic mount (Magisk)
touch /sbin/.magisk/modules/$id/skip_mount 2>/dev/null || :

# restore config backup
[ -f $config ] || cp /data/media/0/.${id}-config-backup.txt $config 2>/dev/null || :

# patch/reset config ###
[ ! -f $config ] || {
  ! grep -q '=20200260$' $config \
    || sed -i 's/=20200260$/=202002260/' $config # bugfix
  configVer=$(get_prop configVerCode $config 2>/dev/null || :)
  dConfVer=$(get_prop configVerCode $installDir/default-config.txt)
  if [ ${configVer:-0} -gt $dConfVer ] || [ ${configVer:-0} -lt 202002220 ]; then
    rm $config /sdcard/${id}-logs-*.tar.bz2 2>/dev/null || :
  fi
  unset dConfVer
}

# flashable uninstaller
cp -f $srcDir/bin/${id}-uninstaller.zip /data/media/0/

# set perms
set_perms_recursive ${config%/*}
chmod 666 /data/media/0/${id}-uninstaller.zip
case $installDir in
  /data/*/files/$id)
    pkg=${installDir%/files/$id}
    pkg=${pkg##/data*/}
    owner=$(grep $pkg /data/system/packages.list | cut -d ' ' -f 2)
    set_perms_recursive ${installDir%/*} $owner
  ;;
  *)
    set_perms_recursive $installDir
  ;;
esac

set +euo pipefail 2>/dev/null || :


echo "- Done


"


# print links and changelog
sed -En "\|## LINKS|,\$p" ${config%/*}/info/README.md \
  | grep -v '^---' | sed 's/^## //'


###
echo "


(i) Rebooting is unnecessary.
- $id can be used right now.
- $id daemon started."


[ $installDir == /data/adb ] && echo -e "\n(i) Use init.d or an app to run $installDir/${id}-init.sh on boot to initialize ${id}."

echo
trap - EXIT

# initialize $id
if [ -f $installDir/service.sh ]; then
  $installDir/service.sh --override
else
  $installDir/${id}-init.sh --override
fi

e=$?
[ $e -eq 0 ] || { echo; exit $e; }
rm /sbin/.$id/.ghost-charging 2>/dev/null ###
/sbin/acca --daemon > /dev/null || /sbin/accd ### workaround, Magisk 20.4+
exit 0
