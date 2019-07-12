#!/system/bin/sh
# Advanced Charging Controller (acc) Initializer
# Copyright (c) 2017-2019, VR25 (xda-developers)
# License: GPLv3+


if ! which busybox > /dev/null; then
  if [ -d /sbin/.magisk/busybox ]; then
    PATH=/sbin/.magisk/busybox:$PATH
  elif [ -d /sbin/.core/busybox ]; then
    PATH=/sbin/.core/busybox:$PATH
  else
    exit 3
  fi
fi

[ -f $PWD/${0##*/} ] && modPath=$PWD || modPath=${0%/*}
modId=$(sed -n 's/^id=//p' $modPath/module.prop)

# prepare working directory
([ -d /sbin/.$modId ] && [[ ${1:-x} != -*o* ]] && exit 0
if ! mount -o remount,rw /sbin 2>/dev/null; then
  cp -a /sbin /dev/.sbin
  mount -o bind,rw /dev/.sbin /sbin
fi
mkdir -p /sbin/.$modId
[ -h /sbin/.$modId/$modId ] && rm /sbin/.$modId/$modId \
  || rm -rf /sbin/.$modId/$modId 2>/dev/null
[ ${MAGISK_VER_CODE:-18200} -gt 18100 ] \
  && ln -s $modPath /sbin/.$modId/$modId \
  || cp -a $modPath /sbin/.$modId/$modId
ln -fs /sbin/.$modId/$modId/$modId.sh /sbin/$modId
ln -fs /sbin/.$modId/$modId/${modId}d-start.sh /sbin/${modId}d
ln -fs /sbin/.$modId/$modId/${modId}d-status.sh /sbin/${modId}d,
ln -fs /sbin/.$modId/$modId/${modId}d-stop.sh /sbin/${modId}d.

# generate power supply log
$modPath/psl.sh $(sed -n s/versionCode=//p $modPath/module.prop) &

# fix termux's PATH
termuxSu=/data/data/com.termux/files/usr/bin/su
if [ -f $termuxSu ] && grep -q 'PATH=.*/sbin/su' $termuxSu; then
  sed '\|PATH=|s|/sbin/su|/sbin|' $termuxSu > $termuxSu.tmp
  cat $termuxSu.tmp > $termuxSu
  rm $termuxSu.tmp
fi

# exclude charging switches with unknown values
(cd /sys/class/power_supply/
: > /sbin/.$modId/switches
while IFS= read -r file; do
  if [ -f $(echo $file | awk '{print $1}') ]; then
    on=$(echo $file | awk '{print $2}')
    off=$(echo $file | awk '{print $3}')
    file=$(echo $file | awk '{print $1}')
    chmod +r $file 2>/dev/null
    if grep -Eq "^($on|$off)$" $file || ! cat $file; then
      echo "$file $on $off" >> /sbin/.$modId/switches
    fi > /dev/null 2>&1
  fi
done << SWITCHES
$(grep -Ev '#|^$' $modPath/switches.txt)
SWITCHES
)

# start ${modId}d
sleep 30
unset file termuxSu
kill -9 $(pgrep -f /psl.sh) 2>/dev/null
$modPath/${modId}d.sh &) &

exit 0
