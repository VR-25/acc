#!/system/bin/sh
# Advanced Charging Controller Daemon (accd)
# Copyright 2017-2022, VR25
# License: GPLv3+


. $execDir/acquire-lock.sh


init=false

case "$*" in
  *-i*) init=true;;
  *) [ -f $TMPDIR/.config-ver ] || init=true;;
esac


# wait until Android has fully booted

until [ .$(getprop sys.boot_completed 2>/dev/null) = .1 ]; do
  sleep 10
done


if ! $init; then


  _ge_cooldown_cap() {
    if t ${capacity[1]} -gt 3000; then
      t $(grep -o '^....' $voltage_now) -ge ${capacity[1]}
    else
      t $(cat $battCapacity) -ge ${capacity[1]}
    fi
  }


  _ge_pause_cap() {
    if t ${capacity[3]} -gt 3000; then
      t $(grep -o '^....' $voltage_now) -ge ${capacity[3]}
    else
      t $(cat $battCapacity) -ge ${capacity[3]}
    fi
  }


  _lt_pause_cap() {
    if t ${capacity[3]} -gt 3000; then
      t $(grep -o '^....' $voltage_now) -lt ${capacity[3]}
    else
      t $(cat $battCapacity) -lt ${capacity[3]}
    fi
  }


  _gt_resume_cap() {
    if t ${capacity[2]} -gt 3000; then
      t $(grep -o '^....' $voltage_now) -gt ${capacity[2]}
    else
      t $(cat $battCapacity) -gt ${capacity[2]}
    fi
  }


  _le_resume_cap() {
    if t ${capacity[2]} -gt 3000; then
      t $(grep -o '^....' $voltage_now) -le ${capacity[2]}
    else
      t $(cat $battCapacity) -le ${capacity[2]}
    fi
  }


  _le_shutdown_cap() {
    if t ${capacity[0]} -gt 3000; then
      t $(grep -o '^....' $voltage_now) -le ${capacity[0]}
    else
      t $(cat $battCapacity) -le ${capacity[0]}
    fi
  }


  exxit() {
    exitCode=$?
    $persistLog && set +eu || set +eux
    trap - EXIT
    [ -n "$1" ] && exitCode=$1
    [ -n "$2" ] && print "$2"
    $persistLog || exec > /dev/null 2>&1
    cmd_batt reset
    grep -Ev '^$|^#' $config > $TMPDIR/.config
    config=$TMPDIR/.config
    apply_on_boot default
    apply_on_plug default
    enable_charging
    if tt "$exitCode" "[127]"; then
      . $execDir/logf.sh
      logf --export
      notif "⚠️ Daemon stopped with exit code $exitCode!"
    fi
    cd /
    echo versionCode=$versionCode
    exit $exitCode
  }


  is_charging() {

    local file=
    local value=
    local isCharging=false

    src_cfg
    not_charging || isCharging=true

    # dynamically toggle capacitySync
    if ${capacity[4]} || ${capacity[5]}; then
      capacitySync=true
    elif $capacitySync; then
      cmd_batt reset
      capacitySync=false
    fi

    # schedules and custom loops
      (set +eu

      schedTime=$(date +%H%M)
      schedScript=$TMPDIR/.${schedTime}_schedScript.sh
      if [ ! -f $schedScript ] && echo "${schedules-}" | grep "$schedTime " >/dev/null; then
        echo "$schedules" | sed -n "s|^$schedTime |#!/system/bin/sh\n|p" > $schedScript
        echo "sleep 60; rm $schedScript; exit" >> $schedScript
        chmod +x $schedScript
        start-stop-daemon -bx $schedScript -S --
      fi

      set +x
      eval '${loopCmd-}'
      eval '${loopCmd_-}') || :

    # shutdown if battery temp >= shutdown_temp
    [ $(cat $temp) -lt $(( ${temperature[3]} * 10 )) ] || shutdown

    if $isCharging; then

      # set chgStatusCode and capacitySync
      if [ -z "$chgStatusCode" ] && cmd_batt reset \
        && chgStatusCode=$(dumpsys battery 2>/dev/null | sed -n 's/^  status: //p')
      then
        setup_capacity_sync
        if [ ! -f $TMPDIR/.dexopt.done ] && _uptime 900; then
          start-stop-daemon -bx $TMPDIR/.bg-dexopt-job.sh -S -- 2>/dev/null || :
          touch $TMPDIR/.dexopt.done
        fi
      fi

      # read charging current ctrl files (part 2) once
      $chCurrRead || {
        if [ ! -f $TMPDIR/.ch-curr-read ] \
          || ! grep -q / $TMPDIR/ch-curr-ctrl-files 2>/dev/null
        then
          . $execDir/read-ch-curr-ctrl-files-p2.sh
          chCurrRead=true
        fi
      }

      $cooldown || {
        resetBattStatsOnUnplug=true
        if $resetBattStatsOnPlug && ${resetBattStats[2]}; then
          sleep ${loopDelay[0]}
          not_charging || {
            dumpsys batterystats --reset < /dev/null > /dev/null 2>&1 || :
            rm /data/system/batterystats* || :
            resetBattStatsOnPlug=false
          } 2>/dev/null
        fi
      }

      ${chargingDisabled:-false} || apply_on_plug
      [ -z "${chargingDisabled-}" ] || enable_charging

      shutdownWarnings=true

    else

      $rebootResume \
        && ${chargingDisabled:-false} \
        && le_resume_cap \
        && [ $(cat $temp) -lt $(( ${temperature[1]} * 10 )) ] && {
          notif "⚠️ System will reboot in 60 seconds to re-enable charging! Stop accd to abort."
          sleep 60
          ! not_charging || {
            /system/bin/reboot || reboot
          }
        } || :

      [ -z "${chargingDisabled-}" ] || chargingDisabled=false

      # set dischgStatusCode and capacitySync
      if [ -z "$dischgStatusCode" ] && cmd_batt reset \
        && dischgStatusCode=$(dumpsys battery 2>/dev/null | sed -n 's/^  status: //p')
      then
        setup_capacity_sync
      fi

      $cooldown || {
        resetBattStatsOnPlug=true
        if $resetBattStatsOnUnplug && ${resetBattStats[1]}; then
          sleep ${loopDelay[1]}
          ! not_charging Discharging || {
            dumpsys batterystats --reset < /dev/null > /dev/null 2>&1 || :
            rm /data/system/batterystats* || :
            resetBattStatsOnUnplug=false
          } 2>/dev/null
        fi
      }
    fi

    sync_capacity

    # log buffer reset
    [ $(du -k $log | cut -f 1) -lt 256 ] || : > $log

    $isCharging && return 0 || return 1
  }


  ctrl_charging() {

    local count=0

    while :; do

      if is_charging; then

        # disable charging after a reboot, if min < capacity < max
        if $offMid && [ -f $TMPDIR/.minCapMax ] && _lt_pause_cap && _gt_resume_cap; then
          disable_charging
          force_off
          sleep ${loopDelay[1]}
          continue
        fi

        # disable charging under <conditions>
        test $(cat $temp) -ge $(( ${temperature[1]} * 10 )) \
          && maxTempPause=true || maxTempPause=false
        if $maxTempPause || _ge_pause_cap; then
          if [ $(cat $battCapacity) -gt ${capacity[3]} ]; then
            # if possible, avoid idle mode when capacity > pause_capacity
            (cat $config > $TMPDIR/.cfg
            config=$TMPDIR/.cfg
            cycle_switches off Discharging
            echo "chargingSwitch=(${chargingSwitch[@]-})" > $TMPDIR/.sw)
          else
            disable_charging
            force_off
          fi
          ! ${resetBattStats[0]} || {
            # reset battery stats on pause
            dumpsys batterystats --reset < /dev/null > /dev/null 2>&1 || :
            rm /data/system/batterystats* 2>/dev/null || :
          }
          ! $maxTempPause || ! not_charging || sleep ${temperature[2]}
        fi

        # cooldown cycle
        while [ -n "${cooldownRatio[0]-}${cooldownCustom[0]-}" ] \
          && _lt_pause_cap \
          && is_charging
        do
          if [ $(cat $temp) -ge $(( ${temperature[0]} * 10 )) ] \
            || _ge_cooldown_cap \
            || [ $(sed s/-// ${cooldownCustom[0]:-cooldownCustom} 2>/dev/null || echo 0) -ge ${cooldownCustom[1]:-1} ]
          then
            cooldown=true
            if [ -n "${cooldownCurrent-}" ] && grep -q / $TMPDIR/ch-curr-ctrl-files 2>/dev/null
            then
              # cooldown by limiting current
              cmd_batt set status $chgStatusCode # to prevent unwanted display wakeups
              set +e
              maxChargingCurrent0=${maxChargingCurrent[0]-}
              set_ch_curr ${cooldownCurrent:-0}
              sleep ${cooldownRatio[1]:-1}
              set_ch_curr ${maxChargingCurrent0:--}
              set -e
              $capacitySync || cmd_batt reset
              count=0
              while [ $count -lt ${cooldownRatio[0]:-1} ]
              do
                sleep ${loopDelay[0]}
                _lt_pause_cap \
                  && count=$(( count + ${loopDelay[0]} )) \
                  || break
              done
            else
              # regular cooldown
              cmd_batt set status $chgStatusCode
              disable_charging
              [ $(sed s/-// ${cooldownCustom[0]:-cooldownCustom} 2>/dev/null || echo 0) -ge ${cooldownCustom[1]:-1} ] \
                && sleep ${cooldownCustom[3]:-1} \
                || sleep ${cooldownRatio[1]:-1}
              enable_charging
              $capacitySync || cmd_batt reset
              [ ! $(sed s/-// ${cooldownCustom[0]:-cooldownCustom} 2>/dev/null || echo 0) -ge ${cooldownCustom[1]:-1} ] \
                || cooldownRatio[0]=${cooldownCustom[2]-}
              count=0
              while ! not_charging && [ $count -lt ${cooldownRatio[0]:-1} ]; do
                sleep ${loopDelay[0]}
                _lt_pause_cap \
                  && count=$(( count + ${loopDelay[0]} )) \
                  || break
              done
            fi
          else
            break
          fi
        done

        cooldown=false
        sleep ${loopDelay[0]}

      else

        # set discharge polarity
        if [ -z "${dischargePolarity-}" ] && $battStatusWorkaround \
          && [ $currFile != $TMPDIR/.dummy-curr ] && ! online
        then
          (cmd="$TMPDIR/acca --set discharge_polarity="
          curr=$(cat $currFile)
          if [ $curr -gt 0 ]; then
            eval "$cmd"+
          elif [ $curr -lt 0 ]; then
            eval "$cmd"-
          fi)
        fi

        # enable charging under <conditions>
        if _le_resume_cap; then
          [ ! $(cat $temp) -lt $(( ${temperature[1]} * 10 )) ] \
            || enable_charging
        fi

        # auto-shutdown
        if ! $maxTempPause && _uptime 900 && not_charging Discharging; then
          if [ ${capacity[0]} -ge 1 ]; then
            # warnings
            ! $shutdownWarnings || {
              if t ${capacity[0]} -gt 3000; then
                ! t $(grep -o '^..' $voltage_now) -eq $(( ${capacity[0]%??} + 1 )) \
                  || ! notif "⚠️ WARNING: ~100mV to auto shutdown, plug the charger!" \
                    || sleep ${loopDelay[1]}
              else
                ! t $(cat $battCapacity) -eq $(( ${capacity[0]} + 5 )) \
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
    [ -z "${forceOff-}" ] || {
      touch $TMPDIR/.forceoff
      set +x
      while [ -f $TMPDIR/.forceoff ]; do
        flip_sw off
        sleep $forceOff
      done &
      set -x
    }
  }


  setup_capacity_sync(){
    if ! $capacitySync; then
      if ${capacity[4]} || ${capacity[5]} || \
        { [ $(dumpsys battery 2>/dev/null | sed -n 's/^  level: //p') -ne $(cat $battCapacity) ] \
        && sleep 2 \
        &&  [ $(dumpsys battery 2>/dev/null | sed -n 's/^  level: //p') -ne $(cat $battCapacity) ]; }
      then
        capacitySync=true
      fi
    fi
  }


  shutdown() {
    /system/bin/am start -n android/com.android.internal.app.ShutdownActivity < /dev/null > /dev/null 2>&1 \
      || /system/bin/reboot -p \
      || reboot -p || :
  }


  sync_capacity() {

    ! $capacitySync || {

      isCharging=${isCharging:-false}
      local isCharging_=$isCharging
      local battCap=$(cat $battCapacity)

      ! ${capacity[5]} || {
        if [ ${capacity[3]} -gt 3000 ]; then
          local maskedCap=$battCap
        else
          local capFactor=$(calc 100 / ${capacity[3]})
          local maskedCap=$(calc $battCap \* $capFactor | xargs printf %.f)
          [ $maskedCap -le 100 ] || maskedCap=100
        fi
      }

      ! $cooldown || isCharging=true

      if $isCharging; then
        cmd_batt set ac 1
        cmd_batt set status $chgStatusCode
      else
        cmd_batt unplug
        cmd_batt set status $dischgStatusCode
      fi

      isCharging=$isCharging_

      [ $battCap -lt 2 ] || {
        if ${capacity[5]}; then
          cmd_batt set level $maskedCap
        else
          cmd_batt set level $battCap
        fi
      }
    }
  }


  _uptime() {
    [ $(cut -d '.' -f 1 /proc/uptime) -ge $1 ]
  }


  # load generic functions
  . $execDir/misc-functions.sh


  isAccd=true
  cooldown=false
  chCurrRead=false
  chgStatusCode=""
  capacitySync=false
  dischgStatusCode=""
  maxTempPause=false
  shutdownWarnings=true
  resetBattStatsOnPlug=false
  resetBattStatsOnUnplug=false
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
  src_cfg


  voltage_now=$batt/voltage_now
  t -f $voltage_now || voltage_now=$batt/batt_vol
  if ! t -f $voltage_now; then
    echo 3900 > $TMPDIR/.voltage_now
    voltage_now=$TMPDIR/.voltage_now
  fi


  apply_on_boot
  touch $TMPDIR/.minCapMax
  ctrl_charging
  exit $?


else


  args="$(echo "$@" | sed -E 's/(--init|-i)//g')"


  # filter out missing and problematic charging switches (those with unrecognized values)

  filter_sw() {
    local over3=false
    [ $# -gt 3 ] && over3=true
    for f in $(echo $1); do
      if [ -f "$f" ] && chmod u+w $f 2>/dev/null \
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

  #legacy
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
  ln -fs $execDir/uninstall.sh $TMPDIR/uninstall

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
  ls_ch_switches | grep -Ev '^#|^$' | \
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
  cat $dataDir/logs/parsed.log 2>/dev/null >> $TMPDIR/ch-switches_
  sed -i -e 's/ $//' -e '/^$/d' $TMPDIR/ch-switches_


  # read charging voltage control files
  : > $TMPDIR/ch-volt-ctrl-files_
  ls -1 $(ls_volt_ctrl_files | grep -Ev '^#|^$') 2>/dev/null | \
    while read file; do
      chmod u+w $file 2>/dev/null && grep -Eq '^4[1-4][0-9]{2}' $file || continue
      grep -q '.... ....' $file && continue
      echo ${file}::$(sed -n 's/^..../v/p' $file)::$(cat $file) \
        >> $TMPDIR/ch-volt-ctrl-files_
    done


  # read charging current control files (part 1)
  # part 2 runs while charging only

  rm $TMPDIR/.ch-curr-read 2>/dev/null
  : > $TMPDIR/ch-curr-ctrl-files_
  ls -1 $(ls_curr_ctrl_files_boolean | grep -Ev '^#|^$') 2>/dev/null | \
    while read file; do
      chmod u+w $file 2>/dev/null || continue
      grep -q '^[01]$' $file && echo ${file}::1::0 >> $TMPDIR/ch-curr-ctrl-files
    done

  ls -1 $(ls_curr_ctrl_files_static | grep -Ev '^#|^$') 2>/dev/null | \
    while read file; do
      chmod u+w $file 2>/dev/null || continue
      defaultValue=$(cat $file)
      [ -n "$defaultValue" ] || continue
      ampFactor=$(sed -n 's/^ampFactor=//p' $dataDir/config.txt 2>/dev/null)
      [ -n "$ampFactor" -o $defaultValue -ne 0 ] || continue
      if [ "${ampFactor:-1}" -eq 1000 -o ${defaultValue#-} -lt 10000 ]; then
        # milliamps
        echo ${file}::v::$defaultValue \
          >> $TMPDIR/ch-curr-ctrl-files_
      else
        # microamps
        echo ${file}::v000::$defaultValue \
          >> $TMPDIR/ch-curr-ctrl-files_
      fi
    done


  # exclude duplicates and parallel/ ctrl files
  for file in $TMPDIR/ch-*_; do
    sort -u $file | grep -iv parallel > ${file%_}
    sed -i /::-/d ${file%_} # exclude ctrl files with negative values
    rm $file
  done


  # prepare default config help text and version code for oem-custom.sh and write-config.sh
  sed -n '/^# /,$p' $execDir/default-config.txt > $TMPDIR/.config-help
  sed -n '/^configVerCode=/s/.*=//p' $execDir/default-config.txt > $TMPDIR/.config-ver


  # preprocess battery interface
  . $execDir/batt-interface.sh

  # prepare bg-dexopt-job wrapper
  printf "#!/system/bin/sh\n/system/bin/cmd package bg-dexopt-job < /dev/null > /dev/null 2>&1" > $TMPDIR/.bg-dexopt-job.sh
  chmod +x $TMPDIR/.bg-dexopt-job.sh

  # start $id daemon
  rm $TMPDIR/.ghost-charging 2>/dev/null
  exec $0 $args
fi

exit 0
