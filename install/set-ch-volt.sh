set_ch_volt() {
  if [ -n "${1-}" ]; then

    set -- $*

    ${verbose:-true} || {
      exxit() { exit $?; }
      . $execDir/misc-functions.sh
    }

    # restore
    if [ $1 = - ]; then
      apply_on_boot default force
      max_charging_voltage=
      ! ${verbose:-true} || print_volt_restored

    else
      apply_voltage() {
        eval "maxChargingVoltage=($1 $(sed "s|::v|::$1|" $TMPDIR/ch-volt-ctrl-files) ${2-})" \
          && unset max_charging_voltage mcv \
          && apply_on_boot \
          && {
            ! ${verbose:-true} || print_volt_set $1
          } || return 1
      }

      # = [3700-4300] millivolts
      if [ $1 -ge 3700 -a $1 -le 4300 ]; then
        apply_voltage $1 ${2-} || return 1

      # < 3700 millivolts
      elif [ $1 -lt 3700 ]; then
        ! ${verbose:-true} || echo "[3700-4300]$(print_mV; print_only)"
        apply_voltage 3700 ${2-} || return 1

      # > 4300 millivolts
      elif [ $1 -gt 4300 ]; then
        ! ${verbose:-true} || echo "[3700-4300]$(print_mV; print_only)"
        apply_voltage 4300 ${2-} || return 1
      fi
    fi

  else
    # print current value
    ! ${verbose:-true} && echo ${maxChargingVoltage[0]-} \
      || echo "${maxChargingVoltage[0]:-$(print_default)}$(print_mV)"
    return 0
  fi
}
