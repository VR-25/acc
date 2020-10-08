#!/system/bin/sh
# Advanced Charging Controller Daemon (accd)
# Copyright 2017-2020, VR25
# License: GPLv3+
#
# devs: triple hashtags (###) mark non-generic code


# wait until the system is ready and data is decrypted
pgrep zygote > /dev/null && {
  until [ -d /sdcard/Download ] \
    && [ .$(getprop sys.boot_completed) = .1 ]
  do
    sleep 30
  done
}


umask 0077
. $execDir/acquire-lock.sh


case "$1" in
  -i|--init) init=true; shift;;
  *) test -f $TMPDIR/.config-ver && init=false || init=true;; ###
esac


if [ -f $TMPDIR/.config-ver ] && ! $init; then ###

  exxit() {
    local exitCode=$?
    set +eux
    trap - EXIT
    {
      cmd_batt reset &
      grep -Ev '^$|^#' $config > $TMPDIR/.config
      config=$TMPDIR/.config
      apply_on_boot default &
      apply_on_plug default &
      enable_charging &
    } > /dev/null 2>&1
    [ -n "$1" ] && exitCode=$1
    [ -n "$2" ] && print "$2"
    [[ $exitCode = [127] ]] && {
      . $execDir/logf.sh
      logf --export > /dev/null 2>&1 &
    }
    timeout 10 wait
    rm $config 2>/dev/null
    cd /
    exit $exitCode
  }


  is_charging() {

    local file="" value="" isCharging=false

    . $config

    not_charging || isCharging=true

    # run custom code
    eval "${loopCmd[@]-}"

    if $isCharging; then

      # read chgStatusCode once
      [ -n "$chgStatusCode" ] || {
        cmd_batt reset
        chgStatusCode=$(dumpsys battery 2>/dev/null | sed -n 's/^  status: //p') || :
      }

      # read charging current ctrl files (part 2) once
      ! $readChCurr || . $execDir/read-ch-curr-ctrl-files-p2.sh

      $cooldown || resetBattStatsOnUnplug=true

      apply_on_plug

    else

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
          ! grep -iq dis $batt/status || {
            dumpsys batterystats --reset < /dev/null > /dev/null 2>&1 || :
            rm /data/system/batterystats* || :
            resetBattStatsOnUnplug=false
          } 2>/dev/null
        fi
      fi
    fi

    sync_capacity

    # log buffer reset
    [ $(du -m $log | cut -f 1) -lt 2 ] || : > $log

    $isCharging && return 0 || return 1
  }

  ctrl_charging() {

    local count=0

    while :; do

      if is_charging; then

        # disable charging under <conditions>
        test $(cat $batt/temp $batt/batt_temp 2>/dev/null) -ge $(( ${temperature[1]} * 10 )) \
          && maxTempPause=true || maxTempPause=false
        if $maxTempPause || test $(cat $batt/capacity) -ge ${capacity[3]}; then
          disable_charging
          ! ${resetBattStats[0]} || {
            # reset battery stats on pause
            dumpsys batterystats --reset < /dev/null > /dev/null 2>&1 || :
            rm /data/system/batterystats* || :
          }
          ! $maxTempPause || ! not_charging || sleep ${temperature[2]}
        fi

        # cooldown cycle
        while [ -n "${cooldownRatio[0]-}${cooldownCustom[0]-}" ] \
          && [ $(cat $batt/capacity) -lt ${capacity[3]} ] \
          && is_charging
        do
          if [ $(cat $batt/temp $batt/batt_temp 2>/dev/null) -ge $(( ${temperature[0]} * 10 )) ] \
            || [ $(cat $batt/capacity) -ge ${capacity[1]} ] \
            || [ $(sed s/-// ${cooldownCustom[0]:-cooldownCustom} 2>/dev/null || echo 0) -ge ${cooldownCustom[1]:-1} ]
          then
            cooldown=true
            cmd_batt set status $chgStatusCode # to prevent unwanted display wakeups
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
              [ $(cat $batt/capacity) -lt ${capacity[3]} ] \
                && count=$(( count + ${loopDelay[0]} )) \
                || break
            done
          else
            break
          fi
        done

        cooldown=false
        sleep ${loopDelay[0]}

      else

        # enable charging under <conditions>
        [ ! $(cat $batt/capacity) -le ${capacity[2]} ] || {
          [ ! $(cat $batt/temp $batt/batt_temp 2>/dev/null) -lt $(( ${temperature[1]} * 10 )) ] \
            || enable_charging
        }

        # auto-shutdown
        if not_charging && ! $maxTempPause \
          && [ $(cat $batt/capacity) -le ${capacity[0]} ] \
          && [ $(cut -d '.' -f 1 /proc/uptime) -ge 900 ]
        then
          sleep ${loopDelay[1]}
          ! not_charging \
            || am start -n android/com.android.internal.app.ShutdownActivity < /dev/null > /dev/null 2>&1 \
            || reboot -p 2>/dev/null \
            || /system/bin/reboot -p || :
        fi

        sleep ${loopDelay[1]}

      fi
    done
  }


  sync_capacity() {
    local isCharging_=$isCharging
    ! $capacitySync || {
      ! $cooldown || isCharging=true
      if $isCharging; then
        cmd_batt set ac 1
        cmd_batt set status $chgStatusCode
      else
        cmd_batt unplug
        cmd_batt set status $dischgStatusCode
      fi
      isCharging=$isCharging_
      if ! ${capacity[4]} \
        || { ${capacity[4]} && [ $(cat $batt/capacity) -ge 2 ]; }
      then
        cmd_batt set level $(cat $batt/capacity)
      fi
    }
  }


  # load generic functions
  . $execDir/misc-functions.sh


  isAccd=true
  cooldown=false
  readChCurr=true
  chgStatusCode=""
  capacitySync=false
  updateConfig=false
  dischgStatusCode=""
  maxTempPause=false
  resetBattStatsOnUnplug=false
  log=$TMPDIR/${id}d-${device}.log


  # verbose
  [ -z "${LINENO-}" ] || export PS4='$LINENO: '
  echo "###$(date)###" >> $log
  echo "versionCode=$(sed -n s/versionCode=//p $execDir/module.prop 2>/dev/null)" >> $log
  exec >> $log 2>&1
  set -x


  misc_stuff "${1-}"
  . $execDir/oem-custom.sh
  . $config


  apply_on_boot
  ctrl_charging
  exit $?


else


  # log
  data_dir=/sdcard/Documents/vr25/$id
  mkdir -p $TMPDIR $data_dir/logs
  exec > $data_dir/logs/init.log 2>&1
  set -x


  # prepare executables ###

  ln -fs $execDir/${id}.sh /dev/$id
  ln -fs $execDir/${id}.sh /dev/${id}d,
  ln -fs $execDir/${id}.sh /dev/${id}d.
  ln -fs $execDir/${id}a.sh /dev/${id}a
  ln -fs $execDir/service.sh /dev/${id}d

  test -d /sbin && {
    ! grep -q "^tmpfs / " /proc/mounts \
      || /system/bin/mount -o remount,rw / 2>/dev/null \
      || mount -o remount,rw /
    for h in  /dev/$id /dev/${id}d, /dev/${id}d. \
      /dev/${id}a /dev/${id}d
    do
      ln -fs $h /sbin/ 2>/dev/null || break
    done
  }


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
  cd /sys/class/power_supply/
  : > $TMPDIR/ch-switches_
  grep -Ev '^#|^$' $execDir/charging-switches.txt | \
    while IFS= read -r chargingSwitch; do
      set -f
      set -- $chargingSwitch
      set +f
      ctrlFile1="$(echo $1 | cut -d ' ' -f 1)"
      ctrlFile2="$(echo $4 | cut -d ' ' -f 1)"
      [ -f "$ctrlFile1" ] && {
        [ -f "$ctrlFile2" -o -z "$ctrlFile2" ] && {
          chmod u+r $ctrlFile1 || continue
          if ! cat $ctrlFile1 > /dev/null 2>&1 || [ -z "$(cat $ctrlFile1 2>/dev/null)" ] \
            || grep -Eq "^(${2//::/ }|${3//::/ })$" $ctrlFile1
          then
            echo $ctrlFile1 $2 $3 $ctrlFile2 $5 $6 >> $TMPDIR/ch-switches_
          fi
        }
      }
    done


  # read charging voltage control files ###
  : > $TMPDIR/ch-volt-ctrl-files_
  ls -1 */constant_charge_voltage* */voltage_max \
    */batt_tune_float_voltage */fg_full_voltage 2>/dev/null | \
      while read file; do
        chmod u+r $file 2>/dev/null && grep -Eq '^4[1-4][0-9]{2}' $file || continue
        echo ${file}::$(sed -n 's/^..../v/p' $file)::$(cat $file) \
          >> $TMPDIR/ch-volt-ctrl-files_
      done


  # read charging current control files (part 1) ###
  # part 2 is handled by accd - while charging only

  : > $TMPDIR/ch-curr-ctrl-files_
  ls -1 */input_current_limited */restrict*_ch*g* \
    /sys/class/qcom-battery/restrict*_ch*g* 2>/dev/null | \
    while read file; do
      chmod u+r $file 2>/dev/null || continue
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
        chmod u+r $file 2>/dev/null || continue
        defaultValue=$(cat $file)
        ampFactor=$(sed -n 's/^ampFactor=//p' $data_dir/config.txt 2>/dev/null)
        [ -n "$ampFactor" -o $defaultValue -ne 0 ] && {
          if [ "${ampFactor:-1}" -eq 1000 -o $defaultValue -lt 10000 ]; then
            # milliamps
            echo ${file}::v::$defaultValue \
              >> $TMPDIR/ch-curr-ctrl-files_
          else
            # microamps
            echo ${file}::v000::$defaultValue \
              >> $TMPDIR/ch-curr-ctrl-files_
          fi
        }
      done


  # remove duplicates and parallel/ ctrl files
  for file in $TMPDIR/ch-*_; do
    sort -u $file | grep -iv parallel > ${file%_}
    rm $file
  done


  # prepare default config help text and version code for oem-custom.sh and write-config.sh
  sed -n '/^# /,$p' $execDir/default-config.txt > $TMPDIR/.config-help
  sed -n '/^configVerCode=/s/.*=//p' $execDir/default-config.txt > $TMPDIR/.config-ver


  # start $id daemon
  rm /dev/.$id/.ghost-charging 2>/dev/null ###
  exec $0 "$@"
fi

exit 0
