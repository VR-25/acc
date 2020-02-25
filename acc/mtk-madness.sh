# flag MediaTek "unplugged, but charging" madness
grep -q 'mtk_battery_cmd' $TMPDIR/charging-switches && mtkMadness=true || mtkMadness=false
