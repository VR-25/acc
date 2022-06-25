discharging() {
  tt "$curThen,$curNow" "-*,[0-9]*|[0-9]*,-*" && _status=Discharging
}


idle() {
  [ $curThen != null ] && {
    if $_dischargePolarity; then
      [ $curNow -ge -$idleThresholdL ] && [ $curNow -le $idleThresholdH ]
    else
      [ $curNow -le $idleThresholdL ] && [ $curNow -ge -$idleThresholdH ]
    fi
  } || return 1
  _status=Idle
}


not_charging() {

  local i=
  local switch=${flip-}; flip=
  local curThen=$(cat $curThen)
  local seqOff=${seqOff:-16}
  local seqOn=${seqOn:-60}
  local battStatusOverride="${battStatusOverride-}"
  local battStatusWorkaround=${battStatusWorkaround-}

  case "${dischargePolarity-}" in
    +) _dischargePolarity=false;;
    -) _dischargePolarity=true;;
  esac

  tt "${chargingSwitch[$*]-}" "*\ --" || battStatusOverride=

  if [ $currFile = $TMPDIR/.dummy-curr ] || [ -z "${_dischargePolarity-}" ]; then
    battStatusWorkaround=false
  fi

  if [ -z "${battStatusOverride-}" ] && [ "$switch" = off ]; then
    for i in $(seq $seqOff); do
      ! status ${1-} || return 0
      if $battStatusWorkaround && [ $i -ge 5 ]; then
        if $_dischargePolarity; then
          [ $(cat $currFile) -lt $((curThen / 100 * 90)) ] || return 1
        else
          [ $(cat $currFile) -gt $((curThen / 100 * 90)) ] || return 1
        fi
      fi
      [ $i = $seqOff ] || sleep 1
    done
    return 1
  else
    status ${1-}
    if [ "$switch" = on ]; then
      for i in $(seq $seqOn); do
        status ${1-} || return 1
        sleep 1
      done
    else
      status ${1-}
    fi
  fi
}


read_status() {
  local status="$(cat $battStatus)"
  case "$status" in
    Charging|Discharging) printf %s $status;;
    Not?charging) printf Idle;;
    *) printf Discharging;;
  esac
}


status() {

  local i=
  local curNow=$(cat $currFile)

  _status=$(read_status)

  [ -n "${_dischargePolarity-}" ] || {
    case "$_status$curNow" in
      Discharging-*) _dischargePolarity=true;;
      Discharging[0-9]*) _dischargePolarity=false;;
    esac
    [ -z "${_dischargePolarity-}" ] \
      || echo "_dischargePolarity=$_dischargePolarity" >> $TMPDIR/.batt-interface.sh
  }

  [ -z "${exitCode_-}" ] || echo "  switch:${switch:-on} status:$_status curr:$curThen,$curNow"

  if [ -n "${battStatusOverride-}" ]; then
    if tt "$battStatusOverride" "Discharging|Idle"; then
      [ $(cat ${chargingSwitch[0]}) != ${chargingSwitch[2]} ] || _status=$battStatusOverride
    else
      _status=$(set -eu; eval '$battStatusOverride') || :
    fi
  elif $battStatusWorkaround; then
    ! tt "$_status" "Charging|Discharging" || {
      idle || discharging || :
    }
  fi

  for i in Discharging DischargingDischarging Idle IdleIdle; do
    [ $i != ${1-}$_status ] || return 0
  done

  return 1
}


if ${init:-false}; then

  for batt in maxfg/capacity */capacity; do
    if [ -f ${batt%/*}/status ]; then
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

  for currFile in $batt/current_now bms/current_now \
    $batt/batteryaveragecurrent $TMPDIR/.dummy-curr
  do
    [ ! -f $currFile ] || break
  done

  idleThresholdL=11 # mA
  idleThresholdH=101 # mA
  ampFactor=$(sed -n 's/^ampFactor=//p' $dataDir/config.txt 2>/dev/null || :)
  ampFactor_=${ampFactor:-1000}

  if [ $ampFactor_ -eq 1000000 ] || [ $(sed s/-// $currFile) -ge 16000 ]; then
    ampFactor_=1000000
    idleThresholdL=${idleThresholdL}000
    idleThresholdH=${idleThresholdH}000
  fi

  curThen=$TMPDIR/.curr
  rm $curThen 2>/dev/null || :


  echo "
ampFactor_=$ampFactor_
batt=$batt
battCapacity=$batt/capacity
battStatus=$battStatus
currFile=$currFile
curThen=$curThen
idleThresholdH=$idleThresholdH
idleThresholdL=$idleThresholdL
temp=$temp
" > $TMPDIR/.batt-interface.sh

  init=false

else
  . $TMPDIR/.batt-interface.sh
fi

[ -f $curThen ] || echo null > $curThen
