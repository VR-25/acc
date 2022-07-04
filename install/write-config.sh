set +u

sc=${shutdown_capacity-${sc-${capacity[0]}}}
cc=${cooldown_capacity-${cc-${capacity[1]}}}
rc=${resume_capacity-${rc-${capacity[2]}}}
pc=${pause_capacity-${pc-${capacity[3]}}}
cs=${capacity_sync-${cs-${capacity[4]}}}
cm=${capacity_mask-${cm-${capacity[5]}}}

ct=${cooldown_temp-${ct-${temperature[0]}}}
mt=${max_temp-${mt-${temperature[1]}}}
mtp=${max_temp_pause-${mtp-${temperature[2]}}}
st=${shutdown_temp-${st-${temperature[3]}}}

cdc=${cooldown_current-${cdc-$cooldownCurrent}}

ccu="${cooldown_custom-${ccu-${cooldownCustom[@]}}}"

cch=${cooldown_charge-${cch-${cooldownRatio[0]}}}
cp=${cooldown_pause-${cp-${cooldownRatio[1]}}}

rbsp=${reset_batt_stats_on_pause-${rbsp-${resetBattStats[0]}}}
rbsu=${reset_batt_stats_on_unplug-${rbsu-${resetBattStats[1]}}}
rbspl=${reset_batt_stats_on_plug-${rbspl-${resetBattStats[2]}}}

s="${charging_switch-${s-${chargingSwitch[@]}}}"

ab="${apply_on_boot-${ab-${applyOnBoot[@]}}}"
ap="${apply_on_plug-${ap-${applyOnPlug[@]}}}"

mcc="${max_charging_current-${mcc-${maxChargingCurrent[@]}}}"
mcv="${max_charging_voltage-${mcv-${maxChargingVoltage[@]}}}"

l=${lang-${l-${language}}}

rcp="${run_cmd_on_pause-${rcp-${runCmdOnPause[@]}}}"

af=${amp_factor-${af-$ampFactor}}
vf=${volt_factor-${vf-$voltFactor}}

lc="${loop_cmd-${lc-${loopCmd[@]}}}"

pbim=${prioritize_batt_idle_mode-${pbim-$prioritizeBattIdleMode}}

cw=${current_workaround-${cw-$currentWorkaround}}

bsw=${batt_status_workaround-${bsw-$battStatusWorkaround}}

sd=${sched-${sd-$schedule}}

bso="${batt_status_override-${bso-$battStatusOverride}}"

rr="${reboot_resume-${rr-$rebootResume}}"

dp="${discharge_polarity-${dp-$dischargePolarity}}"

om="${off_mid-${om-$offMid}}"

fo="${force_off-${fo-$forceOff}}"

tl="${temp_level-${tl-$tempLevel}}"


# schedule -- append/delete
case "$sd" in
  +*)
    sd="${schedule-}
${sd#+}"
    sd="$(echo "$sd" | sed '/^$/d')"
  ;;
  -*)
    sd="$(echo "${schedule-}" | sed "\%${sd#-}%d")"
  ;;
esac


# enforce valid pc and rc difference
[ $rc -lt $pc ] || {
  [ $pc -gt 3000 ] && rc=$((pc - 50)) || rc=$((pc - 5))
}


# backup scripts
! grep '^: ' $config > $TMPDIR/.scripts 2>/dev/null && echo > $TMPDIR/.scripts || {
  sed -i '/: one-line script sample/d; /:/s/$/\n/' $TMPDIR/.scripts
  echo >> $TMPDIR/.scripts
}


echo "configVerCode=$(cat $TMPDIR/.config-ver)

capacity=(${sc:--1} ${cc:-60} ${rc:-70} ${pc:-75} ${cs:-false} ${cm:-false})

temperature=(${ct:-40} ${mt:-60} ${mtp:-90} ${st:-65})

cooldownRatio=($cch $cp)
cooldownCurrent=$cdc
cooldownCustom=($ccu)

resetBattStats=(${rbsp:-false} ${rbsu:-false} ${rbspl:-false})

chargingSwitch=($(echo "$s" | sed 's/ m[AV]//'))

applyOnBoot=($ab)

applyOnPlug=($ap)

maxChargingCurrent=($mcc)

maxChargingVoltage=($mcv)

language=$lang

runCmdOnPause='$rcp'

ampFactor=$af
voltFactor=$vf

loopCmd='$lc'

prioritizeBattIdleMode=${pbim:-false}
currentWorkaround=${cw:-false}
battStatusWorkaround=${bsw:-true}

schedule='$sd'

battStatusOverride='$bso'

rebootResume=${rr:-false}

dischargePolarity=$dp

offMid=${om:-true}

forceOff=$fo

tempLevel=${tl:-0}

: one-line script sample; echo nothing >/dev/null
" > $config

cat $TMPDIR/.scripts $TMPDIR/.config-help >> $config
set -u
