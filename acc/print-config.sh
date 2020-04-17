set +u

echo "shutdown_capacity=${capacity[0]}
resume_capacity=${capacity[2]}
pause_capacity=${capacity[3]}
capacity_offset=${capacity[4]}
capacity_sync=${capacity[5]}

cooldown_capacity=${capacity[1]}
cooldown_temp=${temperature[0]}
cooldown_charge=${cooldownRatio[0]}
cooldown_pause=${cooldownRatio[1]}

max_temp=${temperature[1]}
max_temp_pause=${temperature[2]}

cooldown_custom=${cooldownCustom[@]}

reset_batt_stats_on_pause=${resetBattStats[0]}
reset_batt_stats_on_unplug=${resetBattStats[1]}

loop_delay_charging=${loopDelay[0]}
loop_delay_discharging=${loopDelay[1]}

charging_switch=${chargingSwitch[@]}

apply_on_boot=${applyOnBoot[@]}

apply_on_plug=${applyOnPlug[@]}

max_charging_current=${maxChargingCurrent[@]}

max_charging_voltage=${maxChargingVoltage[@]}

reboot_on_pause=$rebootOnPause
switch_delay=$switchDelay
lang=$language

wake_unlock=${wakeUnlock[@]}

prioritize_batt_idle_mode=$prioritizeBattIdleMode
force_charging_status_full_at_100=$forceChargingStatusFullAt100

run_cmd_on_pause=${runCmdOnPause[@]}

dyn_power_saving=${dynPowerSaving}

auto_shutdown_alert_cmd=${autoShutdownAlertCmd[@]}

calibration_alert_cmd=${calibrationAlertCmd[@]}

charg_enabled_notif_cmd=${chargEnabledNotifCmd[@]}

error_alert_cmd=${errorAlertCmd[@]}

charg_disabled_notif_cmd=${chargDisabledNotifCmd[@]}"
