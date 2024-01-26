(set +u
s0="${charging_switch-${s}}"


ab="${apply_on_boot-${ab-${applyOnBoot[@]}}}"
af=${amp_factor-${af-$ampFactor}}
aiapc="${allow_idle_above_pcap-${aiapc-$allowIdleAbovePcap}}"
ap="${apply_on_plug-${ap-${applyOnPlug[@]}}}"
bso="${batt_status_override-${bso-$battStatusOverride}}"
bsw=${batt_status_workaround-${bsw-$battStatusWorkaround}}
cc=${cooldown_capacity-${cc-${capacity[1]}}}
cch=${cooldown_charge-${cch-${cooldownRatio[0]}}}
ccu="${cooldown_custom-${ccu-${cooldownCustom[@]}}}"
cdc=${cooldown_current-${cdc-$cooldownCurrent}}
cm=${capacity_mask-${cm-${capacity[5]}}}
cp=${cooldown_pause-${cp-${cooldownRatio[1]}}}
cs=${capacity_sync-${cs-${capacity[4]}}}
ct=${cooldown_temp-${ct-${temperature[0]}}}
cw=${current_workaround-${cw-$currentWorkaround}}
dp="${discharge_polarity-${dp-$dischargePolarity}}"
fo="${force_off-${fo-$forceOff}}"
ia="${idle_apps-${ia-${idleApps[@]}}}"
it="${idle_threshold-${it-$idleThreshold}}"
l=${lang-${l-${language}}}
mcc="${max_charging_current-${mcc-${maxChargingCurrent[@]}}}"
mcv="${max_charging_voltage-${mcv-${maxChargingVoltage[@]}}}"
mt=${max_temp-${mt-${temperature[1]}}}
om="${off_mid-${om-$offMid}}"
pbim=${prioritize_batt_idle_mode-${pbim-$prioritizeBattIdleMode}}
pc=${pause_capacity-${pc-${capacity[3]}}}
rbsp=${reset_batt_stats_on_pause-${rbsp-${resetBattStats[0]}}}
rbspl=${reset_batt_stats_on_plug-${rbspl-${resetBattStats[2]}}}
rbsu=${reset_batt_stats_on_unplug-${rbsu-${resetBattStats[1]}}}
rc=${resume_capacity-${rc-${capacity[2]}}}
rcp="${run_cmd_on_pause-${rcp-${runCmdOnPause[@]}}}"
rr="${reboot_resume-${rr-$rebootResume}}"
rt=${resume_temp-${rt-${temperature[2]}}}
s="${charging_switch-${s-${chargingSwitch[@]}}}"
sc=${shutdown_capacity-${sc-${capacity[0]}}}
st=${shutdown_temp-${st-${temperature[3]}}}
tl="${temp_level-${tl-$tempLevel}}"
vf=${volt_factor-${vf-$voltFactor}}


# backup scripts
touch $TMPDIR/.scripts
grep '^:' $config > $TMPDIR/.scripts 2>/dev/null || :
sed -i 's/^:/\n:/' $TMPDIR/.scripts
printf "\n\n\n" >> $TMPDIR/.scripts


# enforce valid capacity and temp limits

: ${pc:=75}
: ${rc:=70}

[ $rc -lt $pc ] || {
  [ $pc -gt 3000 ] && rc=$((pc - 50)) || rc=$((pc - 5))
}

: ${mt:=50}
: ${rt:=45}

if [ ${rt%r} -ge $mt ] || [ $((mt - ${rt%r})) -gt 10 ]; then
  ! ${acc_f:-false} || rt=r
  case $rt in
    *r) rt=$((mt - 1))r;;
    *) rt=$((mt - 1));;
  esac
fi


# reset switch (in auto-mode) if pbim has changed
case "${chargingSwitch[*]}" in
  *--) ;;
  *)
    if [ -z "$s0" ] && [ ".$pbim" != ".$prioritizeBattIdleMode" ]; then
      s=
    fi;;
esac


echo "configVerCode=$(cat $TMPDIR/.config-ver)

allowIdleAbovePcap=${aiapc:-false}
ampFactor=$af
battStatusWorkaround=${bsw:-true}
capacity=(${sc:-5} ${cc:-50} $rc $pc ${cs:-false} ${cm:-false})
cooldownCurrent=$cdc
cooldownRatio=($cch $cp)
currentWorkaround=${cw:-false}
dischargePolarity=$dp
forceOff=${fo:-false}
idleApps=($ia)
idleThreshold=${it:-30}
language=${lang:-en}
offMid=${om:-true}
prioritizeBattIdleMode=${pbim:-true}
rebootResume=${rr:-false}
resetBattStats=(${rbsp:-false} ${rbsu:-false} ${rbspl:-false})
temperature=(${ct:-35} ${mt:-50} ${rt:-45} ${st:-55})
tempLevel=${tl:-0}
voltFactor=$vf

applyOnBoot=($ab)

applyOnPlug=($ap)

battStatusOverride='$bso'

chargingSwitch=($(echo "$s" | sed 's/ m[AV]//'))

cooldownCustom=($ccu)

maxChargingCurrent=($mcc)

maxChargingVoltage=($mcv)

runCmdOnPause='$rcp'" > $config


cat $TMPDIR/.scripts $TMPDIR/.config-help >> $config
rm $TMPDIR/.scripts
set -u)
