# flag MediaTek "unplugged, but charging" madness
mtkMadness=false
if [[ ${chargingSwitch[0]:-x} == *mtk_battery_cmd* ]] \
  || grep -q 'mtk_battery_cmd' $TMPDIR/charging-switches
then
  mtkMadness=true
fi
