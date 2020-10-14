set +u

sc=${shutdown_capacity-${sc-${capacity[0]}}}
cc=${cooldown_capacity-${cc-${capacity[1]}}}
rc=${resume_capacity-${rc-${capacity[2]}}}
pc=${pause_capacity-${pc-${capacity[3]}}}
cft=${capacity_freeze2-${cft-${capacity[4]}}}

ct=${cooldown_temp-${ct-${temperature[0]}}}
mt=${max_temp-${mt-${temperature[1]}}}
mtp=${max_temp_pause-${mtp-${temperature[2]}}}

cdc=${cooldown_current-${cdc-$cooldownCurrent}}

ccu="${cooldown_custom-${ccu-${cooldownCustom[@]}}}"

cch=${cooldown_charge-${cch-${cooldownRatio[0]}}}
cp=${cooldown_pause-${cp-${cooldownRatio[1]}}}

rbsp=${reset_batt_stats_on_pause-${rbsp-${resetBattStats[0]}}}
rbsu=${reset_batt_stats_on_unplug-${rbsu-${resetBattStats[1]}}}

s="${charging_switch-${s-${chargingSwitch[@]}}}"

ab="${apply_on_boot-${ab-${applyOnBoot[@]}}}"
ap="${apply_on_plug-${ap-${applyOnPlug[@]}}}"

mcc="${max_charging_current-${mcc-${maxChargingCurrent[@]}}}"
mcv="${max_charging_voltage-${mcv-${maxChargingVoltage[@]}}}"

l=${lang-${l-${language}}}

pbim=${prioritize_batt_idle_mode-${pbim-${prioritizeBattIdleMode}}}
rcp="${run_cmd_on_pause-${rcp-${runCmdOnPause[@]}}}"

af=${amp_factor-${af-$ampFactor}}
vf=${volt_factor-${vf-$voltFactor}}

lc="${loop_cmd-${lc-${loopCmd[@]}}}"


{
echo "configVerCode=$(cat $TMPDIR/.config-ver)
capacity=(${sc:--1} ${cc:-60} ${rc:-70} ${pc:-75} ${cft:-false})
temperature=(${ct:-40} ${mt:-60} ${mtp:-90})
cooldownRatio=($cch $cp)
cooldownCurrent=${cdc-0}
cooldownCustom=($ccu)
resetBattStats=(${rbsp:-false} ${rbsu:-false})
chargingSwitch=($s)
applyOnBoot=($ab)
applyOnPlug=($ap)
maxChargingCurrent=($mcc)
maxChargingVoltage=($mcv)
language=${lang:-en}
prioritizeBattIdleMode=${pbim:-false}
runCmdOnPause=($rcp)
ampFactor=$af
voltFactor=$vf
loopCmd=($lc)

"
cat $TMPDIR/.config-help
} > $config

set -u
