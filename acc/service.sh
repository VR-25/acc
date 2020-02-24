#!/system/bin/sh
# Advanced Charging Controller (ACC) Initializer
# Copyright (c) 2017-2020, VR25 (xda-developers)
# License: GPLv3+
#
# devs: triple hashtags (###) mark custom code

(set +x
id=acc
umask 077

# prevent running more than once per boot session
[ -d /sbin/.$id ] && [[ ${1:-x} != -*o* ]] && exit 0

# bootloop lock file
[ -f /data/adb/${id}-data/logs/.bootlooped ] && exit 0
touch /data/adb/${id}-data/logs/.bootlooped

# log
mkdir -p /data/adb/${id}-data/logs
exec > /data/adb/${id}-data/logs/init.log 2>&1
set -x

# set up  working directory and busybox
[ -f $PWD/${0##*/} ] && modPath=$PWD || modPath=${0%/*}
. $modPath/setup-busybox.sh

# prepare executables
if ! mount -o remount,rw /sbin 2>/dev/null; then
  cp -a /sbin /dev/.sbin
  mount -o bind,rw /dev/.sbin /sbin
  restorecon -R /sbin > /dev/null 2>&1
fi
mkdir -p /sbin/.$id
###
ln -fs $modPath /sbin/.$id/$id
ln -fs /sbin/.$id/$id/${id}.sh /sbin/$id
ln -fs /sbin/.$id/$id/${id}.sh /sbin/${id}d,
ln -fs /sbin/.$id/$id/${id}.sh /sbin/${id}d.
ln -fs /sbin/.$id/$id/${id}.sh /sbin/.${id}-en
ln -fs /sbin/.$id/$id/start-${id}d.sh /sbin/${id}d

# generate power supply log ###
(set +x
. $modPath/power-supply-logger.sh $(sed -n s/versionCode=//p $modPath/module.prop) &) &

# fix Termux's PATH (missing /sbin)
termuxSu=/data/data/com.termux/files/usr/bin/su
if [ -f $termuxSu ] && grep -q 'PATH=.*/sbin/su' $termuxSu; then
  sed '\|PATH=|s|/sbin/su|/sbin|' $termuxSu > ${termuxSu}.tmp
  cat ${termuxSu}.tmp > $termuxSu # preserves attributes
  rm ${termuxSu}.tmp
fi


# filter out missing and problematic charging switches (those with unrecognized values) ###
(cd /sys/class/power_supply/
: > /sbin/.$id/charging-switches
grep -Ev '^#|^$' $modPath/charging-switches.txt | \
  while read -A chargingSwitch; do
    ctrlFile1="$(echo ${chargingSwitch[0]} | cut -d ' ' -f 1)"
    ctrlFile2="$(echo ${chargingSwitch[3]} | cut -d ' ' -f 1)"
    if [ -f "$ctrlFile1" ]; then
      if  [[ -f "$ctrlFile2" || -z "$ctrlFile2" ]]; then
        chmod +r $ctrlFile1 || continue
        if grep -Eq "^(${chargingSwitch[1]//::/ }|${chargingSwitch[2]//::/ })$" $ctrlFile1 \
          || ! cat $ctrlFile1 > /dev/null || [ -z "$(cat $ctrlFile1)" ]
        then
          echo "$ctrlFile1 ${chargingSwitch[1]} ${chargingSwitch[2]} $ctrlFile2 ${chargingSwitch[4]} ${chargingSwitch[5]}" >> /sbin/.$id/charging-switches
        fi 2>/dev/null
      fi
    fi
  done

# read charging voltage control files ###
: > /sbin/.$id/ch-volt-ctrl-files
ls -1 */BatterySenseVoltage */ISenseVoltage */batt_vol */InstatVolt \
  */constant_charge_voltage* */voltage_max */batt_tune_float_voltage 2>/dev/null | \
    while read file; do
      chmod +r $file && grep -Eq '^4[1-4][0-9]{2}' $file || continue
      echo ${file}::$(sed -n 's/^..../vvvv/p' $file)::$(cat $file) \
        >> /sbin/.$id/ch-volt-ctrl-files
    done

# read charging current control files (part 1) ###
# part 2 is handled by accd - while charging only
: > /sbin/.$id/ch-curr-ctrl-files
ls -1 */input_current_limited */restrict*_ch*g* \
  /sys/class/qcom-battery/restrict*_ch*g* | \
    while read file; do
      chmod +r $file || continue
      if grep -q '^0$' $file; then
        echo ${file}::1::0 >> /sbin/.$id/ch-curr-ctrl-files
      fi
   done)


# remove bootloop lock file and kill potentially stuck processes ###
(set +x
sleep 15
rm /data/adb/${id}-data/logs/.bootlooped
pkill -9 -f $0 &) 2>/dev/null &

# start $id daemon
$modPath/${id}d.sh &) &

exit 0
