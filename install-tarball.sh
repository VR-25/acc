#!/system/bin/sh
# ${1:-$id} Tarball Installer
# Copyright 2019-2022, VR25
# License: GPLv3+
#
# this file must be in the same directory as the tarball
# $1: module id
# $2: parent install dir, optional
# example: sh install-tarball.sh acc /data/data/github.vr25.acc/files

id=acc
domain=vr25
data_dir=/data/adb/$domain/${1:-$id}-data

# log
[ -z "${LINENO-}" ] || export PS4='$LINENO: '
mkdir -p $data_dir/logs
exec 2>$data_dir/logs/install-tarball.sh.log
set -x

# set up busybox
#BB#
bin_dir=/data/adb/vr25/bin
busybox_dir=/dev/.vr25/busybox
magisk_busybox=/data/adb/magisk/busybox
[ -x $busybox_dir/ls ] || {
  mkdir -p $busybox_dir
  chmod 0700 $busybox_dir
  for f in $bin_dir/busybox $magisk_busybox /system/*bin/busybox*; do
    [ -f $f ] && {
      [ -x $f ] || chmod 0755 $f 2>/dev/null
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

set -e

# get into the target directory
[ -f $PWD/${0##*/} ] || cd $(readlink -f ${0%/*})

# this runs on exit if the installer is launched by a front-end app
copy_log() {
  rm -rf ${1-$id}[-_]*/ 2>/dev/null
  case "$PWD" in
    /data/data/*|/data/user/*)
      mkdir -p logs
      cp -af $data_dir/logs/install.log logs/${1:-$id}-install.log 2>/dev/null || return 0
      chown -R $(stat -c %u:%g .) logs
      /system/bin/restorecon -R logs
    ;;
  esac
}
trap copy_log EXIT

# extract tarball
rm -rf ${1:-$id}[-_]*/ 2>/dev/null
test -f ${1:-$id}[-_]*.tar.gz && ext=tar.gz || ext=tgz
tar -xf ${1:-$id}[-_]*.$ext
unset ext

# prevent frontends from downgrading/reinstalling modules
case "$PWD" in
  /data/data/*|/data/user/*)
    get_ver() { sed -n '/^versionCode=/s/.*=//p' ${1}module.prop 2>/dev/null || echo 0; }
    bundled_ver=$(get_ver ${1:-$id}[-_]*/)
    regular_ver=$(get_ver /data/adb/$domain/${1:-$id}/)
    if [ $bundled_ver -le $regular_ver ] && [ $regular_ver -ne 0 ]; then
      ln -s $(readlink -f /data/adb/$domain/${1:-$id}) .
      exit 0
    fi 2>/dev/null || :
  ;;
esac

# install ${1:-$id}
export installDir="$2"
/system/bin/sh ${1:-$id}[-_]*/install.sh

exit 0
