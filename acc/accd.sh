#!/system/bin/sh
# Advanced Charging Controller Daemon (accd)
# Copyright (c) 2017-2019, VR25 (xda-developers.com)
# License: GPLv3+


exxit() {
  local exitCode=$?
  set +euxo pipefail
  trap - EXIT
  { dumpsys battery reset
  enable_charging
  /sbin/acc --voltage -; } > /dev/null 2>&1
  [ -n "$1" ] && echo -e "$2" && exitCode=$1
  echo "***EXIT $exitCode***"
  [[ $exitCode == [12] ]] && /sbin/acc --log --export > /dev/null 2>&1
  exit $exitCode
}


get_value() { sed -n "s|^$1=||p" $config; }


is_charging() {

  local file="" value="" isCharging=true wakelock=""

  grep -Eiq 'dis|not' $batt/status && isCharging=false || :

  if $isCharging; then
    unplugged=false
    secondsUnplugged=0
    # applyOnPlug
    for file in $(get_value applyOnPlug); do
      value=${file##*:}
      file=${file%:*}
      [ -f $file ] && chmod +w $file && echo $value > $file || :
    done
  else
    # resetBsOnUnplug
    if ! $unplugged && ! $coolDown && eval $(get_value resetBsOnUnplug); then
      sleep $(get_value loopDelay)
      if grep -iq dis $batt/status; then
        dumpsys batterystats --reset > /dev/null 2>&1 || :
        rm /data/system/batterystats* 2>/dev/null || :
      fi
    fi
    # rebootOnUnplug
    if ! $unplugged && [[ x$(get_value rebootOnUnplug) == x[0-9]* ]]; then
      sleep $(get_value rebootOnUnplug)
      ! grep -iq dis $batt/status || reboot
    fi
    unplugged=true
    # wakeUnlock
    # won't run under coolDown nor "battery idle" mode ("not charging" status)
    if grep -iq dis $batt/status && ! $coolDown; then
      for wakelock in $(get_value wakeUnlock); do
        echo $wakelock > /sys/power/wake_unlock
      done
    fi
    # dynamic power saving
    if ! $coolDown; then
      secondsUnplugged=$(( secondsUnplugged + $(get_value loopDelay) ))
      if [ $secondsUnplugged -ge 30 ]; then
        sleep $secondsUnplugged
      fi
      [ $secondsUnplugged -ge 60 ] && secondsUnplugged=$(get_value loopDelay) || :
    else
      secondsUnplugged=0
    fi
  fi

  # correct the battery capacity reported by Android
  if eval $(get_value capacitySync); then
    dumpsys battery reset || :
    dumpsys battery set level $(cat $batt/capacity) || :
  fi > /dev/null 2>&1

  # clear "rebooted on pause" flag
  [ $(( $(cat $batt/capacity) $(get_value capacityOffset) )) -le $(get_value capacity | cut -d, -f3 | cut -d- -f1) ] \
    && rm ${config%/*}/.rebootedOnPause 2>/dev/null || :

  [ $(du -m $log | awk '{print $1}') -gt 1 ] && : > $log || :
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
  # cool down
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

  local count=0

  while :; do

    if is_charging; then
      # disable charging & clear battery stats if conditions apply
      if [ $(( $(cat $batt/temp 2>/dev/null || cat $batt/batt_temp) / 10 )) -ge $(get_value temperature | cut -d- -f2 | cut -d_ -f1) ] \
        || [ $(( $(cat $batt/capacity) $(get_value capacityOffset) )) -ge $(get_value capacity | cut -d, -f3 | cut -d- -f2) ]
      then
        disable_charging
        if eval $(get_value resetBsOnPause); then
          # reset battery stats
          dumpsys batterystats --reset > /dev/null 2>&1 || :
          rm /data/system/batterystats* 2>/dev/null || :
        fi
        # rebootOnPause
        sleep $(get_value rebootOnPause) 2>/dev/null \
          && [ $(( $(cat $batt/capacity) $(get_value capacityOffset) )) -ge $(get_value capacity | cut -d, -f3 | cut -d- -f2) ] \
            && [ ! -f ${config%/*}/.rebootedOnPause ] \
              && touch ${config%/*}/.rebootedOnPause \
               && reboot || :
      fi

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
            sleep $(get_value loopDelay)
            [ $(( $(cat $batt/capacity) $(get_value capacityOffset) )) -lt $(get_value capacity | cut -d, -f3 | cut -d- -f2) ] \
              && [ $(( $(cat $batt/temp 2>/dev/null || cat $batt/batt_temp) / 10 )) -lt $(get_value temperature | cut -d- -f2 | cut -d_ -f1) ] \
                && count=$((count + $(get_value loopDelay))) || break
          done
        else
          break
        fi
      done
      coolDown=false

    else
      # enable charging if conditions apply
      if [ $(( $(cat $batt/capacity) $(get_value capacityOffset) )) -le $(get_value capacity | cut -d, -f3 | cut -d- -f1) ] \
        && [ $(( $(cat $batt/temp 2>/dev/null || cat $batt/batt_temp) / 10 )) -lt $(get_value temperature | cut -d- -f2 | cut -d_ -f1) ]
      then
        enable_charging
      fi
      # auto-shutdown if battery is not charging and capacity is less than <shutdownCapacity>
      if ! is_charging && [ $(( $(cat $batt/capacity) $(get_value capacityOffset) )) -le $(get_value capacity | cut -d, -f1) ]; then
        reboot -p || :
      fi
    fi

    sleep $(get_value loopDelay)
  done
}


apply_on_boot() {
  local file="" value=""
  for file in $(get_value applyOnBoot); do
    value=${file##*:}
    file=${file%:*}
    [ -f $file ] && chmod +w $file && echo $value > $file || :
  done
  [[ "x$(get_value applyOnBoot)" == *--exit ]] && exit 0 || :
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
  done << SWITCHES
$(grep -Ev '#|^$' $modPath/switches.txt)
SWITCHES
}


umask 0
modId=acc
coolDown=false
unplugged=true
secondsUnplugged=0
modPath=/sbin/.$modId/$modId
config=/data/media/0/$modId/${modId}.conf

if [ ! -f $modPath/module.prop ]; then
  touch /dev/${modId}-modpath-not-found
  exit 1
fi

if ! which busybox > /dev/null; then
  if [ -d /sbin/.magisk/busybox ]; then
    PATH=/sbin/.magisk/busybox:$PATH
  elif [ -d /sbin/.core/busybox ]; then
    PATH=/sbin/.core/busybox:$PATH
  else
    touch $modPath/busybox-not-found
    exit 1
  fi
fi

# wait for data decryption
until [ -d /data/media/0/?ndroid ]; do sleep 15; done

mkdir -p ${config%/*}
cd /sys/class/power_supply/

if [ ! -f $config ]; then
  cp $modPath/acc.conf $config
  chmod -R 0777 ${config%/*}
fi

batt=$(echo /sys/class/power_supply/*attery/capacity | awk '{print $1}' | sed 's|/capacity||')
log=${modPath%/*}/acc-daemon-$(getprop ro.product.device | grep .. || getprop ro.build.product).log

pgrep -f '/acc (-|--)[def]|/accd.sh' | sed s/$$// | xargs kill -9 2>/dev/null\

# diagnostics and cleanup
echo "###$(date)###" >> $log
echo "versionCode=$(sed -n s/versionCode=//p $modPath/module.prop 2>/dev/null)" >> $log
exec >> $log 2>&1
trap exxit EXIT
set -euxo pipefail

apply_on_boot
(/sbin/acc --voltage apply > /dev/null 2>&1) || :
unset modId
unset -f apply_on_boot
ctrl_charging
exit $?
