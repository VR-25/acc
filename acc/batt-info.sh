batt_info() {

  local info=
  local voltNow=
  local currNow=
  local powerNow=
  local factor=
  set +eu


  # calculator
  calc2() {
    awk "BEGIN {print $*}" | xargs printf %.2f
  }


  dtr_conv_factor() {
    factor=${2-}
    if [ -z "$factor" ]; then
      case $1 in
        0) factor=1;;
        *) [ $1 -lt 10000 ] && factor=1000 || factor=1000000;;
      esac
    fi
  }


  # raw battery info from the kernel's battery interface
  info="$(
    cat $batt/uevent *bms*/uevent 2>/dev/null \
      | sort -u \
      | sed -e 's/^POWER_SUPPLY_//' \
          -e 's/^BATT_VOL=/VOLTAGE_NOW=/' \
          -e 's/^BATT_TEMP=/TEMP=/' \
          -e '/^(CHARGE_TYPE|NAME)=/d'\
          -e "/^CAPACITY=/s/=.*/=$(cat $battCapacity)/"
  )"


  # determine the correct charging status
  not_charging || :
  info="$(echo "$info" | sed "/^STATUS=/s/=.*/=$_status/")"


  # because MediaTek is weird
  [ ! -d /proc/mtk_battery_cmd ] || {
    echo "$info" | grep '^CURRENT_NOW=' > /dev/null \
      || info="${info/BATTERYAVERAGECURRENT=/CURRENT_NOW=}"
  }


  # parse CURRENT_NOW & convert to Amps
  currNow=$(echo "$info" | sed -n "s/^CURRENT_NOW=//p" | head -n1)
  dtr_conv_factor ${currNow#-} ${ampFactor:-$ampFactor_}
  currNow=$(calc2 ${currNow:-0} / $factor)


  # add/remove negative sign
  case $currNow in
    0.00)
      :
    ;;
    *)
      if [ $_status = Discharging ]; then
        currNow=-${currNow#-}
      elif [ $_status = Charging ]; then
        currNow=${currNow#-}
      fi
    ;;
  esac


  # parse VOLTAGE_NOW & convert to Volts
  voltNow=$(echo "$info" | sed -n "s/^VOLTAGE_NOW=//p")
  dtr_conv_factor $voltNow ${voltFactor-}
  voltNow=$(calc2 ${voltNow:-0} / $factor)


  # calculate POWER_NOW (Watts)
  powerNow=$(calc2 $currNow \* $voltNow)


  {
    # print raw battery info
    ${verbose:-true} \
      && echo "$info" \
      || echo "$info" | grep -Ev '^(CURRENT|VOLTAGE)_NOW='

    # print CURRENT_NOW, VOLTAGE_NOW and POWER_NOW
    echo "
CURRENT_NOW=$currNow$(print_A 2>/dev/null || :)
VOLTAGE_NOW=$voltNow$(print_V 2>/dev/null || :)
POWER_NOW=$powerNow$(print_W 2>/dev/null || :)"
  } | grep -Ei "${1:-.*}" || :
}
