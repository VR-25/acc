#!/system/bin/sh
# Advanced Charging Controller (acc) Initializer
# Copyright (c) 2017-2019, VR25 (xda-developers)
# License: GPLv3+

set +x
id=acc
umask 077

# log
mkdir -p /data/adb/${id}-data/logs
exec > /data/adb/${id}-data/logs/init.log 2>&1
set -x

[ -f $PWD/${0##*/} ] && modPath=$PWD || modPath=${0%/*}
. $modPath/busybox.sh

# prepare working directory
([ -d /sbin/.$id ] && [[ ${1:-x} != -*o* ]] && exit 0
if ! mount -o remount,rw /sbin 2>/dev/null; then
  cp -a /sbin /dev/.sbin
  mount -o bind,rw /dev/.sbin /sbin
  restorecon -R /sbin > /dev/null 2>&1
fi
mkdir -p /sbin/.$id
[ -h /sbin/.$id/$id ] && rm /sbin/.$id/$id \
  || rm -rf /sbin/.$id/$id 2>/dev/null
[ ${MAGISK_VER_CODE:-18200} -gt 18100 ] \
  && ln -s $modPath /sbin/.$id/$id \
  || cp -a $modPath /sbin/.$id/$id
ln -fs /sbin/.$id/$id/$id.sh /sbin/$id
ln -fs /sbin/.$id/$id/$id.sh /sbin/${id}-en
ln -fs /sbin/.$id/$id/${id}d-start.sh /sbin/${id}d
ln -fs /sbin/.$id/$id/${id}d-status.sh /sbin/${id}d,
ln -fs /sbin/.$id/$id/${id}d-stop.sh /sbin/${id}d.

# generate power supply log
(. $modPath/psl.sh $(sed -n s/versionCode=//p $modPath/module.prop) &) &

# fix termux's PATH
termuxSu=/data/data/com.termux/files/usr/bin/su
if [ -f $termuxSu ] && grep -q 'PATH=.*/sbin/su' $termuxSu; then
  sed '\|PATH=|s|/sbin/su|/sbin|' $termuxSu > $termuxSu.tmp
  cat $termuxSu.tmp > $termuxSu
  rm $termuxSu.tmp
fi

# exclude charging switches with odd values
(cd /sys/class/power_supply/
: > /sbin/.$id/switches
while IFS= read -r file; do
  if [ -f $(echo $file | awk '{print $1}') ]; then
    on=$(echo $file | awk '{print $2}')
    off=$(echo $file | awk '{print $3}')
    file=$(echo $file | awk '{print $1}')
    chmod +r $file 2>/dev/null
    if grep -Eq "^($on|$off)$" $file || ! cat $file; then
      echo "$file $on $off" >> /sbin/.$id/switches
    fi > /dev/null 2>&1
  fi
done << EOF
$(grep -Ev '#|^$' $modPath/switches.txt)
EOF
)

# start ${id}d
(sleep 30
pkill -9 -f /psl.sh 2>/dev/null &) &
$modPath/${id}d.sh &) &

exit 0
