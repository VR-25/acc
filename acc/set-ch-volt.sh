set_ch_volt() {
  if [ -n "${1-}" ]; then

    ${verbose:-true} || {
      execDir=/data/adb/vr25/acc
      exxit() { exit $?; }
      . $execDir/misc-functions.sh
      cd $execDir
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
            noEcho=true
            ! ${verbose:-true} || print_volt_set $1
          } || return 1
      }

      # = [3700-4200] millivolts
      if [ $1 -ge 3700 -a $1 -le 4200 ]; then
        apply_voltage $1 ${2-} || return 1

      # < 3700 millivolts
      elif [ $1 -lt 3700 ]; then
        ! ${verbose:-true} || echo "(!) [3700-4200]$(print_mV; print_only)"
        apply_voltage 3700 ${2-} || return 1

      # > 4200 millivolts
      elif [ $1 -gt 4200 ]; then
        ! ${verbose:-true} || echo "(!) [3700-4200]$(print_mV; print_only)"
        apply_voltage 4200 ${2-} || return 1
      fi
    fi

  else
    # print current value
    ! ${verbose:-true} && echo ${maxChargingVoltage[0]-} \
      || echo "${maxChargingVoltage[0]:-$(print_default)}$(print_mV)"
    return 0
  fi
}
