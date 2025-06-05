#!/system/bin/sh
# Advanced Charging Controller Daemon (accd)
# Copyright 2017-2024, VR25
# License: GPLv3+


. $execDir/acquire-lock.sh


_INIT=false

case "$*" in
  *-i*) _INIT=true;;
  *) [ -f $TMPDIR/.batt-interface.sh ] || _INIT=true;;
esac


if ! $_INIT; then


  _ge_cooldown_cap() {
    if [ ${capacity[1]} -gt 3000 ]; then
      [ $(volt_now) -ge ${capacity[1]} ]
    else
      [ $(batt_cap) -ge ${capacity[1]} ]
    fi
  }


  _ge_pause_cap() {
    if [ ${capacity[3]} -gt 3000 ]; then
      [ $(volt_now) -ge ${capacity[3]} ]
    else
      [ $(batt_cap) -ge ${capacity[3]} ]
    fi
  }


  _le_pause_cap() {
    if [ ${capacity[3]} -gt 3000 ]; then
      [ $(volt_now) -le ${capacity[3]} ]
    else
      [ $(batt_cap) -le ${capacity[3]} ]
    fi
  }


  _lt_pause_cap() {
    if [ ${capacity[3]} -gt 3000 ]; then
      [ $(volt_now) -lt ${capacity[3]} ]
    else
      [ $(batt_cap) -lt ${capacity[3]} ]
    fi
  }


  _gt_resume_cap() {
    if [ ${capacity[2]} -gt 3000 ]; then
      [ $(volt_now) -gt ${capacity[2]} ]
    else
      [ $(batt_cap) -gt ${capacity[2]} ]
    fi
  }


  _le_resume_cap() {
    if $mtReached && _lt_pause_cap; then
      return 0
    elif [ ${capacity[2]} -gt 3000 ]; then
      [ $(volt_now) -le ${capacity[2]} ]
    else
      [ $(batt_cap) -le ${capacity[2]} ]
    fi
  }


  _le_shutdown_cap() {
    if [ ${capacity[0]} -gt 3000 ]; then
      [ $(volt_now) -le ${capacity[0]} ]
    else
      [ $(batt_cap) -le ${capacity[0]} ]
    fi
  }


  _uptime() {
    [ $(cut -d '.' -f 1 /proc/uptime) -ge $1 ]
  }


  cap_idle_threshold() {
    if [ ${capacity[3]} -gt 3000 ]; then
      [ ${capacity[3]} -gt 3900 ] && [ $(volt_now) -gt $(( ${capacity[3]} + 50 )) ]
    else
      [ ${capacity[3]} -gt 60 ] && [ $(batt_cap) -gt $(( ${capacity[3]} + 1 )) ]
    fi
  }


  exxit() {
    exitCode=$?
    $persistLog && set +eu || set +eux
    rm $TMPDIR/.forceoff* 2>/dev/null
    trap - EXIT
    [ -n "$1" ] && exitCode=$1
    [ -n "$2" ] && print "$2"
    $persistLog || exec > /dev/null 2>&1
    dsys_batt reset >/dev/null
    grep -Ev '^$|^#' $config > $TMPDIR/.config
    config=$TMPDIR/.config
    applyOnPlug=(${applyOnPlug[*]-} ${applyOnBoot[*]-})
    apply_on_plug default
    tempLevel=0
    enable_charging
    if [[ "$exitCode" = [127] ]]; then
      . $execDir/logf.sh
      logf --export
      notif "⚠️ Exit $exitCode; log: acc -l tail"
    fi
    cd /
    echo versionCode=$versionCode
    exit $exitCode
  }


  is_charging() {

    local file=
    local value=
    local isCharging=false

    # source config & set discharge polarity
    set_dp

    if not_charging; then
      unsolicitedResumes=0
    else
      isCharging=true
      # [auto mode] change the charging switch if charging has not been enabled by acc (if behavior repeats 3 times in a row)
      if $chDisabledByAcc && [ -n "${chargingSwitch[0]-}" ] && [[ "${chargingSwitch[*]}" != *\ -- ]] \
        && sleep ${loopDelay[1]} && { ! not_charging || { isCharging=false; false; }; }
      then
        if [ $unsolicitedResumes -ge 3 ]; then
          if grep -q "^${chargingSwitch[*]}$" $TMPDIR/ch-switches; then
            sed -i "\|^${chargingSwitch[*]}$|d" $TMPDIR/ch-switches
            echo "${chargingSwitch[*]}" >> $TMPDIR/ch-switches
          fi
          $TMPDIR/acca $config --set charging_switch=
          chargingSwitch=()
          unsolicitedResumes=0
        else
          unsolicitedResumes=$((unsolicitedResumes + 1))
        fi
      fi
      # [auto mode] set charging switch
      if [ -z "${chargingSwitch[0]-}" ]; then
        disable_charging
        enable_charging
      fi
    fi

    [ $currentWorkaround0 = $currentWorkaround ] || exec $TMPDIR/accd --init
    (set +eu; eval '${loopCmd-}') || :

    # shutdown if battery temp >= shutdown_temp
    [ $(cat $temp) -lt $(( ${temperature[3]} * 10 )) ] || shutdown

    [ -z "${cooldownCurrent-}" ] || {
      if [ $(cat $temp) -le $(( ${temperature[2]} * 10 )) ] && ! _ge_cooldown_cap; then
        restrictCurr=false
      fi
      if _ge_cooldown_cap || [ $(cat $temp) -ge $(( ${temperature[0]} * 10 )) ] \
        || { ! $isCharging && [ $(cat $temp) -ge $(( ${temperature[2]} * 10 )) ]; }
      then
        restrictCurr=true
      fi
    }

    if $isCharging; then

      if [ -f $TMPDIR/.mcc-read ]; then
        # set charging current control files, as needed
        if [ -n "${maxChargingCurrent[0]-}" ] \
          && { [ -z "${maxChargingCurrent[1]-}" ] || [[ "${maxChargingCurrent[1]-}" = -* ]]; } \
          && grep -q / $TMPDIR/ch-curr-ctrl-files 2>/dev/null
        then
          set_ch_curr ${maxChargingCurrent[0]} || :
          . $execDir/write-config.sh
        fi
      else
        # parse charging current ctrl files
        . $execDir/read-ch-curr-ctrl-files-p2.sh
      fi

       # set charging voltage control files, as needed
      if [ -n "${maxChargingVoltage[0]-}" ] \
        && { [ -z "${maxChargingVoltage[1]-}" ] || [[ "${maxChargingCurrent[1]-}" = -* ]]; } \
        && grep -q / $TMPDIR/ch-volt-ctrl-files 2>/dev/null
      then
        set_ch_volt ${maxChargingVoltage[0]} || :
        . $execDir/write-config.sh
      fi

      $cooldown || {
        resetBattStatsOnUnplug=true
        if $resetBattStatsOnPlug && ${resetBattStats[2]}; then
          sleep ${loopDelay[0]}
          not_charging || {
            resetbs
            resetBattStatsOnPlug=false
          } 2>/dev/null
        fi
      }

      if $restrictCurr && [ -n "${cooldownCurrent-}" ]; then
        $cooldown || (set_ch_curr ${cooldownCurrent:--} || :)
        (maxChargingCurrent=(); apply_on_plug)
      else
        [ -n "${maxChargingCurrent[0]-}" ] || (set_ch_curr - || :)
        apply_on_plug
      fi

      set_ch_volt ${maxChargingVoltage[0]:--}
      { $restrictCurr && [[ .${cooldownCurrent-} = .*% ]]; } || set_temp_level
      shutdownWarnings=true

    else

      $rebootResume \
        && le_resume_cap \
        && [ $(cat $temp) -lt $(( ${temperature[1]} * 10 )) ] && {
          notif "⚠️ System will reboot in 60 seconds to re-enable charging! Run \"accd.\" to abort."
          sleep 60
          ! not_charging || {
            /system/bin/reboot || reboot
          }
        } || :

      $cooldown || {
        resetBattStatsOnPlug=true
        if $resetBattStatsOnUnplug && ${resetBattStats[1]}; then
          sleep ${loopDelay[1]}
          ! not_charging Discharging || {
            resetbs
            resetBattStatsOnUnplug=false
          } 2>/dev/null
        fi
      }
    fi

    mask_capacity

    set +u
    [ -n "${idleApps[0]}" ] \
      && dumpsys activity top | sed -En 's/(.*ACTIVITY )(.*)(\/.*)/\2/p' \
      | tail -n 1 | grep -E "$(echo ${idleApps[*]} | sed 's/ /|/g; s/,/|/g')" >/dev/null \
      && pause_now || :
    [ $(cat /dev/encore_mode 2>/dev/null || cat /data/adb/.config/encore/current_profile 2>/dev/null || print 0) -ne 1 ] || pause_now
    set -u

    # log buffer reset
    [ $(du -k $log | cut -f 1) -lt 256 ] || : > $log

    $isCharging && return 0 || return 1
  }


  ctrl_charging() {

    while :; do

      if is_charging; then

        xIdle=false
        mtReached=false

        # disable charging after a reboot, if min < capacity < max
        if $offMid && [ -f $TMPDIR/.minCapMax ] && _lt_pause_cap && _gt_resume_cap; then
          disable_charging
          force_off
          sleep ${loopDelay[1]}
          rm $TMPDIR/.minCapMax 2>/dev/null || :
          continue
        fi

        # disable charging under <conditions>
        if mt_reached || _ge_pause_cap; then
          if ! $allowIdleAbovePcap && [ $xIdleCount -lt 2 ] && cap_idle_threshold; then
            # if possible, avoid idle mode when capacity > pause_capacity
            (cat $config > $TMPDIR/.cfg
            config=$TMPDIR/.cfg
            prioritizeBattIdleMode=no
            cycle_switches_off
            echo "chargingSwitch=(${chargingSwitch[@]-})" > $TMPDIR/.sw
            force_off)
            chDisabledByAcc=true
            [ $_status != Discharging ] || xIdle=true
          else
            disable_charging
            force_off
          fi
          ! ${resetBattStats[0]} || {
            # reset battery stats on pause
            resetbs
          }
          sleep ${loopDelay[1]}
          rm $TMPDIR/.minCapMax 2>/dev/null || :
          continue
        fi

        # cooldown cycle

        while [ -n "${cooldownRatio[0]-}" ]; do

          if [ $(cat $temp) -ge $(( ${temperature[0]} * 10 )) ] || _ge_cooldown_cap; then
            cooldown=true
          else
            break
          fi

          _lt_pause_cap && [ $(cat $temp) -lt $(( ${temperature[1]} * 10 )) ] && is_charging || break

          if [ -z "${cooldownCurrent-}" ]; then
            dsys_batt set ac 1
            disable_charging
            sleep ${cooldownRatio[1]:-${loopDelay[0]}}
            enable_charging
            sleep ${cooldownRatio[0]:-${loopDelay[0]}}
          else
            (set_ch_curr ${cooldownCurrent:--} || :)
            sleep ${cooldownRatio[1]:-${loopDelay[0]}}
            if [[ .${cooldownCurrent-} = .*% ]]; then
              set_temp_level $tempLevel
            else
              [ -n "${maxChargingCurrent[0]-}" ] || set_ch_curr -
            fi || :
            sleep ${cooldownRatio[0]:-${loopDelay[0]}}
          fi
        done

        cooldown=false
        sleep ${loopDelay[0]}

      else

        if $xIdle && _le_pause_cap; then
          enable_charging
          disable_charging
          xIdle=false
          xIdleCount=$((xIdleCount + 1))
        # enable charging under <conditions>
        elif _le_resume_cap && [ $(cat $temp) -le $(( ${temperature[2]} * 10 )) ]; then
          rm $TMPDIR/.forceoff* 2>/dev/null && sleep ${loopDelay[0]} || :
          enable_charging
        fi

        # auto-shutdown
        if _uptime 900 && not_charging Discharging; then
          if [ ${capacity[0]} -ge 1 ]; then
            # warnings
            ! $shutdownWarnings || {
              if [ ${capacity[0]} -gt 3000 ]; then
                ! [ $(grep -o '^..' $voltNow) -eq $(( ${capacity[0]%??} + 1 )) ] \
                  || ! notif "⚠️ WARNING: ~100mV to auto shutdown, plug the charger!" \
                    || sleep ${loopDelay[1]}
              else
                ! [ $(batt_cap) -eq $(( ${capacity[0]} + 5 )) ] \
                  || ! notif "⚠️ WARNING: 5% to auto shutdown, plug the charger!" \
                    || sleep ${loopDelay[1]}
              fi
              shutdownWarnings=false
            }
            # action
            if _le_shutdown_cap; then
              sleep ${loopDelay[1]}
              ! not_charging Discharging || shutdown
            fi
          fi
        fi
        sleep ${loopDelay[1]}
      fi
      rm $TMPDIR/.minCapMax 2>/dev/null || :
    done
  }


  force_off() {
    local f=$TMPDIR/.forceoff
    rm $f* 2>/dev/null || :
    $forceOff || return 0
    f=$f.$(date +%s)
    touch $f
    set +x
    while [ -f $f ] && _gt_resume_cap; do
      flip_sw off || break
      sleep 1
    done &
    set -x
  }


  mt_reached() {
    [ $(cat $temp) -ge $(( ${temperature[1]} * 10 )) ] && mtReached=true
  }


  pause_now() {
    capacity[3]=$(batt_cap)
    capacity[2]=$((capacity[3] - 5))
  }


  set_dp() {
    local cmd=
    local curr=
    . $config
    while [ -z "${_DPOL-}" ] && $battStatusWorkaround && [ $currFile != $TMPDIR/.dummy-mcc ]; do
      curr=$(cat $currFile)
      if [ $(cat $battStatus) = Charging ]; then
        if [ $curr -gt 0 ]; then
          sdp -
        elif [ $curr -lt 0 ]; then
          sdp +
        else
          /dev/acca --set batt_status_workaround=false
          return 0
        fi
      else
        if [ $curr -gt 0 ]; then
          sdp +
        elif [ $curr -lt 0 ]; then
          sdp -
        else
          /dev/acca --set batt_status_workaround=false
          return 0
        fi
      fi
      set +x
      . $config
    done
    set -x
  }


  shutdown() {
    /system/bin/am start -n android/com.android.internal.app.ShutdownActivity < /dev/null > /dev/null 2>&1 \
      || /system/bin/reboot -p \
      || reboot -p || :
  }


  mask_capacity() {

    is_android || return 0

    isCharging=${isCharging:-false}
    local isCharging_=$isCharging
    local battCap=$(batt_cap)
    local maskedCap=

    if ${capacity[4]} && [ ${capacity[3]} -le 100 ]; then

      if [ ${capacity[0]} -le 0 ]; then
        maskedCap=$(calc $battCap \* 100 / ${capacity[3]} | xargs printf %.f)
      else
        maskedCap=$(calc "($battCap - ${capacity[0]}) * 100 / (${capacity[3]} - ${capacity[0]})" | xargs printf %.f)
      fi

      [ $maskedCap -le 100 ] || maskedCap=100
      [ $maskedCap -ge 2 ] || maskedCap=2

      ! $cooldown || isCharging=true
      $isCharging && dsys_batt set ac 1 || dsys_batt unplug

      isCharging=$isCharging_
      dsys_batt set level $maskedCap
      dsys_batt set temp $(cat $temp)

    else
      dsys_batt reset >/dev/null
    fi
  }


  # load generic functions
  . $execDir/misc-functions.sh


  xIdle=false
  xIdleCount=0
  chDisabledByAcc=false
  chgStatusCode=""
  cooldown=false
  dischgStatusCode=""
  isAccd=true
  mtReached=false
  resetBattStatsOnPlug=false
  resetBattStatsOnUnplug=false
  restrictCurr=false
  shutdownWarnings=true
  unsolicitedResumes=0
  versionCode=$(sed -n s/versionCode=//p $execDir/module.prop 2>/dev/null || :)


  if [ "${1:-y}" = -x ]; then
    log=/sdcard/Download/accd-${device}.log
    persistLog=true
    shift
  else
    log=$TMPDIR/accd-${device}.log
    persistLog=false
  fi


  # verbose
  [ -z "${LINENO-}" ] || export PS4='$LINENO: '
  echo "###$(date)###" >> $log
  exec >> $log 2>&1
  set -x


  misc_stuff "${1-}"
  . $execDir/oem-custom.sh
  . $config
  currentWorkaround0=$currentWorkaround


  apply_on_boot
  touch $TMPDIR/.minCapMax
  rm $TMPDIR/.testingsw 2>/dev/null || :
  ctrl_charging
  exit $?


else


  args="$(echo "$@" | sed -E 's/(--init|-i)//g')"


  # filter out missing and problematic charging switches (those with unrecognized values)

  filter_sw() {
    local over3=false
    [ $# -gt 3 ] && over3=true
    for f in $(echo $1); do
      if [ -f "$f" ] && chmod a+r $f 2>/dev/null \
        && {
          ! cat $f > /dev/null 2>&1 \
          || [ -z "$(cat $f 2>/dev/null)" ] \
          || grep -Eiq '^([0-9]+|0 0|0 1|(en|dis)abl(e|ed))$' $f
        }
      then
        $over3 && printf "$f $2 $3 " || printf "$f $2 $3\n"
      else
        return 1
      fi
    done
  }


  # log
  mkdir -p $TMPDIR $dataDir/logs
  exec > $dataDir/logs/init.log 2>&1
  set -x


  # prepare executables

  ln -fs $execDir/${id}.sh /dev/$id
  ln -fs $execDir/${id}.sh /dev/${id}d,
  ln -fs $execDir/${id}.sh /dev/${id}d.
  ln -fs $execDir/${id}a.sh /dev/${id}a
  ln -fs $execDir/service.sh /dev/${id}d

  mkdir -p $TMPDIR

  ln -fs $execDir/${id}.sh $TMPDIR/$id
  ln -fs $execDir/${id}.sh $TMPDIR/${id}d,
  ln -fs $execDir/${id}.sh $TMPDIR/${id}d.
  ln -fs $execDir/${id}a.sh $TMPDIR/${id}a
  ln -fs $execDir/service.sh $TMPDIR/${id}d

  if [ -d /sbin ]; then
    if grep -q '^tmpfs / ' /proc/mounts; then
      /system/bin/mount -o remount,rw / \
        || mount -o remount,rw /
    fi
    for h in $TMPDIR/$id \
      $TMPDIR/${id}d, $TMPDIR/${id}d. \
      $TMPDIR/${id}a $TMPDIR/${id}d
    do
      ln -fs $h /sbin/ 2>/dev/null || break
    done
  fi


  # fix Termux's PATH (missing /sbin/)
  termuxSu=/data/data/com.termux/files/usr/bin/su
  grep -q 'PATH=.*/sbin/su' $termuxSu 2>/dev/null && {
    sed '\|PATH=|s|/sbin/su|/sbin|' $termuxSu > ${termuxSu}.tmp
    cat ${termuxSu}.tmp > $termuxSu # preserves attributes
    rm ${termuxSu}.tmp
  }


  # whitelist MTK-specific switch, if necessary
  if test -f /proc/mtk_battery_cmd/current_cmd \
    && ! test -f /proc/mtk_battery_cmd/en_power_path \
    && grep -q "^#/proc/mtk" $execDir/ctrl-files.sh
  then
    sed -i '/^#\/proc\/mtk/s/#//' $execDir/ctrl-files.sh
  fi


  cd /sys/class/power_supply/
  : > $TMPDIR/ch-switches_
  : > $TMPDIR/ch-switches__

  for f in $TMPDIR/plugins/ctrl-files.sh \
    ${execDir}-data/plugins/ctrl-files.sh \
    $execDir/ctrl-files.sh
  do
    [ -f $f ] && . $f && break
  done

  ls_ch_switches | grep -Ev '^#|^$|num_system_temp' | \
    while IFS= read -r chargingSwitch; do
      set -f
      set -- $chargingSwitch
      set +f
      [ $# -lt 3 ] && continue
      if [ $# -gt 3 ]; then
        while [ $# -ge 3 ]; do
          if ! filter_sw "$@" >> $TMPDIR/ch-switches__; then
            rm $TMPDIR/ch-switches__
            break
          fi
          [ $# -lt 3 ] || shift 3
        done
        [ -f $TMPDIR/ch-switches__ ] \
          && cat $TMPDIR/ch-switches__ >> $TMPDIR/ch-switches_ \
          && rm $TMPDIR/ch-switches__
      else
        filter_sw "$@" >> $TMPDIR/ch-switches_
      fi
      echo >> $TMPDIR/ch-switches_
    done

  ls_ch_switches | grep num_system_temp | \
    while IFS= read -r chargingSwitch; do
      chsw=($chargingSwitch)
      [ -f ${chsw[0]} ] || continue
      chsw[2]=$(cat ${chsw[2]})
      [ -n "${chsw[2]}" ] || continue
      echo "${chsw[*]}" >> $TMPDIR/ch-switches_
      for i in 1 2; do
        echo "${chsw[0]} ${chsw[1]} $((chsw[2] - i))" >> $TMPDIR/ch-switches_
      done
    done

  cat $dataDir/logs/parsed.log 2>/dev/null >> $TMPDIR/ch-switches_
  sed -i -e 's/ $//' -e '/^$/d' $TMPDIR/ch-switches_


  # read charging voltage control files
  rm $TMPDIR/.mcc-read 2>/dev/null
  : > $TMPDIR/ch-volt-ctrl-files_
  ls -1 $(ls_volt_ctrl_files | grep -Ev '^#|^$') 2>/dev/null | \
    while read file; do
      chmod a+r $file 2>/dev/null && grep -Eq '^4[1-4][0-9]{2}' $file || continue
      grep -q '.... ....' $file && continue
      echo ${file}::$(sed -n 's/^..../v/p' $file)::$(cat $file) \
        >> $TMPDIR/ch-volt-ctrl-files_
    done
  grep -q / $TMPDIR/ch-volt-ctrl-files_ || rm $TMPDIR/ch-volt-ctrl-files_


  # exclude troublesome ctrl files
  for file in $TMPDIR/ch-*_; do
    sort -u $file | grep -Eiv 'parallel|::-|bq[0-9].*/current_max' > ${file%_}
    rm $file
  done


  # prepare default config help text and version code for oem-custom.sh and write-config.sh
  sed -n '/^# /,$p' $execDir/default-config.txt > $TMPDIR/.config-help
  sed -n '/^configVerCode=/s/.*=//p' $execDir/default-config.txt > $TMPDIR/.config-ver


  # preprocess battery interface
  . $execDir/batt-interface.sh


  # start $id daemon
  rm $TMPDIR/.ghost-charging 2>/dev/null
  if [ -f $TMPDIR/.install-notes ]; then
    $TMPDIR/acca $config --notif "$(cat $TMPDIR/.install-notes)"
    mv -f $TMPDIR/.install-notes $TMPDIR/.updated
  fi 2>/dev/null
  exec $0 $args
fi

exit 0
