#!/system/bin/sh
# ACC Installer/Upgrader
# Copyright (c) 2019-2020, VR25 (xda-developers)
# License: GPLv3+
#
# devs: triple hashtags (###) mark custom code


# override the official Magisk module installer
SKIPUNZIP=1


echo
id=acc
umask 0077


# log
mkdir -p /data/adb/${id}-data/logs
chmod -R 0700 /data/adb/${id}-data/logs
exec 2>/data/adb/${id}-data/logs/install.log
set -x


exxit() {
  local e=$?
  set +eo pipefail
  rm -rf /dev/.${id}-install
  [ $e -ne 0 ] && echo || { ###
    rm /sbin/.$id/.ghost-charging
    /sbin/acca --daemon > /dev/null || /sbin/accd || {
      pkill -9 -f $installDir/service.sh
      $installDir/service.sh --override
      rm /sbin/.$id/.ghost-charging
      /sbin/acca --daemon > /dev/null || /sbin/accd
    } || e=12
  }
  exit $e
} 2>/dev/null

trap exxit EXIT


# set up busybox
#BB#
if [ -d /sbin/.magisk/busybox ]; then
  case $PATH in
    /sbin/.magisk/busybox:*) :;;
    *) PATH=/sbin/.magisk/busybox:$PATH;;
  esac
else
  mkdir -p /dev/.busybox
  chmod 0700 /dev/.busybox
  case $PATH in
    /dev/.busybox:*) :;;
    *) PATH=/dev/.busybox:$PATH;;
  esac
  [ -x /dev/.busybox/busybox ] || {
    if [ -f /data/adb/magisk/busybox ]; then
      [ -x /data/adb/magisk/busybox ] || chmod 0700 /data/adb/magisk/busybox
      /data/adb/magisk/busybox --install -s /dev/.busybox
    elif which busybox > /dev/null; then
      busybox --install -s /dev/.busybox
    elif [ -f /data/adb/busybox ]; then
      [ -x /data/adb/busybox ] || chmod 0700 /data/adb/busybox
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
  local owner=${2:-0} perms=0600 target=$(readlink -f $1)
  if echo $target | grep -q '.*\.sh$' || [ -d $target ]; then perms=0700; fi
  chmod $perms $target
  chown $owner:$owner $target
  restorecon $target > /dev/null 2>&1 || :
}

set_perms_recursive() {
  local owner=${2-0} target=""
  find $1 2>/dev/null | while read target; do set_perms $target $owner; done
}

set -euo pipefail 2>/dev/null || :


# set source code directory
[ -f $PWD/${0##*/} ] && srcDir=$PWD || srcDir=${0%/*}
srcDir=${srcDir/#"${0##*/}"/"."}


# extract flashable zip if source code is unavailable
[ -f $srcDir/module.prop ] || {
  srcDir=/dev/.${id}-install
  rm -rf $srcDir 2>/dev/null || :
  mkdir $srcDir
  unzip "$3" -d $srcDir/ >&2
}


name=$(get_prop name)
author=$(get_prop author)
version=$(get_prop version)
magiskModDir=/sbin/.magisk/modules
versionCode=$(get_prop versionCode)
: ${installDir:=/data/data/mattecarra.${id}app/files} ###
config=/data/adb/${id}-data/config.txt

[ -d  $magiskModDir ] && magisk=true || magisk=false


# check/set parent installation directory

[ -d $installDir ] || installDir=$magiskModDir
[ -d $installDir ] || installDir=/data/adb

[ -d $installDir ] || {
  echo "(!) /data/adb/ not found\n"
  exit 1
}


###
echo "$name $version ($versionCode)
© 2017-2020, $author
GPLv3+

(i) Installing in $installDir/$id/..."


ash $srcDir/$id/uninstall.sh install
rm /data/adb/${id}-data/logs/bootlooped 2>/dev/null || :
cp -R $srcDir/$id/ $installDir/
installDir=$(readlink -f $installDir/$id)
cp $srcDir/module.prop $installDir/
mkdir -p ${config%/*}/info
cp -f $srcDir/*.md ${config%/*}/info


case $installDir in
  /data/*/files/*$id)
    ! $magisk || {
      cp -R $installDir $magiskModDir/

# front-end post-uninstall cleanup script
echo "#!/system/bin/sh
# $id front-end post-uninstall cleanup script

(until [ -d /sdcard/?ndroid -a .\$(getprop sys.boot_completed) == .1 ]; do sleep 60; done
sleep 60
[ -f $installDir/module.prop ] || {
$(grep -Ev '#|^$' $installDir/uninstall.sh | sed 's/^/  /')
} &) > /dev/null 2>&1 &
exit 0"  > /data/adb/service.d/${id}-cleanup.sh

      chmod 0700 /data/adb/service.d/${id}-cleanup.sh
    }
    ln $installDir/service.sh $installDir/${id}-init.sh

    # TODO
    # upgrade bundled version
    #cp -f $srcDir/install-tarball.sh ${installDir%/*}/
    #tar -cvf - . -C $srcDir --exclude .git | gzip -9 > ${installDir%/*}/acc_bundle.tar.gz
  ;;
esac


[ $installDir == /data/adb/$id ] || {

  ln -s $installDir /data/adb/

  ! $magisk || {
    # workaround for Magisk "forgetting service.sh" issue
    ln $magiskModDir/$id/service.sh $magiskModDir/$id/post-fs-data.sh

    # disable magic mount (Magisk)
    touch $magiskModDir/$id/skip_mount
  }
}


# restore config backup
[ -f $config ] || cp /data/media/0/.${id}-config-backup.txt $config 2>/dev/null || :


# flashable uninstaller
cp -f $srcDir/bin/${id}-uninstaller.zip /data/media/0/


# Termux, fix sha-bang
[[ $installDir != *com.termux* ]] && termux=false || {
  termux=true
  for f in $installDir/*.sh; do
    ! grep -q '^#\!/.*/sh' $f \
      || sed -i 's|^#!/.*/sh|#!/data/data/com.termux/files/usr/bin/bash|' $f
  done
}


# set perms
set_perms_recursive ${config%/*}
chmod 0666 /data/media/0/${id}-uninstaller.zip
case $installDir in
  /data/*/files/*$id)
    pkg=${installDir%/files/*$id}
    pkg=${pkg##/data*/}
    owner=$(grep $pkg /data/system/packages.list | cut -d ' ' -f 2)
    set_perms_recursive $installDir $owner
    ! $magisk || set_perms_recursive $magiskModDir/$id

    # Termux:Boot
    ! $termux || {
      mkdir -p ${installDir%/*}/.termux/boot
      ln -sf $installDir/${id}-init.sh ${installDir%/*}/.termux/boot
      set_perms_recursive ${installDir%/*}/.termux $owner
    }
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

# initialize $id
$installDir/service.sh --override

exit 0
