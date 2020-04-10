set +u
{
echo "configVerCode=$(cat $TMPDIR/.config-ver)
capacity=(${shutdown_capacity-${sc-${capacity[0]}}} ${cooldown_capacity-${cc-${capacity[1]}}} ${resume_capacity-${rc-${capacity[2]}}} ${pause_capacity-${pc-${capacity[3]}}} ${capacity_offset-${co-${capacity[4]}}} ${capacity_sync-${cs-${capacity[5]}}})
temperature=(${cooldown_temp-${ct-${temperature[0]}}} ${max_temp-${mt-${temperature[1]}}} ${max_temp_pause-${mtp-${temperature[2]}}})
cooldownCustom=(${cooldown_custom-${ccu-${cooldownCurrent[@]}}})
cooldownRatio=(${cooldown_charge-${cch-${cooldownRatio[0]}}} ${cooldown_pause-${cp-${cooldownRatio[1]}}})
resetBattStats=(${reset_batt_stats_on_pause-${rbsp-${resetBattStats[0]}}} ${reset_batt_stats_on_unplug-${rbsu-${resetBattStats[1]}}})
loopDelay=(${loop_delay_charging-${ldc-${loopDelay[0]}}} ${loop_delay_discharging-${ldd-${loopDelay[1]}}})
chargingSwitch=(${charging_switch-${s-${chargingSwitch[@]}}})
applyOnBoot=(${apply_on_boot-${ab-${applyOnBoot[@]}}})
applyOnPlug=(${apply_on_plug-${ap-${applyOnPlug[@]}}})
maxChargingCurrent=(${max_charging_current-${mcc-${maxChargingCurrent[@]}}})
maxChargingVoltage=(${max_charging_voltage-${mcv-${maxChargingVoltage[@]}}})
rebootOnPause=${reboot_on_pause-${rp-${rebootOnPause}}}
switchDelay=${switch_delay-${sd-${switchDelay}}}
language=${lang-${l-${language}}}
wakeUnlock=(${wake_unlock-${wu-${wakeUnlock[@]}}})
prioritizeBattIdleMode=${prioritize_batt_idle_mode-${pbim-${prioritizeBattIdleMode}}}
forceChargingStatusFullAt100=${force_charging_status_full_at_100-${ff-${forceChargingStatusFullAt100}}}
runCmdOnPause=(${run_cmd_on_pause-${rcp-${runCmdOnPause[@]}}})
dynPowerSaving=${dyn_power_saving-${dps-${dynPowerSaving}}}
vibrationPatterns=(${vibration_patterns-${vp-${vibrationPatterns[@]}}})

"
cat $TMPDIR/.config-help
} > $config
set -u
