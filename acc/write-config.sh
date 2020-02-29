# print current or default prop
pcd() {
 ([ -n "$(eval "echo "\${$1-}"")" ] || . $defaultConfig
 eval "echo "\${$1-}"")
}

# update config
cat << EOF > $config
configVerCode=$(get_prop configVerCode $defaultConfig)
capacity=(${shutdown_capacity-${sc-$(pcd "capacity[0]")}} ${cooldown_capacity-${cc-$(pcd "capacity[1]")}} ${resume_capacity-${rc-$(pcd "capacity[2]")}} ${pause_capacity-${pc-$(pcd "capacity[3]")}} ${capacity_offset-${co-$(pcd "capacity[4]")}} ${capacity_sync-${cs-$(pcd "capacity[5]")}})
temperature=(${cooldown_temp-${ct-$(pcd "temperature[0]")}} ${max_temp-${mt-$(pcd "temperature[1]")}} ${max_temp_pause-${mtp-$(pcd "temperature[2]")}})
coolDownRatio=(${cooldown_charge-${cch-$(pcd "coolDownRatio[0]")}} ${cooldown_pause-${cp-$(pcd "coolDownRatio[1]")}})
resetBattStats=(${reset_batt_stats_on_pause-${rbsp-$(pcd "resetBattStats[0]")}} ${reset_batt_stats_on_unplug-${rbsu-$(pcd "resetBattStats[1]")}})
loopDelay=(${loop_delay_charging-${ldc-$(pcd "loopDelay[0]")}} ${loop_delay_discharging-${ldd-$(pcd "loopDelay[1]")}})
chargingSwitch=(${charging_switch-${s-$(pcd "chargingSwitch[@]")}})
applyOnBoot=(${apply_on_boot-${ab-$(pcd "applyOnBoot[@]")}})
applyOnPlug=(${apply_on_plug-${ap-$(pcd "applyOnPlug[@]")}})
maxChargingCurrent=(${max_charging_current-${mcc-$(pcd "maxChargingCurrent[@]")}})
maxChargingVoltage=(${max_charging_voltage-${mcv-$(pcd "maxChargingVoltage[@]")}})
rebootOnPause=${reboot_on_pause-${rp-$(pcd "rebootOnPause")}}
switchDelay=${switch_delay-${sd-$(pcd "switchDelay")}}
language=${lang-${l-$(pcd "language")}}
wakeUnlock=(${wake_unlock-${wu-$(pcd "wakeUnlock[@]")}})
prioritizeBattIdleMode=${prioritize_batt_idle_mode-${pbim-$(pcd "prioritizeBattIdleMode")}}
forceChargingStatusFullAt100=${force_charging_status_full_at_100-${fs-$(pcd "forceChargingStatusFullAt100")}}
runCmdOnPause=(${run_cmd_on_pause-${rcp-$(pcd "runCmdOnPause[@]")}})
dynPowerSaving=${dyn_power_saving-${dps-$(pcd "dynPowerSaving")}}


$(sed -n '/^# /,$p' $defaultConfig)
EOF
