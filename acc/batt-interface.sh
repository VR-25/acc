discharging() {
  [ $(cat $TMPDIR/.curr) != null ] \
    && [ $(cat $currFile) -lt $(cat $TMPDIR/.curr) ]
}

idle() {
  [ -n "$idleThreshold" ] \
    && [ $(sed s/-// $currFile) -le $idleThreshold ]
}


not_charging() {

  local file=
  local i=

  for file in sm????_bms/status $batt/status; do
    [ ! -f $file ] || break
  done

  _status=$(sed 's/Not charging/Idle/' $file)

  if [ ! -f $TMPDIR/curr ] && [ ! -f $dataDir/curr ]; then
    case $_status in
      Charging) idle && _status=Idle || { ! discharging || _status=Discharging; };;
      Discharging) ! idle || _status=Idle;;
    esac
  fi

  for i in Discharging DischargingDischarging Idle IdleIdle; do
    [ $i != ${1-}$_status ] || return 0
  done

  return 1
}


if ${init:-false}; then

  for batt in */capacity; do
    if [ -f ${batt%/*}/status ]; then
      batt=${batt%/*}
      break
    fi
  done

  case $batt in
    */capacity) exit 1;;
  esac

  [ -f maxfg/capacity ] && battCapacity=maxfg/capacity || battCapacity=$batt/capacity


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
  idleThreshold=95 # mA

  ampFactor_=1000

  if [ $curr -le $idleThreshold ]; then
    ampFactor_=
    idleThreshold=
  else
    ! [ $curr -ge 10000 ] || {
      ampFactor_=1000000
      idleThreshold=${idleThreshold}000
    }
  fi

  unset curr

  echo "ampFactor_=$ampFactor_
batt=$batt
currFile=$currFile
battCapacity=$battCapacity
idleThreshold=$idleThreshold
temp=$temp" > $TMPDIR/.batt-interface.sh

  init=false

else
  . $TMPDIR/.batt-interface.sh
fi

[ -f $TMPDIR/.curr ] || echo null > $TMPDIR/.curr
