# find battery interface
for batt in */capacity; do
  if [ -f ${batt%/*}/status ]; then
    batt=${batt%/*}
    break
  fi
done

case $batt in
  */capacity) exit 1;;
esac

# set temperature reporter
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

not_charging() {
  if test -f sm????_bms/status; then
    grep -Eiq "${1-dis|not}" sm????_bms/status
  else
    grep -Eiq "${1-dis|not}" $batt/status
  fi && {
    if [ -f $batt/charge_type ]; then
      [ ".$(cat $batt/charge_type)" = .N/A ]
    else
      return 0
    fi
  }
}
