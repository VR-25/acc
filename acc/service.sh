#!/system/bin/sh
# Advanced Charging Controller (ACC) Initializer
# Copyright (c) 2017-2020, VR25 (xda-developers)
# License: GPLv3+
#
# devs: triple hashtags (###) mark custom code


(
  set +x
  id=acc
  umask 077
  TMPDIR=/sbin/.$id


  # prevent running more than once per boot session
  [ -d $TMPDIR ] && [ -z "$1" ] && exit 0


  # log
  mkdir -p /data/adb/${id}-data/logs
  exec > /data/adb/${id}-data/logs/init.log 2>&1
  set -x


  # bootloop lock file
  [ -f /data/adb/${id}-data/logs/bootlooped ] && exit 0
  touch /data/adb/${id}-data/logs/bootlooped


  # set up  working directory and busybox
  [ -f $PWD/${0##*/} ] && modPath=$PWD || modPath=${0%/*}
  . $modPath/setup-busybox.sh


  # generate power supply log ###
  (
    set +x
    . $modPath/power-supply-logger.sh $(sed -n s/versionCode=//p $modPath/module.prop) \
  &) &


  # prepare executables
  if ! mount -o remount,rw /sbin 2>/dev/null; then
    cp -a /sbin /dev/.sbin
    mount -o bind,rw /dev/.sbin /sbin
    restorecon -R /sbin > /dev/null 2>&1
  fi
  mkdir -p $TMPDIR
  ###
  ln -fs $modPath $TMPDIR/$id
  ln -fs $TMPDIR/$id/${id}.sh /sbin/$id
  ln -fs $TMPDIR/$id/${id}.sh /sbin/${id}d,
  ln -fs $TMPDIR/$id/${id}.sh /sbin/${id}d.
  ln -fs $TMPDIR/$id/${id}a.sh /sbin/${id}a
  ln -fs $TMPDIR/$id/start-${id}d.sh /sbin/${id}d


  # fix Termux's PATH (missing /sbin/)
  termuxSu=/data/data/com.termux/files/usr/bin/su
  if grep -q 'PATH=.*/sbin/su' $termuxSu 2>/dev/null; then
    sed '\|PATH=|s|/sbin/su|/sbin|' $termuxSu > ${termuxSu}.tmp
    cat ${termuxSu}.tmp > $termuxSu # preserves attributes
    rm ${termuxSu}.tmp
  fi


  # filter out missing and problematic charging switches (those with unrecognized values) ###
  cd /sys/class/power_supply/
  : > $TMPDIR/charging-switches
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
            echo "$ctrlFile1 ${chargingSwitch[1]} ${chargingSwitch[2]} $ctrlFile2 ${chargingSwitch[4]} ${chargingSwitch[5]}" >> $TMPDIR/charging-switches
          fi 2>/dev/null
        fi
      fi
    done


  # read charging voltage control files ###
  : > $TMPDIR/ch-volt-ctrl-files
  ls -1 */BatterySenseVoltage */ISenseVoltage */batt_vol */InstatVolt \
    */constant_charge_voltage* */voltage_max */batt_tune_float_voltage 2>/dev/null | \
      while read file; do
        chmod +r $file && grep -Eq '^4[1-4][0-9]{2}' $file || continue
        echo ${file}::$(sed -n 's/^..../vvvv/p' $file)::$(cat $file) \
          >> $TMPDIR/ch-volt-ctrl-files
      done


  # read charging current control files (part 1) ###
  # part 2 is handled by accd - while charging only
  : > $TMPDIR/ch-curr-ctrl-files
  ls -1 */input_current_limited */restrict*_ch*g* \
    /sys/class/qcom-battery/restrict*_ch*g* 2>/dev/null | \
      while read file; do
        chmod +r $file || continue
        if grep -q '^0$' $file; then
          echo ${file}::1::0 >> $TMPDIR/ch-curr-ctrl-files
        fi
      done

  ls -1 */constant_charge_current_max \
    */input_current_max */restrict*_cur* \
    /sys/class/qcom-battery/restrict*_cur* \
    */batt_tune_*_charge_current */ac_input \
    */mhl_2000_charge */mhl_2000_input \
    */hv_charge battery  */ac_charge \
    */batt_tune_chg_limit_cur */so_limit_input \
    */so_limit_charge */car_input */sdp_input \
    */aca_charge */sdp_charge */aca_input \
    *dcp_input */wc_input */car_charge \
    */dcp_charge */wc_charge 2>/dev/null | \
      while read file; do
        chmod +r $file || continue
        defaultValue=$(cat $file)
        if [ $defaultValue -lt 10000 -a $defaultValue -ne 0 ]; then
          # milliamps
          echo ${file}::v::$defaultValue \
            >> $TMPDIR/ch-curr-ctrl-files
        else
          # microamps
          echo ${file}::v000::$defaultValue \
            >> $TMPDIR/ch-curr-ctrl-files
       fi
     done


  # prepare default config help text and version code for write-config.sh
  sed -n '/^# /,$p' $modPath/default-config.txt > $TMPDIR/.default-config-help
  sed -n '/^configVerCode=/s/.*=//p' $modPath/default-config.txt > $TMPDIR/.default-config-ver


  # remove bootloop lock file and kill potentially stuck processes ###
  (
    set +x
    sleep 10
    rm /data/adb/${id}-data/logs/bootlooped
    pkill -9 -f $0 2>/dev/null \
  &) &

  # start $id daemon
  $modPath/${id}d.sh \
&) &

exit 0
