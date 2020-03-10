(
_grep() { grep -Eq "$1" ${2:-$config}; }

get_prop() { sed -n "\|^$1=|s|.*=||p" $config; }

set_prop() { sed -i "\|^${1}=|s|=.*|=$2|" ${3:-$config}; }


# /proc/... switches
if _grep '/proc/' $TMPDIR/charging-switches || _grep '^chargingSwitch=.*/proc/'; then
  # charging switch
  _grep '^chargingSwitch=.*/proc/' \
    || set_prop chargingSwitch "($(grep '/proc/' $TMPDIR/charging-switches | head -n 1))"
  # switchDelay
  switchDelay=$(get_prop switchDelay)
  [ ${switchDelay%.*} -gt 2 ] || set_prop switchDelay 3.5
fi


# single switch
if [ 0$(grep -cv '^#' $TMPDIR/charging-switches) -eq 01 ]; then
  _grep '^chargingSwitch=.*/' \
    || set_prop chargingSwitch "($(grep -v '^#' $TMPDIR/charging-switches))"
fi


# 1+7pro battery idle mode
if _grep '^chargingSwitch=.*/op_disable_charge'; then
  [ -f $TMPDIR/oem-custom ] \
    || echo "chmod +w battery/input_suspend; echo 1 > battery/op_disable_charge; echo 0 > battery/input_suspend" > $TMPDIR/oem-custom
  _grep "^runCmdOnPause=.*$TMPDIR/oem-custom" \
    || set_prop runCmdOnPause "(. $TMPDIR/oem-custom)"
  switchDelay=$(get_prop switchDelay)
  [ ${switchDelay%.*} -gt 2 ] || set_prop switchDelay 3.5
else
  ! _grep '1 \> .*/op_disable_charge' $TMPDIR/oem-custom 2>/dev/null \
    || rm $TMPDIR/oem-custom
  ! _grep "^runCmdOnPause=.*$TMPDIR/oem-custom" 2>/dev/null \
    || set_prop runCmdOnPause "()"
  ! _grep 'switchDelay=3.5' || set_prop switchDelay 1.5
fi


# Razer
# default value: 65
{ echo 30 > /sys/devices/platform/soc/*/*/*/razer_charge_limit_dropdown || :
echo 30 > usb/razer_charge_limit_dropdown || :; } 2>/dev/null


 # 202002280, patch config, forceFullStatusAt100
! _grep '^forceFullStatusAt100=' \
  || /sbin/acca --set force_charging_status_full_at_100=$(get_prop forceFullStatusAt100)


# 202002290, patch config, remove ghostCharging
! _grep '^ghostCharging=' || /sbin/acca --set dummy=


# 202003030, patch config, switchDelay=1.5, dynPowerSaving=0
if [ $(get_prop configVerCode) -lt 202003030 ]; then
  sed -i -e "/^configVerCode=/s/=.*/=202003030/" \
    -e "/^switchDelay=/s/=.*/=1.5/" \
    -e "/^dynPowerSaving=/s/=.*/=0/" $config
  . $modPath/oem-custom.sh
fi

# block ghost charging on steroids (Xiaomi Redmi 3 - ido)
[ ! -f $TMPDIR/accd-ido.log ] || touch $TMPDIR/.ghost-charging

# 202003110, patch config, /coolDown/cooldown
! _grep coolDown || {
  set_prop configVerCode 202003110
  sed -i 's/coolDown/cooldown/' $config
}
)
