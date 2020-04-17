set +u

sc=${shutdown_capacity-${sc-${capacity[0]}}}
cc=${cooldown_capacity-${cc-${capacity[1]}}}
rc=${resume_capacity-${rc-${capacity[2]}}}
pc=${pause_capacity-${pc-${capacity[3]}}}
co=${capacity_offset-${co-${capacity[4]}}}
cs=${capacity_sync-${cs-${capacity[5]}}}

ct=${cooldown_temp-${ct-${temperature[0]}}}
mt=${max_temp-${mt-${temperature[1]}}}
mtp=${max_temp_pause-${mtp-${temperature[2]}}}

ccu="${cooldown_custom-${ccu-${cooldownCustom[@]}}}"

cch=${cooldown_charge-${cch-${cooldownRatio[0]}}}
cp=${cooldown_pause-${cp-${cooldownRatio[1]}}}

rbsp=${reset_batt_stats_on_pause-${rbsp-${resetBattStats[0]}}}
rbsu=${reset_batt_stats_on_unplug-${rbsu-${resetBattStats[1]}}}

ldc=${loop_delay_charging-${ldc-${loopDelay[0]}}}
ldd=${loop_delay_discharging-${ldd-${loopDelay[1]}}}

s="${charging_switch-${s-${chargingSwitch[@]}}}"

ab="${apply_on_boot-${ab-${applyOnBoot[@]}}}"
ap="${apply_on_plug-${ap-${applyOnPlug[@]}}}"

mcc="${max_charging_current-${mcc-${maxChargingCurrent[@]}}}"
mcv="${max_charging_voltage-${mcv-${maxChargingVoltage[@]}}}"

rp=${reboot_on_pause-${rp-${rebootOnPause}}}
sd=${switch_delay-${sd-${switchDelay}}}
l=${lang-${l-${language}}}

wu="${wake_unlock-${wu-${wakeUnlock[@]}}}"

pbim=${prioritize_batt_idle_mode-${pbim-${prioritizeBattIdleMode}}}
ff=${force_charging_status_full_at_100-${ff-${forceChargingStatusFullAt100}}}

rcp="${run_cmd_on_pause-${rcp-${runCmdOnPause[@]}}}"

dps=${dyn_power_saving-${dps-${dynPowerSaving}}}

asac="${auto_shutdown_alert_cmd-${asac-${autoShutdownAlertCmd[@]}}}"

cac="${calibration_alert_cmd-${cac-${calibrationAlertCmd[@]}}}"

cdnc="${charg_disabled_notif_cmd-${cdnc-${chargDisabledNotifCmd[@]}}}"

cenc="${charg_enabled_notif_cmd-${cenc-${chargEnabledNotifCmd[@]}}}"

eac="${error_alert_cmd-${eac-${errorAlertCmd[@]}}}"


{
echo "configVerCode=$(cat $TMPDIR/.config-ver)
capacity=(${sc:--1} ${cc:-101} ${rc:-70} ${pc:-75} ${co:-+0} ${cs:-false})
temperature=(${ct:-70} ${mt:-80} ${mtp:90})
cooldownRatio=($cch $cp)
cooldownCustom=($ccu)
resetBattStats=(${rbsp:-false} ${rbsu:-false})
loopDelay=(${ldc:-10} ${ldd:-15})
chargingSwitch=($s)
applyOnBoot=($ab)
applyOnPlug=($ap)
maxChargingCurrent=($mcc)
maxChargingVoltage=($mvc)
rebootOnPause=$rp
switchDelay=${sd:-1.5}
language=${lang:-en}
wakeUnlock=($wu)
prioritizeBattIdleMode=${pbim:-false}
forceChargingStatusFullAt100=$ff
runCmdOnPause=($rcp)
dynPowerSaving=${dps:-0}
autoShutdownAlertCmd=(${asac:-vibrate 5 0.1})
calibrationAlertCmd=(${cac:-vibrate 5 0.1})
chargDisabledNotifCmd=(${cdnc:-vibrate 3 0.1})
chargEnabledNotifCmd=(${cenc:-vibrate 4 0.1})
errorAlertCmd=(${eac:-vibrate 6 0.1})

"
cat $TMPDIR/.config-help
} > $config

set -u
