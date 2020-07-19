(
grep_() { grep -Eq "$1" ${2:-$config}; }

get_prop() { sed -n "\|^$1=|s|.*=||p" ${2:-$config}; }

set_prop_() { sed -i "\|^${1}=|s|=.*|=$2|" ${3:-$config}; }


# patch/reset [broken/obsolete] config
configVer=0$(get_prop configVerCode 2>/dev/null || :)
defaultConfVer=$(get_prop configVerCode $execDir/default-config.txt)
if (set +x; . $config) > /dev/null 2>&1; then
  [ $configVer -eq $defaultConfVer ] || {
    if [ $configVer -lt 202007170 ]; then
      cp -f $execDir/default-config.txt $config
    else
      /dev/acca --set dummy=
    fi
  }
else
  cp -f $execDir/default-config.txt $config
fi 2>/dev/null


# battery idle mode for OnePlus 7/Pro
if grep_ '^chargingSwitch=.*/op_disable_charge'; then
  [ -f $TMPDIR/oem-custom ] \
    || echo "run_xtimes 'echo 1 > battery/op_disable_charge; echo 0 > battery/input_suspend'" > $TMPDIR/oem-custom
  grep_ "^runCmdOnPause=.*$TMPDIR/oem-custom" \
    || set_prop_ runCmdOnPause "(. $TMPDIR/oem-custom)"
  switchDelay=$(get_prop switchDelay)
  [ ${switchDelay%.*} -gt 4 ] || set_prop_ switchDelay 5
else
  ! grep_ "^runCmdOnPause=.*$TMPDIR/oem-custom" 2>/dev/null || {
    set_prop_ runCmdOnPause "()"
    set_prop_ switchDelay 1.5
  }
fi


# battery idle mode for Google Pixel 2/XL and devices with similar hardware
if grep_ '^chargingSwitch=./sys/module/lge_battery/parameters/charge_stop_level'; then
  [ -f $TMPDIR/oem-custom ] \
    || echo "[ \$(cat battery/input_suspend) != 1 ] || run_xtimes 'echo 0 > battery/input_suspend'" > $TMPDIR/oem-custom
  grep_ "^loopCmd=.*$TMPDIR/oem-custom" \
    || set_prop_ loopCmd "(. $TMPDIR/oem-custom)"
  #switchDelay=$(get_prop switchDelay)
  #[ ${switchDelay%.*} -gt 4 ] || set_prop_ switchDelay 5
else
  ! grep_ "^loopCmd=.*$TMPDIR/oem-custom" 2>/dev/null || {
    set_prop_ loopCmd "()"
    #set_prop_ switchDelay 1.5
  }
fi


# Razer
# default value: 65
(set +e
echo 1 > /sys/devices/platform/soc/*/*/*/razer_charge_limit_dropdown
echo 1 > usb/razer_charge_limit_dropdown) 2>/dev/null || :


# block "ghost charging on steroids" (Xiaomi Redmi 3 - ido)
[ ! -f $TMPDIR/accd-ido.log ] || touch $TMPDIR/.ghost-charging


# MediaTek mt6795, exclude ChargerEnable switch (troublesome)
! getprop | grep -E mt6795 > /dev/null || {
  ! grep_ ChargerEnable $execDir/charging-switches.txt || {
    sed -i /ChargerEnable/d $TMPDIR/ch-switches
    sed -i /ChargerEnable/d $execDir/charging-switches.txt
  }
}


# Pixel [1-3]*, exclude charge_control_limit switches (troublesome)
! getprop |  grep -E '\[Pixel(\]| [1-3])' > /dev/null || {
  ! grep_ charge_control_limit $execDir/charging-switches.txt || {
    sed -i /charge_control_limit/d $TMPDIR/ch-switches
    sed -i /charge_control_limit/d $execDir/charging-switches.txt
  }
}
)
