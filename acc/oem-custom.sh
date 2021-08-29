(grep_() { grep -Eq "$1" ${2:-$config}; }

get_prop() { sed -n "\|^$1=|s|.*=||p" ${2:-$config} 2>/dev/null || :; }

set_prop_() { sed -i "\|^${1}=|s|=.*|=$2|" ${3:-$config}; }


# patch/reset [broken/obsolete] config
configVer=0$(get_prop configVerCode)
defaultConfVer=0$(cat $TMPDIR/.config-ver)
broken=false
(set +x; . $config) > /dev/null 2>&1 || broken=true
if $broken || [ $configVer -ne $defaultConfVer ]; then
  if ! $broken && [ $configVer -eq 202012070 ]; then
    $TMPDIR/acca --set dummy=
  else
    cat $execDir/default-config.txt > $config
  fi
fi


# battery idle mode for OnePlus devices
if grep_ '^chargingSwitch=.*battery/op_disable_charge'; then
  [ -f $TMPDIR/oem-custom ] \
    || echo "run_xtimes 'echo 1 > battery/op_disable_charge; echo 0 > battery/input_suspend'" > $TMPDIR/oem-custom
  grep_ "^loopCmd=.*$TMPDIR/oem-custom" \
    || set_prop_ loopCmd "(. $TMPDIR/oem-custom)"
else
  ! grep_ "^loopCmd=.*$TMPDIR/oem-custom" 2>/dev/null || {
    set_prop_ loopCmd "()"
  }
fi


# battery idle mode for Google Pixel 2/XL and devices with similar hardware
if grep_ '^chargingSwitch=./sys/module/lge_battery/parameters/charge_stop_level'; then
  [ -f $TMPDIR/oem-custom ] \
    || echo "[ \$(cat battery/input_suspend) != 1 ] || run_xtimes 'echo 0 > battery/input_suspend'" > $TMPDIR/oem-custom
  grep_ "^loopCmd=.*$TMPDIR/oem-custom" \
    || set_prop_ loopCmd "(. $TMPDIR/oem-custom)"
else
  ! grep_ "^loopCmd=.*$TMPDIR/oem-custom" 2>/dev/null || {
    set_prop_ loopCmd "()"
  }
fi


# block "ghost charging on steroids" (Xiaomi Redmi 3 - ido)
[ ! -f $TMPDIR/accd-ido.log ] || touch $TMPDIR/.ghost-charging


# mt6795, exclude ChargerEnable switches (troublesome)
! getprop | grep -E mt6795 > /dev/null || {
  ! grep_ ChargerEnable $execDir/charging-switches.txt || {
    sed -i /ChargerEnable/d $TMPDIR/ch-switches
    sed -i /ChargerEnable/d $execDir/charging-switches.txt
  }
})

# set batt_slate_mode as default charging control file for Exynos devices
# this prevents the "battery level stuck at 70%" issue
if grep_ '^battery/batt_slate_mode 0 1' $TMPDIR/ch-switches; then
  [ -n "$(get_prop chargingSwitch)" ] || set_prop_ chargingSwitch "(battery/batt_slate_mode 0 1)"
fi
