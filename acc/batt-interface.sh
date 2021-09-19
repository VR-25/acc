for batt in */capacity; do
  if [ -f ${batt%/*}/status ]; then
    batt=${batt%/*}
    break
  fi
done

case $batt in
  */capacity) exit 1;;
esac

currNow_=0
echo 0 > $TMPDIR/.dummy-curr
for currFile in $batt/current_now bms/current_now \
  $batt/batteryaveragecurrent $TMPDIR/.dummy-curr
do
  [ ! -f $currFile ] || break
done

temp=$batt/temp
[ -f $temp ] || {
  temp=$batt/batt_temp
  [ -f $temp ] || {
    temp=bms/temp
    [ -f $temp ] || {
      echo 250 > $TMPDIR/.dummy-temp
      temp=$TMPDIR/.dummy-temp
    }
  }
}

curr_dropped() {
  local currNowNew=$(cat $currFile)
  local currNow__=${currNow_#-}
  local currNow25p=$(( (currNow_ * 25) / 100 ))
  currNow_=0
  if [ $currNow__ -ne 0 ] && [ ${currNowNew#-} -ge 1000 ]; then
    [ $(( $currNow__ - ${currNowNew#-} )) -ge $currNow25p ] && echo true || echo false
  else
    echo neutral
  fi
}

dis_not() {
  if test -f sm????_bms/status; then
    grep -Eiq "$1" sm????_bms/status
  else
    grep -Eiq "$1" $batt/status
  fi
}

type_na() {
  if [ -f $batt/charge_type ]; then
    [ ".$(cat $batt/charge_type)" = .N/A ]
  else
    return 0
  fi
}

not_charging() {

  # if dis_not "${1-dis|not}"; then
  #   type_na
  # else
  #   ! type_na
  # fi

  # local curr_dropped=$(curr_dropped)
  # if dis_not "${1-dis|not}"; then
  #   case $curr_dropped in
  #     neutral|true) return 0;;
  #   esac
  #   return 1
  # else
  #   case $curr_dropped in
  #     neutral|false) return 1;;
  #   esac
  #   return 0
  # fi

  dis_not "${1-dis|not}"
}
