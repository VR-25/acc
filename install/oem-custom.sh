_grep() { grep -Eq "$1" ${2:-$config}; }
_set_prop() { sed -i "\|^${1}=|s|=.*|=$2|" ${3:-$config}; }
_get_prop() { sed -n "\|^$1=|s|.*=||p" ${2:-$config} 2>/dev/null || :; }

# patch/reset [broken/obsolete] config
if (set +x; . $config) > /dev/null 2>&1; then
  configVer=0$(_get_prop configVerCode)
  defaultConfVer=0$(cat $TMPDIR/.config-ver)
  [ $configVer -eq $defaultConfVer ] || {
    if [ $configVer -lt 202308121 ]; then
      $TMPDIR/acca --set temp_level=0 force_off= capacity_sync=
    elif [ $configVer -lt 202310160 ]; then
      $TMPDIR/acca --set force_off= capacity_sync=
    else
      $TMPDIR/acca --set dummy=
    fi
  }
else
  cat $execDir/default-config.txt > $config
fi

# battery idle mode for OnePlus devices
! _grep '^chargingSwitch=.battery/op_disable_charge 0 1 battery/input_suspend 0 0.$' \
  || loopCmd='[ $(cat battery/input_suspend) != 1 ] || echo 0 > battery/input_suspend'

# battery idle mode for Google Pixel 2/XL and devices with similar hardware
! _grep '^chargingSwitch=./sys/module/lge_battery/parameters/charge_stop_level' \
  || loopCmd='[ $(cat battery/input_suspend) != 1 ] || echo 0 > battery/input_suspend'

# battery idle mode for certain mtk devices
# ! _grep '^chargingSwitch=.battery/input_suspend 0 1 /proc/mtk_battery_cmd/en_power_path 1 1' \
#   || loopCmd='
#     if [ $(cat /proc/mtk_battery_cmd/en_power_path) -eq 0 ] && [ $(cat battery/status) = Discharging ]; then
#       echo 0 > battery/input_suspend
#     fi
#   '

# idle mode - sony xperia
echo 1 > battery_ext/smart_charging_activation 2>/dev/null || :

# block "ghost charging on steroids" (Xiaomi Redmi 3 - ido)
[ ! -f $TMPDIR/accd-ido.log ] || touch $TMPDIR/.ghost-charging

# mt6795, exclude ChargerEnable switches (troublesome)
! getprop | grep -E mt6795 > /dev/null || {
  ! _grep ChargerEnable $execDir/ctrl-files.sh || {
    sed -i /ChargerEnable/d $TMPDIR/ch-switches
    sed -i /ChargerEnable/d $execDir/ctrl-files.sh
  }
}

# set batt_slate_mode as default charging control file for Exynos/Samsung devices
# this prevents the "battery level stuck at 70%" issue
! _grep '^battery/batt_slate_mode 0 1' $TMPDIR/ch-switches \
  || [ -n "$(_get_prop chargingSwitch)" ] \
  || _set_prop chargingSwitch "(battery/batt_slate_mode 0 1)"

unset -f _grep _get_prop _set_prop
unset configVer defaultConfVer
