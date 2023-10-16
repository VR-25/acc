#!/system/bin/sh
# $id Installer/Upgrader
# Copyright 2019-2023, VR25
# License: GPLv3+
#
# devs: triple hashtags (###) mark non-generic code


# override the official Magisk module installer
SKIPUNZIP=1


echo
id=acc
domain=vr25
data_dir=/data/adb/$domain/${id}-data


# log
[ -z "${LINENO-}" ] || export PS4='$LINENO: '
mkdir -p $data_dir/logs
exec 2>$data_dir/logs/install.log
set -x


exxit() {
  local e=$?
  set +eu
  rm -rf /dev/.$domain.${id}-install
  $KSU || {
    rm -rf /data/adb/modules_update/$id
   (abort) > /dev/null
  }
  echo
  exit $e
} 2>/dev/null

trap exxit EXIT


# set up busybox
#BB#
bin_dir=/data/adb/vr25/bin
busybox_dir=/dev/.vr25/busybox
magisk_busybox="/data/adb/ksu/bin/busybox /data/adb/magisk/busybox"
[ -x $busybox_dir/ls ] || {
  mkdir -p $busybox_dir
  chmod 0755 $busybox_dir $bin_dir/busybox 2>/dev/null || :
  for f in $bin_dir/busybox $magisk_busybox /system/*bin/busybox*; do
    [ ! -f $f ] || {
      $f --install -s $busybox_dir/
      break
    }
  done
  [ -x $busybox_dir/ls ] || {
    echo "Install busybox or simply place it in $bin_dir/"
    echo
    exit 3
  }
}
case $PATH in
  $bin_dir:*) ;;
  *) export PATH="$bin_dir:$busybox_dir:$PATH";;
esac
unset f bin_dir busybox_dir magisk_busybox
#/BB#


# root check
[ $(id -u) -ne 0 ] && {
  echo "$0 must run as root (su)"
  exit 4
}


get_prop() { sed -n "s|^$1=||p" ${2:-$srcDir/module.prop}; }

set_perms() {
  local owner=${2:-0}
  local perms=0644
  local target=
  target=$(readlink -f $1)
  if echo $target | grep -q '.*\.sh$' || [ -d $target ]; then perms=0755; fi
  chmod $perms $target
  chown $owner:$owner $target
  chcon u:object_r:system_file:s0 $target 2>/dev/null || :
}

set_perms_recursive() {
  local owner=${2-0}
  local target=
  find $1 2>/dev/null | while read target; do set_perms $target $owner; done
}

set -eu


# set source code directory
srcDir="$(cd "${0%/*}" 2>/dev/null || :; echo "$PWD")"

# extract flashable zip if source code is unavailable
[ -d $srcDir/install ] || {
  srcDir=/dev/.$domain.${id}-install
  rm -rf $srcDir 2>/dev/null || :
  mkdir $srcDir
  unzip "${APK:-${ZIPFILE:-$3}}" -d $srcDir/ >&2
}


name=$(get_prop name)
author=$(get_prop author)
version=$(get_prop version)
magiskModDir=/data/adb/modules
versionCode=$(get_prop versionCode)
accaFiles=/data/data/mattecarra.accapp/files ###
: ${installDir:=$accaFiles} ###
config=$data_dir/config.txt


# install in front-end's internal path by default
if [ "$installDir" != "$accaFiles" ]; then
  case "$installDir" in
    /data/data/*|/data/user/*)
      accaFiles="$installDir"
    ;;
  esac
fi


[ -d $magiskModDir ] && magisk=true || magisk=false
ls -d ${accaFiles%/*}* > /dev/null 2>&1 && acca=true || acca=false ###


# ensure AccA's files/ exists - to prevent unwanted downgrades ###
if $acca && [ ! -d $accaFiles ]; then
  if mkdir $accaFiles 2>/dev/null; then
    chown $(stat -c %u:%g ${accaFiles%/*}) $accaFiles
    chmod $(stat -c %a ${accaFiles%/*}) $accaFiles
    /system/bin/restorecon $accaFiles
  fi
fi


# check/change parent installation directory
! $magisk || installDir=$magiskModDir
[ $installDir != /data/adb/$domain ] || mkdir -p $installDir
[ -d $installDir ] || {
  installDir=/data/adb/$domain
  mkdir -p $installDir
}


###
echo "$name $version ($versionCode)
Copyright 2017-2023, $author
GPLv3+

Installing in $installDir/$id/..."


# backup
rm -rf $data_dir/backup 2>/dev/null || :
mkdir -p $data_dir/backup
cp -aH /data/adb/$domain/$id/* $config $data_dir/backup/ 2>/dev/null || :


/system/bin/sh $srcDir/install/uninstall.sh install
KSU=${KSU:-false}
$KSU || { [ ! -f /data/adb/ksu/bin/busybox ] || KSU=true; }
cp -R $srcDir/install/ $installDir/$id
installDir=$(readlink -f $installDir/$id)
cp $srcDir/module.prop $installDir/
cp -f $srcDir/README.* $data_dir/


# KaiOS patches
[ ! -d /data/usbmsc_mnt/ ] || {
  for i in $installDir/$id/*.sh; do
    sed -Ei 's#/sdcard(/|/Download/)#/data/usbmsc_mnt/#g' $i
  done
}


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

    ln -fs $installDir $accaFiles/

    # AccA post-uninstall cleanup script
    mkdir -p /data/adb/service.d || {
      rm /data/adb/service.d
      mkdir /data/adb/service.d
    }
    echo "#!/system/bin/sh
      # acc front-end post-uninstall cleanup script

      until test -d /sdcard/Android \\
        && test .\$(getprop sys.boot_completed) = .1
      do
        sleep 60
      done

      sleep 60

      [ -e $accaFiles/$id ] || rm -rf \$0 /data/adb/$domain/$id /data/adb/modules/$id 2>/dev/null

      exit 0" | sed 's/^      //' > /data/adb/service.d/${id}-cleanup.sh
    chmod 0755 /data/adb/service.d/${id}-cleanup.sh
  }
fi


[ $installDir = /data/adb/$domain/$id ] || {
  mkdir -p /data/adb/$domain
  ln -s $installDir /data/adb/$domain/
}


# install binaries
cp -f $srcDir/bin/${id}_flashable_uninstaller.zip $data_dir/


# Termux, fix shebang
termux=false
case "$installDir" in
  */com.termux*)
    termux=true
    for f in $installDir/*.sh; do
      ! grep -q '^#\!/.*/sh' $f \
        || sed -i 's|^#!/.*/sh|#!/data/data/com.termux/files/usr/bin/bash|' $f
    done
  ;;
