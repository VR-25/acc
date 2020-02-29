batt_info() {

  local info="" voltNow="" currNow="" powerW="" factor=""
  set +euo pipefail 2>/dev/null || :

  # awk calculator
  calc() { awk "BEGIN { print $* }"; }

  # raw battery info from $batt/uevent
  info="$(
    sed -e 's/POWER_SUPPLY_//' -e 's/^BATTERYAVERAGECURRENT=/CURRENT_NOW=/' \
      -e 's/^BATT_VOL=/VOLTAGE_NOW=/' -e 's/^BATT_TEMP=/TEMP=/' \
      -e "/^CAPACITY=/s/=.*/=$(( $(cat $batt/capacity) ${capacity[4]} ))/" \
      $batt/uevent

    if [ -f bms/uevent ]; then
      grep -q 'Y_TEMP=' $batt/uevent \
        || { grep 'Y_TEMP=' bms/uevent | grep -o 'TEMP=.*'; }
      grep -q 'Y_VOLTAGE_NOW=' $batt/uevent \
        || { grep 'Y_VOLTAGE_NOW=' bms/uevent | grep -o 'VOLTAGE_NOW=.*'; }
    fi
  )"

  voltNow=$(echo "$info" | sed -n "s/VOLTAGE_NOW=//p")
  currNow=$(echo "$info" | sed -n "s/CURRENT_NOW=//p")

  # determine voltage unit conversion factor (millivolts, microvolts)
  [ $(echo $voltNow | wc -m) == 5 ] && factor=1000 || factor=1000000

  # calculate power (Watts)
  powerW="$( calc "( ${currNow:-0} / $factor ) * ( ${voltNow:-0} / $factor )" )"
  powerW="POWER=$powerW$(print_W 2>/dev/null || :)"

  {
    # print raw battery info
    echo "$info" | grep -Ev '^(CURRENT|VOLTAGE)_NOW='
    echo

    # convert and print -- currNow (milliamps), voltNow (volts)
    if [ $factor -eq 1000 ]; then
      echo "CURRENT_NOW=$currNow$(print_mA 2>/dev/null || :)"
      echo "VOLTAGE_NOW=$(calc $voltNow / $factor)$(print_V 2>/dev/null || :)"
    else
      echo "CURRENT_NOW=$(calc $currNow / 1000)$(print_mA 2>/dev/null || :)"
      echo "VOLTAGE_NOW=$(calc $voltNow / $factor)$(print_V 2>/dev/null || :)"
    fi

    # print power
    echo "$powerW"
  } | grep -Ei "${1:-.*}"
}
