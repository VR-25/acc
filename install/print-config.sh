set +u

echo "allow_idle_above_pcap=$allowIdleAbovePcap
amp_factor=$ampFactor
batt_status_workaround=$battStatusWorkaround

capacity_mask=${capacity[5]}
capacity_sync=${capacity[4]}

cooldown_capacity=${capacity[1]}
cooldown_charge=${cooldownRatio[0]}
cooldown_current=$cooldownCurrent
cooldown_pause=${cooldownRatio[1]}
cooldown_temp=${temperature[0]}

current_workaround=$currentWorkaround
discharge_polarity=$dischargePolarity
force_off=$forceOff
idle_threshold=$idleThreshold
lang=$language

max_temp=${temperature[1]}
resume_temp=${temperature[2]}
max_temp_pause=${temperature[2]%r}

off_mid=$offMid
pause_capacity=${capacity[3]}
prioritize_batt_idle_mode=$prioritizeBattIdleMode
reboot_resume=$rebootResume

reset_batt_stats_on_pause=${resetBattStats[0]}
reset_batt_stats_on_plug=${resetBattStats[2]}
reset_batt_stats_on_unplug=${resetBattStats[1]}

resume_capacity=${capacity[2]}
shutdown_capacity=${capacity[0]}
shutdown_temp=${temperature[3]}
temp_level=$tempLevel
volt_factor=$voltFactor

apply_on_boot=${applyOnBoot[@]}

apply_on_plug=${applyOnPlug[@]}

batt_status_override=$battStatusOverride

charging_switch=${chargingSwitch[@]}

cooldown_custom=${cooldownCustom[@]}

max_charging_current=${maxChargingCurrent[0]}

max_charging_voltage=${maxChargingVoltage[0]}

run_cmd_on_pause=$runCmdOnPause

loop_cmd=" #legacy, AccSettings

[ "${1-.}" = ns ] || sed -n 's/^:/\n:/p' $config
