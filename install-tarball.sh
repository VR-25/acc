#!/system/bin/sh
# ${1:-$id}[-_]*.tar.gz Installer
# Copyright 2019-2020, VR25 (xda-developers.com)
# License: GPLv3+

id=acc
domain=vr25
umask 0077
data_dir=/data/adb/$domain/${1:-$id}-data

# log
[ -z "${LINENO-}" ] || export PS4='$LINENO: '
mkdir -p $data_dir/logs
exec 2>$data_dir/logs/install-tarball.sh.log
set -x

# set up busybox
#BB#
[ -x /dev/.vr25/busybox/ls ] || {
  mkdir -p /dev/.vr25/busybox
  chmod 0700 /dev/.vr25/busybox
  if [ -f /data/adb/vr25/bin/busybox ]; then
    [ -x /data/adb/vr25/bin/busybox ] || chmod -R 0700 /data/adb/vr25/bin
    /data/adb/vr25/bin/busybox --install -s /dev/.vr25/busybox
  elif [ -f /data/adb/magisk/busybox ]; then
    [ -x /data/adb/magisk/busybox ] || chmod 0700 /data/adb/magisk/busybox
    /data/adb/magisk/busybox --install -s /dev/.vr25/busybox
  elif which busybox > /dev/null; then
    eval "$(which busybox) --install -s /dev/.vr25/busybox"
  else
    echo "(!) Install busybox or simply place it in /data/adb/vr25/bin/"
    exit 3
  fi
}
case $PATH in
  /data/adb/vr25/bin:*) :;;
  *) export PATH=/data/adb/vr25/bin:/dev/.vr25/busybox:$PATH;;
esac
#/BB#

# root check
[ $(id -u) -ne 0 ] && {
  echo "(!) $0 must run as root (su)"
  exit 4
}

umask 0000
set -e

# get into the target directory
[ -f $PWD/${0##*/} ] || cd $(readlink -f ${0%/*})

# this runs on exit if the installer is launched by a front-end app
copy_log() {
  rm -rf ${1-$id}[-_]*/ 2>/dev/null
  [[ $PWD != /data/data/* ]] || {
    umask 077
    mkdir -p logs

    cp -af $data_dir/logs/install.log logs/${1:-$id}-install.log 2>/dev/null || return 0

    pkg=$(cd ..; pwd)
    pkg=${pkg##/data*/}

    owner=$(grep $pkg /data/system/packages.list | cut -d ' ' -f 2)
    chown -R $owner:$owner logs
  }
}
trap copy_log EXIT

# extract tarball
rm -rf ${1:-$id}[-_]*/ 2>/dev/null
tar -xf ${1:-$id}[-_]*.tar.gz

# prevent AccA from downgrading/reinstalling modules ###
case "$PWD" in
  *mattecarra.accapp*)
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
test -f ${1:-$id}[-_]*/install.sh || i=-current #legacy
export installDir="$2"
/system/bin/sh ${1:-$id}[-_]*/install${i}.sh

exit 0