esac


# set perms
case $installDir in
  /data/data/*|/data/user/*)
    set_perms_recursive $installDir $(stat -c %u ${installDir%/$id})

    # Termux:Boot
    ! $termux || {
      mkdir -p ${installDir%/*}/.termux/boot
      ln -sf $installDir/service.sh ${installDir%/*}/.termux/boot/${id}-init.sh
      chown -R $(stat -c %u:%g /data/data/com.termux) ${installDir%/*}/.termux
      /system/bin/restorecon -R ${installDir%/*}/.termux > /dev/null 2>&1 || :
    }
  ;;
  *)
    set_perms_recursive $installDir
  ;;
esac


! $KSU || {
  upModDir=${magiskModDir}_update
  rm -rf $upModDir/$id 2>/dev/null || :
  cp -a $installDir $upModDir
  touch $installDir/update
}


set +eu
printf "- Done\n\n\n"


# print links and changelog
sed -En "\|^## LINKS|,\$p" $srcDir/README.md \
  | grep -v '^---' | sed 's/^## //'

printf "\n\nCHANGELOG\n\n"
cat $srcDir/changelog.md


printf "\n\n"
which accd. >/dev/null && echo "Rebooting is unnecessary." \
  || echo "- $id commands require the "/dev/" prefix (e.g., /dev/$id -v) until system is rebooted."
echo "- Daemon started."


case $installDir in
  /data/adb/modules*) ;;
  *) $KSU || echo "
Non-Magisk users can enable $id auto-start by running /data/adb/$domain/$id/service.sh, a copy of, or a link to it - with init.d or an app that emulates it.";;
esac

#legacy
f=$data_dir/logs/ps-blacklist.log
[ -f $f ] || mv $data_dir/logs/psl-blacklist.txt $f 2>/dev/null
rm $data_dir/${id}-uninstaller.zip $data_dir/logs/*.tar.gz $data_dir/curr 2>/dev/null

# initialize $id
/data/adb/$domain/$id/service.sh --init
exit 0
