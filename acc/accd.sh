#!/system/bin/sh
# Advanced Charging Controller Daemon (accd)
# Copyright 2017-2021, VR25
# License: GPLv3+
#
# devs: triple hashtags (###) mark non-generic code


. $execDir/acquire-lock.sh


case "$1" in
  -i|--init) init=true; shift;;
  *) [ -f $TMPDIR/.config-ver ] && init=false || init=true;; ###
esac


# wait until data is decrypted and system is ready
until [ -d /sdcard/Android ]
do
  sleep 30
done
pgrep zygote > /dev/null && {
  until [ .$(getprop sys.boot_completed) = .1 ]
  do
    sleep 30
  done
}


if ! $init; then


  _ge_cooldown_cap() {
    if t ${capacity[1]} -gt 3000; then
      t $(grep -o '^....' $voltage_now) -ge ${capacity[1]}
    else
      t $(cat $batt/capacity) -ge ${capacity[1]}
    fi
  }


  _ge_pause_cap() {
    if t ${capacity[3]} -gt 3000; then
      t $(grep -o '^....' $voltage_now) -ge ${capacity[3]}
    else
      t $(cat $batt/capacity) -ge ${capacity[3]}
    fi
  }


  _lt_pause_cap() {
    if t ${capacity[3]} -gt 3000; then
      t $(grep -o '^....' $voltage_now) -lt ${capacity[3]}
    else
      t $(cat $batt/capacity) -lt ${capacity[3]}
    fi
  }


  _gt_resume_cap() {
    if t ${capacity[2]} -gt 3000; then
      t $(grep -o '^....' $voltage_now) -gt ${capacity[2]}
    else
      t $(cat $batt/capacity) -gt ${capacity[2]}
    fi
  }


  _le_resume_cap() {
    if t ${capacity[2]} -gt 3000; then
      t $(grep -o '^....' $voltage_now) -le ${capacity[2]}
    else
      t $(cat $batt/capacity) -le ${capacity[2]}
    fi
  }


  _le_shutdown_cap() {
    if t ${capacity[0]} -gt 3000; then
      t $(grep -o '^....' $voltage_now) -le ${capacity[0]}
    else
      t $(cat $batt/capacity) -le ${capacity[0]}
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
    exit $exitCode
  }


  is_charging() {

    local file=
    local value=
    local isCharging=false

    . $config
    not_charging || isCharging=true

    # run custom code
    eval "${loopCmd[@]-}"

    # shutdown if battery temp >= shutdown_temp
    [ $(cat $temp) -lt $(( ${temperature[3]} * 10 )) ] || {
      am start -n android/com.android.internal.app.ShutdownActivity < /dev/null > /dev/null 2>&1 \
        || reboot -p 2>/dev/null \
          || /system/bin/reboot -p || :
    }

    if $isCharging; then

      # read chgStatusCode once
      [ -n "$chgStatusCode" ] || {
        cmd_batt reset
        chgStatusCode=$(dumpsys battery 2>/dev/null | sed -n 's/^  status: //p') || :
        ! ${capacity[4]} || capacitySync=true
      }

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

    else

      [ -z "${chargingDisabled-}" ] || chargingDisabled=false

      # read dischgStatusCode once
      #   and dynamically enable/disable capacitySync
      [ -n "$dischgStatusCode" ] || {
        ! cmd_batt reset || {
          ! dischgStatusCode=$(dumpsys battery 2>/dev/null | sed -n 's/^  status: //p') || {
            if ${capacity[4]} || { [ $(dumpsys battery 2>/dev/null | sed -n 's/^  level: //p') -ne $(cat $batt/capacity) ] \
              && sleep 2 \
              &&  [ $(dumpsys battery 2>/dev/null | sed -n 's/^  level: //p') -ne $(cat $batt/capacity) ]; }
            then
              capacitySync=true
            fi
          }
        }
      }

      if ! $cooldown; then

        # resetBattStatsOnUnplug
        if $resetBattStatsOnUnplug && ${resetBattStats[1]}; then
          sleep ${loopDelay[1]}
          ! not_charging dis || {
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
    local i=

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
        if ! $maxTempPause && [ $(cut -d '.' -f 1 /proc/uptime) -ge 900 ] && not_charging dis; then
          if [ ${capacity[0]} -ge 1 ]; then
            # warnings
            if ${shutdownWarnings:-false} || [ -f $data_dir/warn ]; then
              if t ${capacity[0]} -gt 3000; then
                i=2
                ! t $(grep -o '^..' $voltage_now) -eq $(( ${capacity[0]%??} + i )) \
                  || su -lp 2000 -c "cmd notification post -S bigtext -t 'ACC' 'Tag' \"WARNING: $(grep -o '^....' $voltage_now | sed 's/^.//' | sed "s/^./$i/")mV to auto shutdown, plug the charger!\"" \
                  && sleep ${loopDelay[1]} || :
              else
                for i in 5 10; do
                  ! t $(cat $batt/capacity) -eq $(( ${capacity[0]} + i )) \
                    || su -lp 2000 -c "cmd notification post -S bigtext -t 'ACC' 'Tag' \"WARNING: ${i}% to auto shutdown, plug the charger!\"" \
                    && sleep ${loopDelay[1]} || :
                done
              fi
            fi
            # action
            if _le_shutdown_cap; then
              sleep ${loopDelay[1]}
              ! not_charging dis \
                || am start -n android/com.android.internal.app.ShutdownActivity < /dev/null > /dev/null 2>&1 \
                || reboot -p 2>/dev/null \
                || /system/bin/reboot -p || :
            fi
          fi
        fi

        sleep ${loopDelay[1]}

      fi
    done
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
  resetBattStatsOnUnplug=false


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
  echo "versionCode=$(sed -n s/versionCode=//p $execDir/module.prop 2>/dev/null)" >> $log
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


  mkdir -p $TMPDIR $data_dir/logs


  # log
  exec > $data_dir/logs/init.log 2>&1
  set -x


  # prepare executables ###

  #legacy
  ln -fs $execDir/${id}.sh /dev/$id
  ln -fs $execDir/${id}.sh /dev/${id}d,
  ln -fs $execDir/${id}.sh /dev/${id}d.
  ln -fs $execDir/${id}a.sh /dev/${id}a
  ln -fs $execDir/service.sh /dev/${id}d

  mkdir -p /dev/.$domain/$id

  ln -fs $execDir/${id}.sh /dev/.$domain/$id/$id
  ln -fs $execDir/${id}.sh /dev/.$domain/$id/${id}d,
  ln -fs $execDir/${id}.sh /dev/.$domain/$id/${id}d.
  ln -fs $execDir/${id}a.sh /dev/.$domain/$id/${id}a
  ln -fs $execDir/service.sh /dev/.$domain/$id/${id}d
  ln -fs $execDir/uninstall.sh /dev/.$domain/$id/uninstall

  if [ -d /sbin ]; then
    if grep -q '^tmpfs / ' /proc/mounts; then
      /system/bin/mount -o remount,rw / \
        || mount -o remount,rw /
    fi
    for h in /dev/.$domain/$id/$id \
        /dev/.$domain/$id/${id}d, /dev/.$domain/$id/${id}d. \
      /dev/.$domain/$id/${id}a /dev/.$domain/$id/${id}d
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
    && grep -q "^#/proc/mtk" $execDir/charging-switches.txt
  then
    sed -i '/^#\/proc\/mtk/s/#//' $execDir/charging-switches.txt
  fi


  # filter out missing and problematic charging switches (those with unrecognized values) ###

  filter_sw() {
    local over3=false
    [ $# -gt 3 ] && over3=true
    for f in $(echo $1); do
      if [ -f "$f" ] && chmod 0644 $f 2>/dev/null \
        && {
          ! cat $f > /dev/null 2>&1 \
          || [ -z "$(cat $f 2>/dev/null)" ] \
          || grep -Eiq '^(1|0|0 0|0 1|(en|dis)abled?)$' $f
        }
      then
        $over3 && printf "$f $2 $3 " || printf "$f $2 $3\n"
      else
        return 1
      fi
    done
  }

  cd /sys/class/power_supply/
  : > $TMPDIR/ch-switches_
  : > $TMPDIR/ch-switches__
  grep -Ev '^#|^$' $execDir/charging-switches.txt | \
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


  # read charging voltage control files ###
  grep -q / $TMPDIR/ch-volt-ctrl-files 2>/dev/null || {
    : > $TMPDIR/ch-volt-ctrl-files_
    ls -1 */constant_charge_voltage* */voltage_max \
      */batt_tune_float_voltage */fg_full_voltage 2>/dev/null | \
        while read file; do
          chmod 0644 $file 2>/dev/null && grep -Eq '^4[1-4][0-9]{2}' $file || continue
          grep -q '.... ....' $file && continue
          echo ${file}::$(sed -n 's/^..../v/p' $file)::$(cat $file) \
            >> $TMPDIR/ch-volt-ctrl-files_
        done
  }


  # read charging current control files (part 1) ###
  # part 2 runs while charging only

  if [ ! -f $TMPDIR/.ch-curr-read ] \
    || ! grep -q / $TMPDIR/ch-curr-ctrl-files 2>/dev/null
  then
    : > $TMPDIR/ch-curr-ctrl-files_
    ls -1 */input_current_limited */restrict*_ch*g* \
      /sys/class/qcom-battery/restrict*_ch*g* 2>/dev/null | \
      while read file; do
        chmod 0644 $file 2>/dev/null || continue
        grep -q '^[01]$' $file && echo ${file}::1::0 >> $TMPDIR/ch-curr-ctrl-files
      done

    ls -1 */constant_charge_current_max \
      */restrict*_cur* \
      /sys/class/qcom-battery/restrict*_cur* \
      */batt_tune_*_charge_current */ac_input \
      */mhl_2000_charge */mhl_2000_input \
      */hv_charge */ac_charge \
      */batt_tune_chg_limit_cur */so_limit_input \
      */so_limit_charge */car_input */sdp_input \
      */aca_charge */sdp_charge */aca_input \
      *dcp_input */wc_input */car_charge \
      */dcp_charge */wc_charge 2>/dev/null | \
        while read file; do
          chmod 0644 $file 2>/dev/null || continue
          defaultValue=$(cat $file)
          ampFactor=$(sed -n 's/^ampFactor=//p' $data_dir/config.txt 2>/dev/null)
          [ -n "$ampFactor" -o $defaultValue -ne 0 ] || continue
          if [ "${ampFactor:-1}" -eq 1000 -o $defaultValue -lt 10000 ]; then
            # milliamps
            echo ${file}::v::$defaultValue \
              >> $TMPDIR/ch-curr-ctrl-files_
          else
            # microamps
            echo ${file}::v000::$defaultValue \
              >> $TMPDIR/ch-curr-ctrl-files_
          fi
        done
  fi


  # remove duplicates and parallel/ ctrl files
  for file in $TMPDIR/ch-*_; do
    sort -u $file | grep -iv parallel > ${file%_}
    rm $file
  done


  # prepare default config help text and version code for oem-custom.sh and write-config.sh
  sed -n '/^# /,$p' $execDir/default-config.txt > $TMPDIR/.config-help
  sed -n '/^configVerCode=/s/.*=//p' $execDir/default-config.txt > $TMPDIR/.config-ver


  # start $id daemon
  rm /dev/.$domain/$id/.ghost-charging 2>/dev/null ###
  exec $0 "$@"
fi

exit 0
