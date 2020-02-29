(
# /proc/... switches
if grep -q '/proc/' $TMPDIR/charging-switches; then
  # charging switch
  grep -q '^chargingSwitch=.*/proc/' $config \
    || sed -i "\|^chargingSwitch=|s|=.*|=\($(grep '/proc/' $TMPDIR/charging-switches | head -n 1)\)|" $config
fi

# single switch
if [ 0$(grep -cv '^#' $TMPDIR/charging-switches) -eq 01 ]; then
  grep -q '^chargingSwitch=.*/' $config \
    || sed -i "\|^chargingSwitch=|s|=.*|=\($(grep -v '^#' $TMPDIR/charging-switches)\)|" $config
fi

# 1+7pro battery idle mode
if grep -q '^chargingSwitch=.*/op_disable_charge' $config; then
  [ -f $TMPDIR/oem-custom ] \
    || echo "(exec 2>/dev/null; echo 0 > battery/input_suspend; echo 1 > battery/op_disable_charge)" > $TMPDIR/oem-custom
  grep -q "^runCmdOnPause=.*$TMPDIR/oem-custom" $config \
    || sed -i "\|^runCmdOnPause=|s|=.*|=\(. $TMPDIR/oem-custom\)|" $config
else
  ! grep -q '1 \> .*/op_disable_charge' $TMPDIR/oem-custom 2>/dev/null \
    || rm $TMPDIR/oem-custom
  ! grep -q "^runCmdOnPause=.*$TMPDIR/oem-custom" $config 2>/dev/null \
    || sed -i "\|^runCmdOnPause=|s|=.*|=\(\)|" $config
fi

# Razer
# default value: 65
{ echo 30 > /sys/devices/platform/soc/*/*/*/razer_charge_limit_dropdown || :
echo 30 > usb/razer_charge_limit_dropdown || :; } 2>/dev/null

 # 202002280, patch config, forceFullStatusAt100
! grep -q '^forceFullStatusAt100=' $config \
  || /sbin/acca --set force_charging_status_full_at_100=$(grep '^forceFullStatusAt100=' $config | sed 's/.*=//')

# 202002290, patch config, remove ghostCharging
! grep -q '^ghostCharging=' $config \
  || /sbin/acca --set dummy=
)
