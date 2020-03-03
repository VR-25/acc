#!/system/bin/sh
# Advanced Charging Controller Daemon (accd)
# Copyright (c) 2017-2020, VR25 (xda-developers)
# License: GPLv3+


exxit() {
  local exitCode=$?
  set +euxo pipefail 2>/dev/null
  trap - EXIT
  { dumpsys battery reset
  enable_charging
  . ${0%/*}/apply-on-boot.sh
  apply_on_boot default
  apply_on_plug default; } > /dev/null 2>&1
  [ -n "$1" ] && exitCode=$1
  [ -n "$2" ] && echo -e "$2"
  echo "***EXIT $exitCode***"
  [[ $exitCode == [127] ]] && /sbin/acca $config --log --export > /dev/null 2>&1
  exit $exitCode
}


is_charging() {

  local file="" value="" isCharging=false

  . $config

  grep -Eiq 'dis|not' $batt/status || isCharging=true

  if $isCharging; then

    # read chgStatusCode once
    [ -z "$chgStatusCode" ] \
      || chgStatusCode=$(dumpsys battery 2>/dev/null | sed -n 's/^  status: //p') || :

    # read charging current ctrl files (part 2) once
    ! $readChCurr || . $modPath/read-ch-curr-ctrl-files-p2.sh

    $coolDown || resetBattStatsOnUnplug=true
    secondsUnplugged=0

    $applyOnUnplug || apply_on_plug
    applyOnUnplug=true

    # forceChargingStatusFullAt100
    if ! $forcedChargingStatusFullAt100 && [[ ${forceChargingStatusFullAt100:-x} == [0-9]* ]] \
      && [ $(cat $batt/capacity) -gt 99 ]
    then
      dumpsys battery set level 100 \
        && dumpsys battery set status $forceChargingStatusFullAt100 \
        && { forcedChargingStatusFullAt100=true; frozenBattSvc=true; } \
        || sleep ${loopDelay[0]}
    fi

  else

    # read dischgStatusCode once
    [ -z "$dischgStatusCode" ] \
      || dischgStatusCode=$(dumpsys battery 2>/dev/null | sed -n 's/^  status: //p') || :

    if ! $coolDown; then

      # applyOnUnplug
      if $applyOnUnplug; then
        apply_on_plug default
        applyOnUnplug=false
      fi

      # revert forceChargingStatusFullAt100
      if $frozenBattSvc; then
        dumpsys battery reset \
          && { frozenBattSvc=false; forcedChargingStatusFullAt100=false; } \
          || sleep ${loopDelay[1]}
      fi

      # resetBattStatsOnUnplug
      if $resetBattStatsOnUnplug && ${resetBattStats[1]}; then
        sleep ${loopDelay[1]}
        if grep -iq dis $batt/status; then
          dumpsys batterystats --reset || :
          rm /data/system/batterystats* || :
          resetBattStatsOnUnplug=false
        fi 2>/dev/null
      fi

      # dynamic power saving
      # while unplugged, this keeps accd asleep most of the time to save resources
      # detecting plugged/unplugged states is possible (with acpi -a), but not universally
      if [ "$dynPowerSaving" != 0 ] && grep -iq dis $batt/status; then
        if [ $secondsUnplugged == 0 ]; then
          [ $(( ${capacity[3]} - ${capacity[2]} )) -gt 4 ] \
            && hibernate=true || hibernate=false
        fi
        secondsUnplugged=$(( secondsUnplugged + ${loopDelay[1]} ))
        ! $hibernate || sleep $secondsUnplugged
        [ $secondsUnplugged -lt $dynPowerSaving ] || secondsUnplugged=0
      fi

    else
      secondsUnplugged=0
    fi
  fi

  # capacitySync: corrects the battery capacity reported by Android
  if ${capacity[5]}; then
    ($isCharging || chgStatusCode=$dischgStatusCode
    $coolDown || dumpsys battery set status $chgStatusCode || :)
    dumpsys battery set level $(cat $batt/capacity) || :
  fi > /dev/null 2>&1

  # log buffer reset
  [ $(du -m $log | cut -f 1) -lt 2 ] || : > $log

  $isCharging && return 0 || return 1
}


disable_charging() {
  if is_charging; then
    if [ -f "${chargingSwitch[0]-}" ]; then
      if chmod +w ${chargingSwitch[0]} && echo "${chargingSwitch[2]//::/ }" > ${chargingSwitch[0]}; then
        # secondary switch
        if [ -f "${chargingSwitch[3]-}" ]; then
          chmod +w ${chargingSwitch[3]} && echo "${chargingSwitch[5]//::/ }" > ${chargingSwitch[3]} \
            || /sbin/acca $config --set charging_switch= > /dev/null
        fi
        sleep $switchDelay
      else
        /sbin/acca $config --set charging_switch= > /dev/null
      fi
    else
      [[ ${chargingSwitch[0]:-x} != */* ]] || /sbin/acca $config --set charging_switch= > /dev/null
      ! $prioritizeBattIdleMode || cycle_switches off not
      ! is_charging || cycle_switches off
    fi
    if is_charging; then
      [[ ${chargingSwitch[0]:-x} != */* ]] || /sbin/acca $config --set charging_switch= > /dev/null
      echo "(!) Failed to disable charging"
      exit 7
    fi
  fi
  # if maxTemp is reached, pause charging regardless of coolDownRatio
  ! is_charging && [ $(( $(cat $batt/temp 2>/dev/null \
    || cat $batt/batt_temp) / 10 )) -ge ${temperature[1]} ] \
    && sleep ${temperature[2]} || :
}


enable_charging() {
  if ! is_charging; then
    if ! $ghostCharging || { $ghostCharging && [[ "$(acpi -a)" == *on-line* ]]; }; then
      if [ -f "${chargingSwitch[0]-}" ]; then
        if chmod +w ${chargingSwitch[0]} \
          && echo "${chargingSwitch[1]//::/ }" > ${chargingSwitch[0]}
        then
          # secondary switch
          if [ -f "${chargingSwitch[3]-}" ]; then
            chmod +w ${chargingSwitch[3]} && echo "${chargingSwitch[4]//::/ }" > ${chargingSwitch[3]} \
              || /sbin/acca $config --set charging_switch= > /dev/null
          fi
          sleep $switchDelay
        else
          /sbin/acca $config --set charging_switch= > /dev/null
        fi
      else
        [[ ${chargingSwitch[0]:-x} != */* ]] \
          || /sbin/acca $config --set charging_switch= > /dev/null
        cycle_switches on
      fi
      # detect and block ghost charging
      if ! $ghostCharging && ! grep -Eiq 'dis|not' $batt/status && [[ "$(acpi -a)" != *on-line* ]]; then
        disable_charging
        ghostCharging=true
        touch $TMPDIR/.ghost-charging
      fi
    fi
  fi
}


