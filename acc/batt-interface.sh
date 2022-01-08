not_charging() {

  local file=

  for file in sm????_bms/status $batt/status; do
    [ ! -f $file ] || break
  done

  [ ${1:-.} = not ] && _status=Idle || _status=Discharging

  grep -Eiq "${1-dis|not}" $file || {
    if [ -n "$currThreshold" ] && [ ! -f ${config_%/*}/curr ] \
      && [ ! -f $TMPDIR/curr ] && [ $(sed s/-// $currFile) -le $currThreshold ]
    then
      return 0
    else
      if { [ -z "${1-}" ] || [ $1 = dis ]; } \
        && [ $(sed s/-// $currFile) -lt $curr ]
      then
        return 0
      fi
      _status=Charging
      return 1
    fi
  }
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
  currThreshold=95 # mA
  ampFactor_=1000

  if [ $curr -le $currThreshold ]; then
    ampFactor_=
    currThreshold=
  else
    ! [ $curr -ge 10000 ] || {
      ampFactor_=1000000
      currThreshold=${currThreshold}000
    }
  fi

  echo "ampFactor_=$ampFactor_
batt=$batt
currFile=$currFile
currThreshold=$currThreshold
temp=$temp" > $TMPDIR/.batt-interface.sh

  init=false

else
  . $TMPDIR/.batt-interface.sh
fi

curr=-1
