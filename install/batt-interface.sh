discharging() {
  tt "$curThen,$curNow" "-*,[0-9]*|[0-9]*,-*" && {
    [ ${chargingSwitch[2]:-.} = voltage_now ] && _status=Idle || _status=Discharging
  }
}


idle() {
  #grep -iq 'Not charging' $battStatus || {
    [ $curThen != null ] && {
      if $plusChgPolarity; then
        [ $curNow -ge -$idleThresholdL ] && [ $curNow -le $idleThresholdH ]
      else
        [ $curNow -le $idleThresholdL ] && [ $curNow -ge -$idleThresholdH ]
      fi
    } || return 1
  #}
  _status=Idle
}


not_charging() {

  local i=
  local off=${flip-}; flip=
  local curThen=$(cat $curThen)
  local plusChgPolarity=true
  local seqCount=${seqCount:-16} ###

  case "${dischargePolarity-}" in
    +) plusChgPolarity=false;;
    -) :;;
    *) [ $curThen != null ] && [ $curThen -lt 0 ] && plusChgPolarity=false || :;;
  esac

  tt "${chargingSwitch[$*]-}" "*\ --" || battStatusOverride=
  [ $currFile != $TMPDIR/.dummy-curr ] || battStatusWorkaround=false

  if [ -z "${battStatusOverride-}" ] && [ -n "$off" ]; then
    [ $off = off ] && off=true || off=false
    for i in $(seq $seqCount); do
      if $off; then
        ! status ${1-} || return 0
        [ $i -lt 5 ] || {
          if $plusChgPolarity; then
            [ $(cat $currFile) -lt $((curThen / 100 * 90)) ] || return 1
          else
            [ $(cat $currFile) -gt $((curThen / 100 * 90)) ] || return 1
          fi
        }
      else
        status ${1-} || return 1
      fi
      [ $i = $seqCount ] || sleep 1
    done
    $off && return 1 || return 0
  else
    status ${1-}
  fi
}


status() {

  local i=
  local curNow=$(cat $currFile)

  _status=$(sed 's/Not charging/Idle/' $battStatus)
  [ -z "${exitCode_-}" ] || echo "  curr=$curThen,$curNow off=${off:-false} status=$_status"

  if [ -n "${battStatusOverride-}" ]; then
    if tt "$battStatusOverride" "Discharging|Idle"; then
      [ $(cat ${chargingSwitch[0]}) != ${chargingSwitch[2]} ] || _status=$battStatusOverride
    else
      _status=$(set -eu; eval '$battStatusOverride') || :
    fi
  elif $battStatusWorkaround; then
    #idle || discharging || :
    case $_status in
      Charging) idle || discharging || :;;
      Discharging) idle || :;;
    esac
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
battStatus=\"$battStatus\"
currFile=$currFile
curThen=$curThen
idleThresholdL=$idleThresholdL
idleThresholdH=$idleThresholdH
temp=$temp
" > $TMPDIR/.batt-interface.sh

  init=false

else
  . $TMPDIR/.batt-interface.sh
fi

[ -f $curThen ] || echo null > $curThen