ctrl_charging() {

  local count=0 wakelock=""

  while :; do

    if is_charging; then

      sleep ${loopDelay[0]}

      # clear "rebooted on pause" flag
    [ $(( $(cat $batt/capacity) ${capacity[4]} )) -gt ${capacity[2]} ] \
      || rm ${config%/*}/.rebootedOnPause 2>/dev/null || :

      # disable charging under <conditions>
      if [ $(( $(cat $batt/temp 2>/dev/null || cat $batt/batt_temp) / 10 )) -ge ${temperature[1]} ] \
        || [ $(( $(cat $batt/capacity) ${capacity[4]} )) -ge ${capacity[3]} ]
      then
        if [ ! -f ${config%/*}/.rebootedOnPause ]; then
          disable_charging
          if ${resetBattStats[0]}; then
            # reset battery stats on pause
            dumpsys batterystats --reset || :
            rm /data/system/batterystats* || :
          fi
          set +eo pipefail 2>/dev/null
          eval "${runCmdOnPause[@]-}"
          set -eo pipefail 2>/dev/null || :
        fi

        # rebootOnPause
        sleep $rebootOnPause 2>/dev/null \
          && [ $(( $(cat $batt/capacity) ${capacity[4]} )) -ge ${capacity[3]} ] \
          && [ ! -f ${config%/*}/.rebootedOnPause ] \
          && touch ${config%/*}/.rebootedOnPause \
          && { am start -a android.intent.action.REBOOT || reboot; } || :

        if [ ! -f ${config%/*}/.rebootedOnPause ]; then
          # wakeUnlock
          # won't run under "battery idle" mode ("not charging" status)
          if grep -iq dis $batt/status && chmod +w /sys/power/wake_unlock; then
            for wakelock in "${wakeUnlock[@]-}"; do
              echo $wakelock > /sys/power/wake_unlock || :
            done
          fi 2>/dev/null
        fi
      fi

      if [ ! -f ${config%/*}/.rebootedOnPause ]; then
        # cool down
        while [ -n "${coolDownRatio[0]:-}" ] && [ $(( ${capacity[3]} - ${capacity[2]} )) -gt 2 ] \
          && is_charging && [ $(( $(cat $batt/capacity) ${capacity[4]} )) -lt ${capacity[3]} ] \
          && [ $(( $(cat $batt/temp 2>/dev/null || cat $batt/batt_temp) / 10 )) -lt ${temperature[1]} ]
        do
          coolDown=true
          if [ $(( $(cat $batt/temp 2>/dev/null || cat $batt/batt_temp) / 10 )) -ge ${temperature[0]} ] \
            || [ $(( $(cat $batt/capacity) ${capacity[4]} )) -ge ${capacity[1]} ]
          then
            dumpsys battery set status $chgStatusCode || :
            disable_charging
            sleep ${coolDownRatio[1]:-1}
            enable_charging
            if ${capacity[5]}; then
              dumpsys battery set status $chgStatusCode || :
            else
              dumpsys battery reset || :
            fi
            count=0
            while ! grep -Eiq 'dis|not' $batt/status \
              && [ $count -lt ${coolDownRatio[0]:-1} ]
            do
              sleep ${loopDelay[0]}
              [ $(( $(cat $batt/capacity) ${capacity[4]} )) -lt ${capacity[3]} ] \
                && [ $(( $(cat $batt/temp 2>/dev/null || cat $batt/batt_temp) / 10 )) -lt ${temperature[1]} ] \
                && count=$(( count + ${loopDelay[0]} )) || break
            done
          else
            break
          fi
        done
        coolDown=false
      fi

    else

      sleep ${loopDelay[1]}

      # enable charging under <conditions>
      if [ $(( $(cat $batt/capacity) ${capacity[4]} )) -le ${capacity[2]} ] \
        && [ $(( $(cat $batt/temp 2>/dev/null || cat $batt/batt_temp) / 10 )) -lt ${temperature[1]} ]
      then
        enable_charging
      fi

      # auto-shutdown if battery is not charging and capacity is less than <shutdownCapacity>
      if ! is_charging && [ $(( $(cat $batt/capacity) ${capacity[4]} )) -le ${capacity[0]} ]; then
        sleep ${loopDelay[1]}
        is_charging \
          || am start -n android/com.android.internal.app.ShutdownActivity 2>/dev/null || reboot -p || :
      fi
    fi
  done
}


# load generic functions
. ${0%/*}/apply-on-boot.sh
. ${0%/*}/apply-on-plug.sh
. ${0%/*}/cycle-switches.sh


umask 077
coolDown=false
hibernate=true
readChCurr=true
chgStatusCode=""
dischgStatusCode=""
secondsUnplugged=0
frozenBattSvc=false
applyOnUnplug=false
resetBattStatsOnUnplug=false
modPath=/sbin/.acc/acc
export TMPDIR=${modPath%/*}
forcedChargingStatusFullAt100=false
config=/data/adb/acc-data/config.txt
[ -f $TMPDIR/.ghost-charging ] && ghostCharging=true || ghostCharging=false


. $modPath/setup-busybox.sh

log=$TMPDIR/accd-$(getprop ro.product.device | grep .. || getprop ro.build.product).log

# verbose
echo "###$(date)###" >> $log
echo "versionCode=$(sed -n s/versionCode=//p $modPath/module.prop 2>/dev/null)" >> $log
exec >> $log 2>&1
trap exxit EXIT
set -x

pgrep -f '/ac(c|ca) (-|--)[def]|/accd\.sh' | sed s/$$// | xargs kill -9 2>/dev/null
set -euo pipefail 2>/dev/null || :
cd /sys/class/power_supply/
mkdir -p ${config%/*}
[ -f $config ] || cp $modPath/default-config.txt $config

# config backup
if [ -d /data/media/0/?ndroid ]; then
  [ /data/media/0/.acc-config-backup.txt -nt $config ] \
    || install -m 777 $config /data/media/0/.acc-config-backup.txt 2>/dev/null
fi

# custom config path
case "${1-}" in
  */*)
    [ -f $1 ] || cp $config $1
    config=$1
  ;;
esac

batt=$(echo *attery/capacity | cut -d ' ' -f 1 | sed 's|/capacity||')

. $modPath/oem-custom.sh
. $config

apply_on_boot
unset -f apply_on_boot

ctrl_charging
exit $?
