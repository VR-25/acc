set +u

echo "shutdown_capacity=${capacity[0]}
resume_capacity=${capacity[2]}
pause_capacity=${capacity[3]}
capacity_sync=${capacity[4]}
capacity_mask=${capacity[5]}

cooldown_capacity=${capacity[1]}
cooldown_temp=${temperature[0]}
cooldown_charge=${cooldownRatio[0]}
cooldown_pause=${cooldownRatio[1]}

max_temp=${temperature[1]}
max_temp_pause=${temperature[2]}

shutdown_temp=${temperature[3]}

cooldown_current=$cooldownCurrent

cooldown_custom=${cooldownCustom[@]}

reset_batt_stats_on_pause=${resetBattStats[0]}
reset_batt_stats_on_unplug=${resetBattStats[1]}
reset_batt_stats_on_plug=${resetBattStats[2]}

charging_switch=${chargingSwitch[@]}

apply_on_boot=${applyOnBoot[@]}

apply_on_plug=${applyOnPlug[@]}

max_charging_current=${maxChargingCurrent[0]}

max_charging_voltage=${maxChargingVoltage[0]}

lang=$language

run_cmd_on_pause='$runCmdOnPause'

amp_factor=$ampFactor
volt_factor=$voltFactor

prioritize_batt_idle_mode=$prioritizeBattIdleMode
current_workaround=$currentWorkaround
batt_status_workaround=$battStatusWorkaround

sched='$schedule'

batt_status_override='$battStatusOverride'

reboot_resume=$rebootResume

discharge_polarity=$dischargePolarity

off_mid=$offMid

force_off=$forceOff

temp_level=$tempLevel
"

sed -n '/^: /p' $config
