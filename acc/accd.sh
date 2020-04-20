#!/system/bin/sh
# Advanced Charging Controller Daemon (accd)
# Copyright (c) 2017-2020, VR25 (xda-developers)
# License: GPLv3+


exxit() {
  local exitCode=$?
  set +euxo pipefail 2>/dev/null
  trap - EXIT
  { dumpsys battery reset
  cp $config /dev/.acc-config
  config=/dev/.acc-config
  enable_charging
  apply_on_boot default
  apply_on_plug default; } > /dev/null 2>&1
  [ -n "$1" ] && exitCode=$1
  [ -n "$2" ] && echo -e "$2"
  echo "***EXIT $exitCode***"
  [[ $exitCode == [127] ]] && {
    . ${0%/*}/logf.sh
    logf --export > /dev/null 2>&1
    eval "${errorAlertCmd[@]-}"
  }
  rm $config
  exit $exitCode
}


is_charging() {

  local file="" value="" isCharging=false

  . $config

  grep -Eiq 'dis|not' $batt/status || isCharging=true

  if $isCharging; then

    # reset auto-shutdown warning thresholds
    lowPower=false
    warningThresholds=$_warningThresholds

    # read chgStatusCode once
    [ -n "$chgStatusCode" ] || {
      dumpsys battery reset \
        && chgStatusCode=$(dumpsys battery 2>/dev/null | sed -n 's/^  status: //p') || :
    }

    # read charging current ctrl files (part 2) once
    ! $readChCurr || . $modPath/read-ch-curr-ctrl-files-p2.sh

    $cooldown || resetBattStatsOnUnplug=true
    secondsUnplugged=0

    $applyOnUnplug || apply_on_plug
    applyOnUnplug=true

    # forceChargingStatusFullAt100
    if ! $forcedChargingStatusFullAt100 \
      && [ -n "${forceChargingStatusFullAt100-}" ] \
      && [ $(( $(cat $batt/capacity) ${capacity[4]} )) -gt 99 ]
    then
      dumpsys battery set level 100 \
        && dumpsys battery set status $forceChargingStatusFullAt100 \
        && { forcedChargingStatusFullAt100=true; frozenBattSvc=true; } \
        || sleep ${loopDelay[0]}
    fi

  else

    # read dischgStatusCode once
    #   and dynamically enable/disable capacitySync
    [ -n "$dischgStatusCode" ] || {
      ! dumpsys battery reset || {
        ! dischgStatusCode=$(dumpsys battery 2>/dev/null | sed -n 's/^  status: //p') || {
          if [ $(dumpsys battery 2>/dev/null | sed -n 's/^  level: //p') -ne $(cat $batt/capacity) ] \
            && sleep 2 \
            &&  [ $(dumpsys battery 2>/dev/null | sed -n 's/^  level: //p') -ne $(cat $batt/capacity) ]
          then
            ${capacity[5]} || {
              capacity[4]=+0
              capacity[5]=true
              [ ${loopDelay[0]} -le 5 ] || loopDelay[0]=5
              [ ${loopDelay[1]} -le 10 ] || loopDelay[1]=10
              dynPowerSaving=0
              . $modPath/write-config.sh
            }
          else
            ! ${capacity[5]} || {
              capacity[5]=false
              [ ${loopDelay[0]} -ge 10 ] || loopDelay[0]=10
              [ ${loopDelay[1]} -ge 15 ] || loopDelay[1]=15
              . $modPath/write-config.sh
            }
          fi
        }
      }
    }

    if ! $cooldown; then

      # applyOnUnplug
      ! $applyOnUnplug || {
        apply_on_plug default
        applyOnUnplug=false
      }

      # revert forceChargingStatusFullAt100
      ! $frozenBattSvc || {
        dumpsys battery reset \
          && { frozenBattSvc=false; forcedChargingStatusFullAt100=false; } \
          || sleep ${loopDelay[1]}
      }

      # resetBattStatsOnUnplug
      if $resetBattStatsOnUnplug && ${resetBattStats[1]}; then
        sleep ${loopDelay[1]}
        ! grep -iq dis $batt/status || {
          dumpsys batterystats --reset || :
          rm /data/system/batterystats* || :
          resetBattStatsOnUnplug=false
        } 2>/dev/null
      fi

      # dynamic power saving
      # while unplugged, this keeps accd asleep most of the time to save resources
      # detecting plugged/unplugged states is possible (with acpi -a), but not universally
      if [ "$dynPowerSaving" != 0 ] && grep -iq dis $batt/status; then
        [ $secondsUnplugged == 0 ] && hibernate=true || hibernate=false
        secondsUnplugged=$(( secondsUnplugged + ${loopDelay[1]} ))
        ! $hibernate || sleep $secondsUnplugged
        [ $secondsUnplugged -lt $dynPowerSaving ] || secondsUnplugged=0
      fi

    else
      secondsUnplugged=0
    fi
  fi

  # capacitySync: corrects the battery capacity reported by Android
  ! ${capacity[5]} || {
    $cooldown || {
      if $isCharging; then
        dumpsys battery set ac 1 \
          && dumpsys battery set status $chgStatusCode || :
      else
        dumpsys battery unplug \
          && dumpsys battery set status $dischgStatusCode || :
      fi
    }
    dumpsys battery set level $(cat $batt/capacity) || :
  }

  # log buffer reset
  [ $(du -m $log | cut -f 1) -lt 2 ] || : > $log

  $isCharging && return 0 || return 1
}


ctrl_charging() {

  local count=0 wakelock=""

  while :; do

    if is_charging; then

      # clear "rebooted on pause" flag
      [ $(( $(cat $batt/capacity) ${capacity[4]} )) -gt ${capacity[2]} ] \
        || rm ${config%/*}/.rebootedOnPause 2>/dev/null || :

      # disable charging under <conditions>
      if [ $(cat $batt/temp 2>/dev/null || cat $batt/batt_temp) -ge $(( ${temperature[1]} * 10 )) ] \
        || [ $(( $(cat $batt/capacity) ${capacity[4]} )) -ge ${capacity[3]} ]
      then
        [ -f ${config%/*}/.rebootedOnPause ] || {
          disable_charging
          ! ${resetBattStats[0]} || {
            # reset battery stats on pause
            dumpsys batterystats --reset || :
            rm /data/system/batterystats* || :
          }
        }

        # rebootOnPause
        sleep $rebootOnPause 2>/dev/null && {
          [ $(( $(cat $batt/capacity) ${capacity[4]} )) -ge ${capacity[3]} ]
          [ ! -f ${config%/*}/.rebootedOnPause ]
          touch ${config%/*}/.rebootedOnPause
          { am start -a android.intent.action.REBOOT || reboot; }
        } || :

        [ -f ${config%/*}/.rebootedOnPause ] || {
          # wakeUnlock
          # won't run under "battery idle" mode ("not charging" status)
          if grep -iq dis $batt/status && chmod u+w /sys/power/wake_unlock; then
            for wakelock in "${wakeUnlock[@]-}"; do
              echo $wakelock > /sys/power/wake_unlock || :
            done
          fi 2>/dev/null
        }
      fi

      [ -f ${config%/*}/.rebootedOnPause ] || {

        # cooldown cycle
        while [ -n "${cooldownRatio[0]-}" -o -n "${cooldownCurrent[0]-}" ] && is_charging \
          && [ $(( $(cat $batt/capacity) ${capacity[4]} )) -lt ${capacity[3]} ]
        do
          if [ $(cat $batt/temp 2>/dev/null || cat $batt/batt_temp) -ge $(( ${temperature[0]} * 10 )) ] \
            || [ $(( $(cat $batt/capacity) ${capacity[4]} )) -ge ${capacity[1]} ] \
            || [ $(sed s/-// ${cooldownCurrent[0]:-cooldownCurrent} 2>/dev/null || echo 0) -ge ${cooldownCurrent[1]:-1} ]
          then
            cooldown=true
            dumpsys battery set status $chgStatusCode || : # to block unwanted display wakeups
            disable_charging
            [ $(sed s/-// ${cooldownCurrent[0]:-cooldownCurrent} 2>/dev/null || echo 0) -ge ${cooldownCurrent[1]:-1} ] \
              && sleep ${cooldownCurrent[3]:-1} \
              || sleep ${cooldownRatio[1]:-1}
            enable_charging
            ${capacity[5]} || dumpsys battery reset || : # ${capacity[5]} == capacity_sync
            [ ! $(sed s/-// ${cooldownCurrent[0]:-cooldownCurrent} 2>/dev/null || echo 0) -ge ${cooldownCurrent[1]:-1} ] \
              || cooldownRatio[0]=${cooldownCurrent[2]-}
            count=0
            while ! grep -Eiq 'dis|not' $batt/status && [ $count -lt ${cooldownRatio[0]:-1} ]; do
              sleep ${loopDelay[0]}
              [ $(( $(cat $batt/capacity) ${capacity[4]} )) -lt ${capacity[3]} ] \
                && count=$(( count + ${loopDelay[0]} )) \
                || break
            done
          else
            break
          fi
        done
        cooldown=false
      }

      sleep ${loopDelay[0]}

    else

      # enable charging under <conditions>
      [ ! $(( $(cat $batt/capacity) ${capacity[4]} )) -le ${capacity[2]} ] || {
        [ ! $(cat $batt/temp 2>/dev/null || cat $batt/batt_temp) -lt $(( ${temperature[1]} * 10 )) ] \
          || enable_charging
      }

      ! not_charging || {

        # auto-shutdown warnings
        c=$(cat $batt/capacity)
        for i in $warningThresholds; do
          [ $c -ne $i ] || {
            eval "$autoShutdownAlertCmd[@]-}"
            warningThresholds=${warningThresholds/$i}
            $lowPower || {
              ! settings put global low_power 1 || lowPower=true
            }
          }
        done
        unset i c

        # auto-shutdown if battery is not charging and capacity is less than <shutdown_capacity>
        [ ! $(( $(cat $batt/capacity) ${capacity[4]} )) -le ${capacity[0]} ] || {
          sleep ${loopDelay[1]}
          ! not_charging \
            || am start -n android/com.android.internal.app.ShutdownActivity 2>/dev/null || reboot -p 2>/dev/null \
              ||/system/bin/reboot -p || :
        }
      }

      sleep ${loopDelay[1]}

    fi
  done
}


# load generic functions
. ${0%/*}/misc-functions.sh


isAccd=true
cooldown=false
hibernate=true
lowPower=false
readChCurr=true
chgStatusCode=""
dischgStatusCode=""
secondsUnplugged=0
frozenBattSvc=false
applyOnUnplug=false
resetBattStatsOnUnplug=false
log=$TMPDIR/accd-${device}.log
forcedChargingStatusFullAt100=false


# verbose
echo "###$(date)###" >> $log
echo "versionCode=$(sed -n s/versionCode=//p $modPath/module.prop 2>/dev/null)" >> $log
exec >> $log 2>&1
set -x


pgrep -f '/ac(c|ca) (-|--)(calibrate|test|[Cdeft])|/accd\.sh' | sed /$$/d | xargs kill -9 2>/dev/null

misc_stuff "${1-}"


. $modPath/oem-custom.sh
. $config


# set auto-shutdown warning thresholds
[ ${capacity[0]} -lt 0 ] || _warningThresholds="
  $(
    for i in 5 4 3 2 1; do
      echo $(( ${capacity[0]} + i ))
    done
  )
"
warningThresholds=${_warningThresholds=}


apply_on_boot
ctrl_charging
exit $?
