#!/system/bin/sh
# Advanced Charging Controller Daemon (accd)
# Copyright (c) 2017-2019, VR25 (xda-developers.com)
# License: GPLv3+


exxit() {
  local exitCode=$?
  set +euxo pipefail
  trap - EXIT
  { dumpsys battery reset 2>/dev/null
  enable_charging
  (/sbin/acc --voltage -); } > /dev/null 2>&1
  [ -n "$1" ] && echo -e "$2" && exitCode=$1
  echo "***EXIT $exitCode***"
  [[ $exitCode == [12] ]] && (/sbin/acc --log --export > /dev/null 2>&1)
  exit $exitCode
}


get_value() { sed -n "s|^$1=||p" $config; }


is_charging() {

  local file="" value="" isCharging=false

  grep -Eiq 'dis|not' $batt/status || isCharging=true

  if $isCharging; then
    $coolDown || resetBsOnUnplug=true
    secondsUnplugged=0

    # applyOnPlug
    for file in $(get_value applyOnPlug); do
      value=${file##*:}
      file=${file%:*}
      [ -f $file ] && chmod +w $file && echo $value > $file || :
    done
    file=$(get_value maxChargingVoltage)
    if [[ "$file" == */* ]]; then
      value=${file##*:}
      file=${file%:*}
      value=$(sed "s/^..../$value/" $file)
      chmod +w $file && echo $value > $file || :
    fi

    # forceStatusAt100
    if ! $forcedStatusAt100 && [[ "$(get_value forceStatusAt100)" == [0-9]* ]] && [ $(cat $batt/capacity) -gt 99 ]; then
      dumpsys battery set level 100 2>/dev/null \
        && dumpsys battery set status $(get_value forceStatusAt100) 2>/dev/null \
        && { forcedStatusAt100=true; frozenBattSvc=true; } \
        || sleep $(get_value loopDelay | cut -d, -f1)
    fi

  else

    # revert forceStatusAt100
    if $frozenBattSvc; then
      dumpsys battery reset 2>/dev/null \
        && { frozenBattSvc=false; forcedStatusAt100=false; } \
        || sleep $(get_value loopDelay | cut -d, -f2)
    fi

    if ! $coolDown; then

      # resetBsOnUnplug
      if $resetBsOnUnplug && eval $(get_value resetBsOnUnplug); then
        sleep $(get_value loopDelay | cut -d, -f2)
        if grep -iq dis $batt/status; then
          dumpsys batterystats --reset 2>/dev/null || :
          rm /data/system/batterystats* 2>/dev/null || :
          resetBsOnUnplug=false
        fi
      fi

      # dynamic power saving
      if [ $secondsUnplugged == 0 ]; then
        [ $(( $(get_value capacity | cut -d, -f3 | cut -d- -f2) - $(get_value capacity | cut -d, -f3 | cut -d- -f1) )) -gt 4 ] \
          && hibernate=true || hibernate=false
      fi
      secondsUnplugged=$(( secondsUnplugged + $(get_value loopDelay | cut -d, -f2) ))
      ! $hibernate || sleep $secondsUnplugged
      [ $secondsUnplugged -lt 120 ] || secondsUnplugged=0
    else
      secondsUnplugged=0
    fi
  fi

  # correct the battery capacity reported by Android
  if eval $(get_value capacitySync); then
    dumpsys battery reset 2>/dev/null || :
    dumpsys battery set level $(cat $batt/capacity) 2>/dev/null || :
  fi > /dev/null 2>&1

  # log cleanup
  [ $(du -m $log | awk '{print $1}') -lt 2 ] || : > $log

  $isCharging && return 0 || return 1
}


disable_charging() {
  local file="" value=""
  if is_charging; then
    if [[ x$(get_value chargingSwitch) == */* ]]; then
      file=$(echo $(get_value chargingSwitch) | awk '{print $1}')
      value=$(get_value chargingSwitch | awk '{print $3}')
      if [ -f $file ]; then
        chmod +w $file && echo $value > $file 2>/dev/null && sleep $(get_value chargingOnOffDelay) \
          || (/sbin/acc --set chargingSwitch- > /dev/null)
      else
        (/sbin/acc --set chargingSwitch- > /dev/null)
      fi
    else
      ! eval $(get_value prioritizeBattIdleMode) || switch_loop off not
      ! is_charging || switch_loop off
    fi
    ! is_charging || echo "(!) Failed to disable charging"
  fi
  # if maxTemp is reached, pause charging regardless of coolDownRatio
  ! is_charging && [ $(( $(cat $batt/temp 2>/dev/null || cat $batt/batt_temp) / 10 )) -ge $(get_value temperature | cut -d- -f2 | cut -d_ -f1) ] \
    && sleep $(get_value temperature | cut -d- -f2 | cut -d_ -f2) || :
}


enable_charging() {
  local file="" value=""
  if ! is_charging; then
    if [[ x$(get_value chargingSwitch) == */* ]]; then
      file=$(echo $(get_value chargingSwitch) | awk '{print $1}')
      value=$(get_value chargingSwitch | awk '{print $2}')
      if [ -f $file ]; then
        chmod +w $file && echo $value > $file 2>/dev/null && sleep $(get_value chargingOnOffDelay) \
          || (/sbin/acc --set chargingSwitch- > /dev/null)
      else
        (/sbin/acc --set chargingSwitch- > /dev/null)
      fi
    else
      switch_loop on
    fi
  fi
}


ctrl_charging() {

  local count=0 wakelock=""

  while :; do

    if is_charging; then

      # clear "rebooted on pause" flag
    [ $(( $(cat $batt/capacity) $(get_value capacityOffset) )) -gt $(get_value capacity | cut -d, -f3 | cut -d- -f1) ] \
      || rm ${config%/*}/.rebootedOnPause 2>/dev/null || :

      # disable charging under <conditions>
      if [ $(( $(cat $batt/temp 2>/dev/null || cat $batt/batt_temp) / 10 )) -ge $(get_value temperature | cut -d- -f2 | cut -d_ -f1) ] \
        || [ $(( $(cat $batt/capacity) $(get_value capacityOffset) )) -ge $(get_value capacity | cut -d, -f3 | cut -d- -f2) ]
      then
        if [ ! -f ${config%/*}/.rebootedOnPause ]; then
          disable_charging
          if eval $(get_value resetBsOnPause); then

            # reset battery stats
            dumpsys batterystats --reset 2>/dev/null || :
            rm /data/system/batterystats* 2>/dev/null || :
          fi
        fi

        # rebootOnPause
        sleep $(get_value rebootOnPause) 2>/dev/null \
          && [ $(( $(cat $batt/capacity) $(get_value capacityOffset) )) -ge $(get_value capacity | cut -d, -f3 | cut -d- -f2) ] \
          && [ ! -f ${config%/*}/.rebootedOnPause ] \
          && touch ${config%/*}/.rebootedOnPause \
          && reboot || :

        if [ ! -f ${config%/*}/.rebootedOnPause ]; then
          # wakeUnlock
          # won't run under "battery idle" mode ("not charging" status)
          if grep -iq dis $batt/status && chmod +w /sys/power/wake_unlock; then
            for wakelock in $(get_value wakeUnlock); do
              echo $wakelock > /sys/power/wake_unlock || :
            done
          fi 2>/dev/null
        fi
      fi

      if [ ! -f ${config%/*}/.rebootedOnPause ]; then
        # cool down
        while [[ x$(get_value coolDownRatio) == */* ]] && is_charging \
          && [ $(( $(cat $batt/capacity) $(get_value capacityOffset) )) -lt $(get_value capacity | cut -d, -f3 | cut -d- -f2) ] \
          && [ $(( $(cat $batt/temp 2>/dev/null || cat $batt/batt_temp) / 10 )) -lt $(get_value temperature | cut -d- -f2 | cut -d_ -f1) ]
        do
          coolDown=true
          if [ $(( $(cat $batt/temp 2>/dev/null || cat $batt/batt_temp) / 10 )) -ge $(get_value temperature | cut -d- -f1) ] \
            || [ $(( $(cat $batt/capacity) $(get_value capacityOffset) )) -ge $(get_value capacity | cut -d, -f2) ]
          then
            disable_charging
            sleep $(get_value coolDownRatio | cut -d/ -f2)
            enable_charging
            count=0
            while [ $count -lt $(get_value coolDownRatio | cut -d/ -f1) ]; do
              sleep $(get_value loopDelay | cut -d, -f1)
              [ $(( $(cat $batt/capacity) $(get_value capacityOffset) )) -lt $(get_value capacity | cut -d, -f3 | cut -d- -f2) ] \
                && [ $(( $(cat $batt/temp 2>/dev/null || cat $batt/batt_temp) / 10 )) -lt $(get_value temperature | cut -d- -f2 | cut -d_ -f1) ] \
                && count=$(( count + $(get_value loopDelay | cut -d, -f1) )) || break
            done
          else
            break
          fi
        done
        coolDown=false
      fi
      sleep $(get_value loopDelay | cut -d, -f1)

    else
      # enable charging under <conditions>
      if [ $(( $(cat $batt/capacity) $(get_value capacityOffset) )) -le $(get_value capacity | cut -d, -f3 | cut -d- -f1) ] \
        && [ $(( $(cat $batt/temp 2>/dev/null || cat $batt/batt_temp) / 10 )) -lt $(get_value temperature | cut -d- -f2 | cut -d_ -f1) ]
      then
        enable_charging
      fi
      # auto-shutdown if battery is not charging and capacity is less than <shutdownCapacity>
      if ! is_charging && [ $(( $(cat $batt/capacity) $(get_value capacityOffset) )) -le $(get_value capacity | cut -d, -f1) ]; then
        sleep $(get_value loopDelay | cut -d, -f2)
        is_charging \
          || am start -n android/com.android.internal.app.ShutdownActivity 2>/dev/null \
          || reboot -p || :
      fi
    fi

    sleep $(get_value loopDelay | cut -d, -f2)
  done
}


apply_on_boot() {
  local file="" value=""
  for file in $(get_value applyOnBoot); do
    value=${file##*:}
    file=${file%:*}
    [ -f $file ] && chmod +w $file && echo $value > $file || :
  done
  [[ "x$(get_value applyOnBoot)" != *--exit ]] || exit 0
}


switch_loop() {
  local file="" on="" off=""
  while IFS= read -r file; do
    if [ -f $(echo $file | awk '{print $1}') ]; then
      on=$(echo $file | awk '{print $2}')
      off=$(echo $file | awk '{print $3}')
      file=$(echo $file | awk '{print $1}')
      chmod +w $file && eval "echo \$$1" > $file 2>/dev/null && sleep $(get_value chargingOnOffDelay) || continue
      if [ $1 == off ] && ! grep -Eiq "${2:-dis|not}" $batt/status; then
        echo $on > $file 2>/dev/null || :
      elif [ $1 == on ] && grep -Eiq "${2:-dis|not}" $batt/status; then
        echo $on > $file 2>/dev/null || :
      else
        break
      fi
    fi
  done << EOF
$(grep -Ev '#|^$' ${modPath%/*}/switches)
EOF
}


umask 077
coolDown=false
hibernate=true
secondsUnplugged=0
frozenBattSvc=false
resetBsOnUnplug=false
modPath=/sbin/.acc/acc
forcedStatusAt100=false
config=/data/adb/acc-data/config.txt

if [ ! -f $modPath/module.prop ]; then
  touch /dev/acc-modpath-not-found
  exit 7
fi

. $modPath/busybox.sh
mkdir -p ${config%/*}
cd /sys/class/power_supply/
[ -f $config ] || cp $modPath/default-config.txt $config

# config backup
if [ -d /data/media/0/?ndroid ]; then
  [ /data/media/0/.acc-config-backup.txt -nt $config ] \
    || install -m 0777 $config /data/media/0/.acc-config-backup.txt 2>/dev/null
fi

batt=$(echo /sys/class/power_supply/*attery/capacity | awk '{print $1}' | sed 's|/capacity||')
log=${modPath%/*}/accd-$(getprop ro.product.device | grep .. || getprop ro.build.product).log

pgrep -f '/acc (-|--)[def]|/accd.sh' | sed s/$$// | xargs kill -9 2>/dev/null

# diagnostics and cleanup
echo "###$(date)###" >> $log
echo "versionCode=$(sed -n s/versionCode=//p $modPath/module.prop 2>/dev/null)" >> $log
exec >> $log 2>&1
trap exxit EXIT
set -euxo pipefail

apply_on_boot
(/sbin/acc --voltage apply > /dev/null 2>&1) || :
unset -f apply_on_boot

ctrl_charging
exit $?
