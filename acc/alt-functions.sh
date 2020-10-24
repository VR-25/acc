disable_charging() {
  maxChargingCurrent0=${maxChargingCurrent[0]-}
  set +e
  set_ch_curr ${chargingSwitch[0]:-0}
  set -e
  chargingDisabled=true
}

enable_charging() {
  set +e
  set_ch_curr ${maxChargingCurrent0:--}
  set -e
  chargingDisabled=false
}
