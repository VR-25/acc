#!/system/bin/sh
# Advanced Charging Controller Daemon (accd)
# Copyright 2017-2022, VR25
# License: GPLv3+


. $execDir/acquire-lock.sh


init=false

case "$1" in
  -i|--init) init=true; shift;;
  *) [ -f $TMPDIR/.config-ver ] || init=true;;
esac


# wait until data is decrypted and system is ready

until [ -d /sdcard/Android ]; do
  sleep 30
done

until [ .$(getprop sys.boot_completed) = .1 ]; do
  sleep 30
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
    fi
    cd /
    echo versionCode=$versionCode
    exit $exitCode
  }


  is_charging() {

    local file=
    local value=
    local isCharging=false

    . $config
    not_charging || isCharging=true

    # dynamically toggle capacitySync
    if ${capacity[4]} || ${capacity[5]}; then
      capacitySync=true
    else
      cmd_batt reset
      capacitySync=false
    fi

    # run custom code
    (set +eux
    eval "${loopCmd[@]-}"
    eval "${loopCmd_-}") || :

    # shutdown if battery temp >= shutdown_temp
    [ $(cat $temp) -lt $(( ${temperature[3]} * 10 )) ] || shutdown

    if $isCharging; then

      # set chgStatusCode and capacitySync
      if [ -z "$chgStatusCode" ] && cmd_batt reset \
        && chgStatusCode=$(dumpsys battery 2>/dev/null | sed -n 's/^  status: //p')
      then
        setup_capacity_sync
        start-stop-daemon -bx $TMPDIR/.bg-dexopt-job.sh -S -- 2>/dev/null || :
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

      $cooldown || resetBattStatsOnUnplug=true
      ${chargingDisabled:-false} || apply_on_plug
      [ -z "${chargingDisabled-}" ] || enable_charging

      shutdownWarnings=true

    else

      [ -z "${chargingDisabled-}" ] || chargingDisabled=false

      # set dischgStatusCode and capacitySync
      if [ -z "$dischgStatusCode" ] && cmd_batt reset \
        && dischgStatusCode=$(dumpsys battery 2>/dev/null | sed -n 's/^  status: //p')
      then
        setup_capacity_sync
      fi

      if ! $cooldown; then

        # resetBattStatsOnUnplug
        if $resetBattStatsOnUnplug && ${resetBattStats[1]}; then
          sleep ${loopDelay[1]}
          ! not_charging Discharging || {
            dumpsys batterystats --reset < /dev/null > /dev/null 2>&1 || :
            rm /data/system/batterystats* || :
            resetBattStatsOnUnplug=false
          } 2>/dev/null
        fi
      fi
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

        # disable charging under <conditions>
        test $(cat $temp) -ge $(( ${temperature[1]} * 10 )) \
          && maxTempPause=true || maxTempPause=false
        if $maxTempPause || _ge_pause_cap; then
          disable_charging
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

        # enable charging under <conditions>
        if _le_resume_cap; then
          [ ! $(cat $temp) -lt $(( ${temperature[1]} * 10 )) ] \
            || enable_charging
        fi

        # auto-shutdown
        if ! $maxTempPause && [ $(cut -d '.' -f 1 /proc/uptime) -ge 900 ] && not_charging Discharging; then
          if [ ${capacity[0]} -ge 1 ]; then
            # warnings
            ! $shutdownWarnings || {
              if t ${capacity[0]} -gt 3000; then
                ! t $(grep -o '^..' $voltage_now) -eq $(( ${capacity[0]%??} + 1 )) \
                  || ! notif "WARNING: ~100mV to auto shutdown, plug the charger!" \
                    || sleep ${loopDelay[1]}
              else
                ! t $(cat $battCapacity) -eq $(( ${capacity[0]} + 5 )) \
                  || ! notif "WARNING: 5% to auto shutdown, plug the charger!" \
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
    done
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
      || reboot -p 2>/dev/null \
      || /system/bin/reboot -p || :
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
  resetBattStatsOnUnplug=false
  versionCode=$(sed -n s/versionCode=//p $execDir/module.prop 2>/dev/null || :)


  if [ "${1:-y}" = -x ]; then
    log=/sdcard/accd-${device}.log
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


  voltage_now=$batt/voltage_now
  t -f $voltage_now || voltage_now=$batt/batt_vol
  if ! t -f $voltage_now; then
    echo 3920 > $TMPDIR/.voltage_now
    voltage_now=$TMPDIR/.voltage_now
  fi


  apply_on_boot

  # disable charging after a reboot, if min < capacity < max
  if _lt_pause_cap && _gt_resume_cap; then
    disable_charging
  fi

  ctrl_charging
  exit $?


else


  # filter out missing and problematic charging switches (those with unrecognized values)

  filter_sw() {
    local over3=false
    [ $# -gt 3 ] && over3=true
    for f in $(echo $1); do
      if [ -f "$f" ] && chmod 0644 $f 2>/dev/null \
        && {
          ! cat $f > /dev/null 2>&1 \
          || [ -z "$(cat $f 2>/dev/null)" ] \
          || grep -Eiq '^(1|0|0 0|0 1|(en|dis)able?)$' $f
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
  list_ch_switches | grep -Ev '^#|^$' | \
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
          shift 3 2>/dev/null
        done
        [ -f $TMPDIR/ch-switches__ ] \
          && cat $TMPDIR/ch-switches__ >> $TMPDIR/ch-switches_ \
          && rm $TMPDIR/ch-switches__
      else
        filter_sw "$@" >> $TMPDIR/ch-switches_
      fi
      echo >> $TMPDIR/ch-switches_
    done
  sed -i -e 's/ $//' -e '/^$/d' $TMPDIR/ch-switches_


  # read charging voltage control files
  : > $TMPDIR/ch-volt-ctrl-files_
  ls -1 $(list_volt_ctrl_files | grep -Ev '^#|^$') 2>/dev/null | \
    while read file; do
      chmod 0644 $file 2>/dev/null && grep -Eq '^4[1-4][0-9]{2}' $file || continue
      grep -q '.... ....' $file && continue
      echo ${file}::$(sed -n 's/^..../v/p' $file)::$(cat $file) \
        >> $TMPDIR/ch-volt-ctrl-files_
    done


  # read charging current control files (part 1)
  # part 2 runs while charging only

  rm $TMPDIR/.ch-curr-read 2>/dev/null
  : > $TMPDIR/ch-curr-ctrl-files_
  ls -1 $(list_curr_ctrl_files_boolean | grep -Ev '^#|^$') 2>/dev/null | \
    while read file; do
      chmod 0644 $file 2>/dev/null || continue
      grep -q '^[01]$' $file && echo ${file}::1::0 >> $TMPDIR/ch-curr-ctrl-files
    done

  ls -1 $(list_curr_ctrl_files_static | grep -Ev '^#|^$') 2>/dev/null | \
    while read file; do
      chmod 0644 $file 2>/dev/null || continue
      defaultValue=$(cat $file)
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


  # remove duplicates and parallel/ ctrl files
  for file in $TMPDIR/ch-*_; do
    sort -u $file | grep -iv parallel > ${file%_}
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
  exec $0 "$@"
fi

exit 0
