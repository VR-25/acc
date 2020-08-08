#!/system/bin/sh
# ACC Installer/Upgrader
# Copyright 2019-2020, VR25
# License: GPLv3+
#
# devs: triple hashtags (###) mark non-generic code


# override the official Magisk module installer
SKIPUNZIP=1


echo
id=acc
umask 0077


# log
[ -z "${LINENO-}" ] || export PS4='$LINENO: '
mkdir -p /data/adb/${id}-data/logs
chmod -R 0700 /data/adb/${id}-data/logs
exec 2>/data/adb/${id}-data/logs/install.log
set -x


exxit() {
  local e=$?
  set +eu
  rm -rf /dev/.${id}-install /data/adb/modules_update/$id
  (abort) > /dev/null
  echo
  exit $e
} 2>/dev/null

trap exxit EXIT


# set up busybox
#BB#
[ -x /dev/.busybox/ls ] || {
  mkdir -p /dev/.busybox
  chmod 0700 /dev/.busybox
  if [ -f /data/adb/bin/busybox ]; then
    [ -x /data/adb/bin/busybox ] || chmod -R 0700 /data/adb/bin
    /data/adb/bin/busybox --install -s /dev/.busybox
  elif [ -f /data/adb/magisk/busybox ]; then
    [ -x /data/adb/magisk/busybox ] || chmod 0700 /data/adb/magisk/busybox
    /data/adb/magisk/busybox --install -s /dev/.busybox
  elif which busybox > /dev/null; then
    eval "$(which busybox) --install -s /dev/.busybox"
  else
    echo "(!) Install busybox or simply place it in /data/adb/bin/"
    exit 3
  fi
}
case $PATH in
  /data/adb/bin:*) :;;
  *) export PATH=/data/adb/bin:/dev/.busybox:$PATH;;
esac
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
  chcon u:object_r:system_file:s0 $target
}

set_perms_recursive() {
  local owner=${2-0} target=""
  find $1 2>/dev/null | while read target; do set_perms $target $owner; done
}

set -eu


# set source code directory
[ -f $PWD/${0##*/} ] && srcDir=$PWD || srcDir=${0%/*}
srcDir=${srcDir/#"${0##*/}"/"."}


# extract flashable zip if source code is unavailable
[ -f $srcDir/module.prop ] || {
  srcDir=/dev/.${id}-install
  rm -rf $srcDir 2>/dev/null || :
  mkdir $srcDir
  unzip "${3:-${ZIPFILE}}" -d $srcDir/ >&2
}


name=$(get_prop name)
author=$(get_prop author)
version=$(get_prop version)
userDir=/sdcard/Download/$id
magiskModDir=/data/adb/modules
versionCode=$(get_prop versionCode)
: ${installDir:=/data/data/mattecarra.${id}app/files} ###
config=/data/adb/${id}-data/config.txt


[ -d $magiskModDir ] && magisk=true || magisk=false
ls -d /data/app/mattecarra.${id}app* > /dev/null 2>&1 && acca=true || acca=false ###


# ensure AccA's files/ exists - to prevent unwanted ACC downgrades ###
if $acca && [ ! -d /data/data/mattecarra.${id}app/files ]; then
  mkdir -p /data/data/mattecarra.${id}app/files
  chmod 0777 /data/data/mattecarra.${id}app \
    /data/data/mattecarra.${id}app/files
fi


# check/change parent installation directory

! $magisk || installDir=$magiskModDir

[ -d $installDir ] || installDir=/data/adb

[ -d $installDir ] || {
  printf "(!) $installDir/ not found\n"
  exit 1
}


###
echo "$name $version ($versionCode)
Copyright 2017-2020, $author
GPLv3+

(i) Installing in $installDir/$id/..."


/system/bin/sh $srcDir/$id/uninstall.sh install
cp -R $srcDir/$id/ $installDir/
installDir=$(readlink -f $installDir/$id)
cp $srcDir/module.prop $installDir/
mkdir -p $userDir
cp -f $srcDir/README.md $userDir/


###
! $magisk || {
  # symlink executables
  mkdir -p $installDir/system/bin
  ln -fs $installDir/${id}.sh $installDir/system/bin/$id
  ln -fs $installDir/${id}.sh $installDir/system/bin/${id}d,
  ln -fs $installDir/${id}.sh $installDir/system/bin/${id}d.
  ln -fs $installDir/${id}a.sh $installDir/system/bin/${id}a
  ln -fs $installDir/service.sh $installDir/system/bin/${id}d
}


###
if $acca; then

  ! $magisk || {

    ln -fs $installDir /data/data/mattecarra.${id}app/files/

    # AccA post-uninstall cleanup script
    mkdir -p /data/adb/service.d || {
      rm /data/adb/service.d
      mkdir /data/adb/service.d
    }
    echo "#!/system/bin/sh
      # AccA post-uninstall cleanup script

      until test -d /sdcard/Download \\
        && test .\$(getprop sys.boot_completed) = .1
      do
        sleep 60
      done

      sleep 60

      [ -e /data/data/mattecarra.${id}app/files/$id ] || rm \$0 /data/adb/$id /data/adb/modules/$id 2>/dev/null

      exit 0" | sed 's/^      //' > /data/adb/service.d/${id}-cleanup.sh
    chmod 0700 /data/adb/service.d/${id}-cleanup.sh
  }
fi


[ $installDir = /data/adb/$id ] || ln -s $installDir /data/adb/


# restore config backup
[ -f $config ] || cp $userDir/.${id}-config-backup.txt $config 2>/dev/null || :


# install binaries
cp -f $srcDir/bin/${id}-uninstaller.zip $userDir/


# Termux, fix shebang
[[ $installDir != *com.termux* ]] && termux=false || {
  termux=true
  for f in $installDir/*.sh; do
    ! grep -q '^#\!/.*/sh' $f \
      || sed -i 's|^#!/.*/sh|#!/data/data/com.termux/files/usr/bin/bash|' $f
  done
}


# set perms
set_perms_recursive ${config%/*}
case $installDir in
  /data/*/files/*$id)
    pkg=${installDir%/files/*$id}
    pkg=${pkg##/data*/}
    owner=$(grep $pkg /data/system/packages.list | cut -d ' ' -f 2)
    set_perms_recursive $installDir $owner

    # Termux:Boot
    ! $termux || {
      mkdir -p ${installDir%/*}/.termux/boot
      ln -sf $installDir/service.sh ${installDir%/*}/.termux/boot/${id}-init.sh
      chown -R $(stat -c %u:%g /data/data/com.termux) ${installDir%/*}/.termux
      chmod -R 0755 ${installDir%/*}/.termux
      /system/bin/restorecon -R ${installDir%/*}/.termux > /dev/null 2>&1
    }
  ;;
  *)
    set_perms_recursive $installDir
  ;;
esac


set +eu


echo "- Done


"
# print links and changelog
sed -En "\|## LINKS|,\$p" $srcDir/README.md \
  | grep -v '^---' | sed 's/^## //'


###
echo "


(i) Rebooting is unnecessary
- $id commands may require the /dev/ prefix (e.g., /dev/$id) until system is rebooted.
- Daemon started."


[ $installDir = /data/adb ] && echo "
(i) Non-Magisk users can enable $id auto-start by running /data/adb/$id/service.sh, a copy of, or a link to it - with init.d or an app that emulates it."


# initialize $id
/data/adb/$id/service.sh --init

exit 0
