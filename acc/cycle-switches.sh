cycle_switches() {

  local chargingSwitch="" on="" off=""

  while read -A chargingSwitch; do

    [[ ${chargingSwitch[0]} != \#* ]] || continue

    if [ -f ${chargingSwitch[0]} ]; then
      on="${chargingSwitch[1]//::/ }"
      off="${chargingSwitch[2]//::/ }"
      chmod +w ${chargingSwitch[0]} && eval "echo "\$$1"" > ${chargingSwitch[0]} || continue

      # toggle secondary switch
      if [ -f "${chargingSwitch[3]-}" ]; then
        on="${chargingSwitch[4]//::/ }"
        off="${chargingSwitch[5]//::/ }"
        chmod +w ${chargingSwitch[3]} && eval "echo "\$$1"" > ${chargingSwitch[3]} || :
      fi

      sleep $switchDelay

      # prioritizeBattIdleMode (if $2 == "not") or reset switches (if at least one fails to toggle charging)
      if { [ "$1" == off ] && ! grep -Eiq "${2:-dis|not}" $batt/status; } \
        || { [ "$1" == on ] && grep -Eiq 'dis|not' $batt/status; }
      then
        { echo "${chargingSwitch[1]//::/ }" > ${chargingSwitch[0]} || :
        echo "${chargingSwitch[4]//::/ }" > ${chargingSwitch[3]:-/dev/null} || :; } 2>/dev/null
        # blacklist non-working switches
        #[ "$1" == off ] && ! grep -Eiq 'dis|not' $batt/status \
          #&& sed -i "\|${chargingSwitch[@]}|s|^|#|" $TMPDIR/charging-switches || :
      else
        break
      fi

    fi
  done < $TMPDIR/charging-switches

  # if there's only one known charging switch, set it (for greater efficiency)
  [ 0$(grep -cv '^#' $TMPDIR/charging-switches) -ne 01 ] \
    || sed -i "\|^chargingSwitch=|s|=.*|=\($(grep -v '^#' $TMPDIR/charging-switches)\)|" $config
}
