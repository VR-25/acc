#!/system/bin/sh
# ${1:-$id}*gz Installer
# Copyright (c) 2019, VR25 (xda-developers.com)
# License: GPLv3+

id=acc
umask 077

# log
mkdir -p /data/adb/${1:-$id}-data/logs
exec 2>/data/adb/${1:-$id}-data/logs/install-tarball.sh.log
set -x

# set up busybox
if [ -d /sbin/.magisk/busybox ]; then
  [[ $PATH == /sbin/.magisk/busybox* ]] || PATH=/sbin/.magisk/busybox:$PATH
elif [ -d /sbin/.core/busybox ]; then
  [[ $PATH == /sbin/.core/busybox* ]] || PATH=/sbin/.core/busybox:$PATH
else
  [[ $PATH == /dev/.busybox* ]] || PATH=/dev/.busybox:$PATH
  if ! mkdir -m 700 /dev/.busybox 2>/dev/null; then
    if [ -x /data/adb/magisk/busybox ]; then
      /data/adb/magisk/busybox --install -s /dev/.busybox
    elif which busybox > /dev/null; then
      busybox --install -s /dev/.busybox
    else
      echo "(!) Install busybox binary first"
      exit 3
    fi
  fi
fi

# root check
if [ $(id -u) -ne 0 ]; then
  echo "(!) $0 must run as root (su)"
  exit 4
fi

umask 0
set -e

# get into the target directory
[ -f $PWD/${0##*/} ] || cd ${0%/*}
cd $(readlink -f $PWD)

# this runs on exit if the installer is launched by a front-end app
copy_log() {
  if [[ $PWD == /data/data/* ]]; then
    umask 077
    mkdir -p logs

    cp -af /data/adb/${1:-$id}-data/logs/install.log logs/${1:-$id}-install.log

    pkg=$(cd ..; pwd)
    pkg=${pkg##/data*/}

    owner=$(grep $pkg /data/system/packages.list | awk '{print $2}')
    chown -R $owner:$owner logs
  fi
}
trap copy_log EXIT

# extract tarball
rm -rf ${1:-$id}-*/ 2>/dev/null
tar -xf ${1:-$id}*gz

# install ${1:-$id}
export installDir0="$2"
sh ${1:-$id}-*/install-current.sh
rm -rf ${1:-$id}-*/

# set up alternate initializer (Magisk service.d)
if [[ $PWD == /data/data/* ]] && [ -d /data/adb/service.d ]; then
  cat << EOF > /data/adb/service.d/${1:-$id}-init.sh
#!/system/bin/sh
(until grep -q /storage/emulated /proc/mounts; do sleep 15; done
if [ -f $PWD/${1:-$id}/${1:-$id}-init.sh ]; then
  $PWD/${1:-$id}/${1:-$id}-init.sh
else
  rm \$0
fi
exit 0 &) &
exit 0
EOF
  chmod 0700 /data/adb/service.d/${1:-$id}-init.sh
fi

exit 0
