(
grep_() { grep -Eq "$1" ${2:-$config}; }

get_prop() { sed -n "\|^$1=|s|.*=||p" ${2:-$config}; }

set_prop_() { sed -i "\|^${1}=|s|=.*|=$2|" ${3:-$config}; }


# patch/reset [broken] config
configVer=$(get_prop configVerCode 2>/dev/null || :)
defaultConfVer=$(get_prop configVerCode $modPath/default-config.txt)
if /system/bin/sh -n $config; then
  [ ${configVer:-0} -eq $defaultConfVer ] || /sbin/acca --set dummy=
else
  cp -f $modPath/default-config.txt $config
  rm /sdcard/acc-logs-*.tar.bz2 || : ### legacy
fi 2>/dev/null


# /proc/... switches
if grep_ '/proc/' $TMPDIR/ch-switches || grep_ '^chargingSwitch=.*/proc/'; then
  # charging switch
  grep_ '^chargingSwitch=.*/proc/' \
    || set_prop_ chargingSwitch "($(grep '/proc/' $TMPDIR/ch-switches | head -n 1))"
  # switchDelay
  switchDelay=$(get_prop switchDelay)
  [ ${switchDelay%.*} -gt 2 ] || set_prop_ switchDelay 3.5
fi


# 1+7pro battery idle mode
if grep_ '^chargingSwitch=.*/op_disable_charge'; then
  [ -f $TMPDIR/oem-custom ] \
    || echo "chmod +w battery/input_suspend; echo 1 > battery/op_disable_charge; echo 0 > battery/input_suspend" > $TMPDIR/oem-custom
  grep_ "^runCmdOnPause=.*$TMPDIR/oem-custom" \
    || set_prop_ runCmdOnPause "(. $TMPDIR/oem-custom)"
  switchDelay=$(get_prop switchDelay)
  [ ${switchDelay%.*} -gt 4 ] || set_prop_ switchDelay 5
else
  ! grep_ '1 \> .*/op_disable_charge' $TMPDIR/oem-custom 2>/dev/null \
    || rm $TMPDIR/oem-custom
  ! grep_ "^runCmdOnPause=.*$TMPDIR/oem-custom" 2>/dev/null || {
    set_prop_ runCmdOnPause "()"
    set_prop_ switchDelay 1.5
  }
fi


# Razer
# default value: 65
(set +e
echo 30 > /sys/devices/platform/soc/*/*/*/razer_charge_limit_dropdown
echo 30 > usb/razer_charge_limit_dropdown) 2>/dev/null || :


# block ghost charging on steroids (Xiaomi Redmi 3 - ido)
[ ! -f $TMPDIR/accd-ido.log ] || touch $TMPDIR/.ghost-charging
)
