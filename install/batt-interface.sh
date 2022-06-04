discharging() {
  tt "$curThen,$curNow" "-*,[0-9]*|[0-9]*,-*" && {
    [ ${chargingSwitch[2]:-.} = voltage_now ] && _status=Idle || _status=Discharging
  }
}


idle() {
  grep -iq 'Not charging' $battStatus || {
    [ -n "$idleThreshold_" ] && [ $curThen != null ] && {
      if $positive; then
        [ $curNow -ge -$idleThreshold_ ] && [ $curNow -le $idleThreshold1 ]
      else
        [ $curNow -le $idleThreshold_ ] && [ $curNow -ge -$idleThreshold1 ]
      fi
    } || return 1
  }
  _status=Idle
}


not_charging() {

  local i=
  local off=${flip-}; flip=
  local curThen=$(cat $curThen)
  local positive=true
  local seqCount=${seqCount:-16} ###

  [ $curThen != null ] && [ $curThen -lt 0 ] && positive=false || :
  tt "${chargingSwitch[$*]-}" "*\ --" || battStatusOverride=
  [ $currFile != $TMPDIR/.dummy-curr ] || battStatusWorkaround=false

  if [ -z "${battStatusOverride-}" ] && [ -n "$off" ]; then
    [ $off = off ] && off=true || off=false
    for i in $(seq $seqCount); do
      if $off; then
        ! status ${1-} || return 0
        [ $i -lt 5 ] || {
          if $positive; then
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
    idle || discharging || :
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

  curr=$(sed s/-// $currFile)
  idleThreshold=11 # mA
  idleThreshold1=101 # mA
  idleThreshold_=$idleThreshold
  ampFactor_=1000

  if [ $curr -le $idleThreshold_ ]; then
    ampFactor_=
    idleThreshold_=
  else
    ! [ $curr -ge 10000 ] || {
      ampFactor_=1000000
      idleThreshold_=${idleThreshold_}000
    }
  fi

  case "$(sed -n 's/^ampFactor=//p' $dataDir/config.txt 2>/dev/null)" in
    1000) idleThreshold_=$idleThreshold;;
    1000000) idleThreshold_=${idleThreshold}000; idleThreshold1=${idleThreshold1}000;;
  esac

  unset curr
  curThen=$TMPDIR/.curr
  rm $curThen 2>/dev/null || :


  echo "
ampFactor_=$ampFactor_
batt=$batt
battCapacity=$batt/capacity
battStatus=\"$battStatus\"
currFile=$currFile
curThen=$curThen
idleThreshold_=$idleThreshold_
idleThreshold1=$idleThreshold1
temp=$temp
" > $TMPDIR/.batt-interface.sh

  init=false

else
  . $TMPDIR/.batt-interface.sh
fi

[ -f $curThen ] || echo null > $curThen
