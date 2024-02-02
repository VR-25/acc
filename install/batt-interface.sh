idle_discharging() {
  [ ${curNow#-} -gt $idleThreshold ] || {
    _status=Idle
    return 0
  }
  case "${dischargePolarity-}" in
    +) [ $curNow -ge 0 ] && _status=Discharging || _status=Charging;;
    -) [ $curNow -lt 0 ] && _status=Discharging || _status=Charging;;
    *) [ $curThen = null ] || {
         tt "$curThen,$curNow" "-*,[0-9]*|[0-9]*,-*" && _status=Discharging || _status=Charging
       };;
  esac
}


not_charging() {

  local i=
  local sti=${sti:-15}
  local switch=${flip-}; flip=
  local curThen=$(cat $curThen)
  local idleThreshold=$idleThreshold
  local battStatusOverride="${battStatusOverride-}"
  local battStatusWorkaround=${battStatusWorkaround-}

  tt "${chargingSwitch[$*]-}" "*\ --" || battStatusOverride=

  case "$currFile" in
    */current_now|*/?attery?verage?urrent) [ ${ampFactor:-$ampFactor_} -eq 1000 ] || idleThreshold=${idleThreshold}000;;
    *) battStatusWorkaround=false;;
  esac

  if [ -z "${battStatusOverride-}" ] && [ -n "$switch" ]; then
    for i in $(seq $sti); do
      if [ "$switch" = off ]; then
        ! status ${1-} || {
          sleep ${loopDelay[0]}
          ! status ${1-} || return 0
        }
      else
        status ${1-} || return 1
      fi
      [ ! -f $TMPDIR/.nowrite ] || { rm $TMPDIR/.nowrite 2>/dev/null || :; break; }
      [ $i = $sti ] || sleep ${loopDelay[0]}
    done
    [ "$switch" = on ] || return 1
  else
    status ${1-}
  fi
}


online() {
  local i=
  for i in $(online_f); do
    grep -q 0 $i || return 0
  done
  return 1
}


online_f() {
  ls -1 */online | grep -Ei '^ac/|^charger/|^dc/|^pc_port/|^usb/|^wireless/' || :
}


read_status() {
  local status="$(cat $battStatus)"
  case "$status" in
    Charging|Discharging) printf %s $status;;
    Not?charging) online && printf Idle || printf Discharging;;
    *) printf Discharging;;
  esac
}


set_temp_level() {
  local a=
  local b=battery/siop_level
  local l=${1:-${tempLevel-}}
  [ -n "$l" ] || return 0
  if [ -f $b ]; then
    chown 0:0 $b && chmod 0644 $b && echo $((100 - $l)) > $b && chmod 0444 $b || :
  else
    for a in */num_system_temp*levels; do
      b=$(echo $a | sed 's/\/num_/\//; s/s$//')
      if [ ! -f $a ] || [ ! -f $b ]; then
        continue
      fi
      chown 0:0 $b && chmod 0644 $b && echo $(( ($(cat $a) * l) / 100 )) > $b && chmod 0444 $b || :
    done
  fi
  for a in */charge_control_limit_max; do
    b=${a%_max}
    if [ ! -f $a ] || [ ! -f $b ]; then
      continue
    fi
    chown 0:0 $b && chmod 0644 $b && echo $(( ($(cat $a) * l) / 100 )) > $b && chmod 0444 $b || :
  done
}


status() {

  local i=
  local curNow=$(cat $currFile)

  _status=$(read_status)

  if [ -n "${battStatusOverride-}" ]; then
    if tt "$battStatusOverride" "Discharging|Idle"; then
      [ $(cat ${chargingSwitch[0]}) != ${chargingSwitch[2]} ] || _status=$battStatusOverride
    else
      _status=$(set -eu; eval '$battStatusOverride') || :
    fi
  elif $battStatusWorkaround; then
    [ $_status = Idle ] || idle_discharging
  fi

  [ -z "${exitCode_-}" ] || echo -e "  switch: ${switch:--} (${swValue:-N/A})\tcurrent: $(calc $curNow \* 1000 / ${ampFactor:-$ampFactor_} | xargs printf %.f)mA\tstatus: $_status"

  for i in Discharging DischargingDischarging Idle IdleIdle; do
    [ $i != ${1-}$_status ] || return 0
  done

  return 1
}


volt_now() {
  grep -o '^....' $voltNow
}


if ${init:-false}; then

  for batt in maxfg/capacity */capacity; do
    if [ -f ${batt%/*}/status ] && [ -n "$(cat ${batt%/*}/uevent 2>/dev/null || :)" ]; then
      batt=${batt%/*}
      break
    fi
  done

  case $batt in
    */capacity) exit 1;;
  esac

  for battStatus in sm????_bms/status $batt/status; do
    [ ! -f $battStatus ] || break
  done


  echo 250 > $TMPDIR/.dummy-temp

  for temp in $batt/temp $batt/batt_temp bms/temp $TMPDIR/.dummy-temp; do
    [ ! -f $temp ] || break
  done


  echo 0 > $TMPDIR/.dummy-curr

  for currFile in $batt/current_now bms/current_now battery/?attery?verage?urrent \
    /sys/devices/platform/battery/power_supply/battery/?attery?verage?urrent $TMPDIR/.dummy-curr
  do
    [ ! -f $currFile ] || break
  done


  voltNow=$batt/voltage_now
  [ -f $voltNow ] || voltNow=$batt/batt_vol
  [ -f $voltNow ] || {
    echo 3900 > $TMPDIR/.voltage_now
    voltNow=$TMPDIR/.voltage_now
  }


  ampFactor=$(sed -n 's/^ampFactor=//p' $dataDir/config.txt 2>/dev/null || :)
  ampFactor_=${ampFactor:-1000}

  if [ $ampFactor_ -eq 1000000 ] || [ $(sed s/-// $currFile) -ge 16000 ]; then
    ampFactor_=1000000
  fi

  curThen=$TMPDIR/.curr
  rm $curThen 2>/dev/null || :


  echo "ampFactor_=$ampFactor_
batt=$batt
battCapacity=$batt/capacity
battStatus=$battStatus
currFile=$currFile
curThen=$curThen
temp=$temp
voltNow=$voltNow" > $TMPDIR/.batt-interface.sh

  init=false

else
  touch $TMPDIR/.batt-interface.sh
  . $TMPDIR/.batt-interface.sh
fi

[ -f $curThen ] || echo null > $curThen
