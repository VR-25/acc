batt_info() {

  local info=
  local voltNow=
  local currNow=
  local powerNow=
  local factor=
  set +eu


  # calculator
  calc() { awk "BEGIN { print $* }"; }


  # (determine conversion factor)
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
    set +e
    cat $batt/uevent *bms*/uevent 2>/dev/null \
      | sort -u \
      | sed -e '/^POWER_SUPPLY_NAME=/d' \
        -e 's/^POWER_SUPPLY_//' \
        -e 's/^BATT_VOL=/VOLTAGE_NOW=/' \
        -e 's/^BATT_TEMP=/TEMP=/'
  )"


  # determine the correct charging status
  case "$info" in
    *STATUS=[Cc]harging*)
      if not_charging dis; then
        info="${info/STATUS=?harging/STATUS=Discharging}"
      elif not_charging not; then
        info="${info/STATUS=?harging/STATUS=Not charging}"
      fi
    ;;
  esac


  # because MediaTek is weird
  [ ! -d /proc/mtk_battery_cmd ] || {
    echo "$info" | grep '^CURRENT_NOW=' > /dev/null \
      || info="${info/BATTERYAVERAGECURRENT=/CURRENT_NOW=}"
  }


  # parse CURRENT_NOW & convert to Amps
  currNow=$(echo "$info" | sed -n "s/^CURRENT_NOW=//p" | head -n1)
  dtr_conv_factor ${currNow#-} ${ampFactor-}
  currNow=$(calc ${currNow:-0} / $factor)


  # add/remove negative sign
  case $currNow in
    *.*)
      if not_charging dis; then
        currNow=-${currNow#-}
      elif ! not_charging; then
        currNow=${currNow#-}
      fi
    ;;
    *)
      currNow=0
    ;;
  esac

  # parse VOLTAGE_NOW & convert to Volts
  voltNow=$(echo "$info" | sed -n "s/^VOLTAGE_NOW=//p")
  dtr_conv_factor $voltNow ${voltFactor-}
  voltNow=$(calc ${voltNow:-0} / $factor)


  # calculate POWER_NOW (Watts)
  powerNow=$(calc $currNow \* $voltNow)


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
