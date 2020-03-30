apply_on_boot() {

  local entry="" file="" value="" default="" arg=${1:-value} exitCmd=false force=false

  [ ${2:-x} != force ] || force=true
 
  [[ "${applyOnBoot[@]:-x}${maxChargingVoltage[@]-}" != *--exit* ]] || exitCmd=true

  for entry in "${applyOnBoot[@]-}" "${maxChargingVoltage[@]-}"; do
    [ "$entry" != --exit ] || continue
    set -- ${entry//::/ }
    file=${1-}
    value=${2-}
    { $exitCmd && ! $force; } && default=${2-} || default=${3:-${2-}}
    [ -f "$file" ] && chmod +w $file && eval "echo \$$arg" > $file || :
  done

  $exitCmd && [ $arg == value ] && exit 0 || :
}


apply_on_plug() {
  local entry="" file="" value="" default="" arg=${1:-value}
  for entry in "${applyOnPlug[@]-}" "${maxChargingCurrent[@]-}"; do
    set -- ${entry//::/ }
    file=${1-}
    value=${2-}
    default=${3:-${2-}}
    [ -f "$file" ] && chmod +w $file && eval "echo \$$arg" > $file || :
  done
}


cycle_switches() {

  local on="" off=""

  while read -A chargingSwitch; do

    [ ! -f ${chargingSwitch[0]} ] || {

      # toggle primary switch
      on="${chargingSwitch[1]//::/ }"
      off="${chargingSwitch[2]//::/ }"
      chmod +w ${chargingSwitch[0]} \
        && eval "echo "\$$1"" > ${chargingSwitch[0]} \
        || continue

      # toggle secondary switch
      [ ! -f "${chargingSwitch[3]-}" ] || {
        on="${chargingSwitch[4]//::/ }"
        off="${chargingSwitch[5]//::/ }"
        chmod +w ${chargingSwitch[3]} \
          && eval "echo "\$$1"" > ${chargingSwitch[3]} || :
      }

      sleep $switchDelay

      if [ "$1" == off ] && ! grep -Eiq "${2:-dis|not}" $batt/status; then
        # reset switch/group that fails to disable charging
        { echo "${chargingSwitch[1]//::/ }" > ${chargingSwitch[0]} || :
        echo "${chargingSwitch[4]//::/ }" > ${chargingSwitch[3]:-/dev/null} || :; } 2>/dev/null
      else
        # enforce working switch/group
        . $modPath/write-config.sh
        break
      fi

    }
  done < $TMPDIR/charging-switches
}


disable_charging() {

  $isAccd || {
    apply_on_boot default
    apply_on_plug default
  }

  if [[ ${chargingSwitch[0]:-x} == */* ]]; then
    if [ -f ${chargingSwitch[0]} ]; then
      # toggle primary switch
      if chmod +w ${chargingSwitch[0]} && echo "${chargingSwitch[2]//::/ }" > ${chargingSwitch[0]}; then
        [ ! -f "${chargingSwitch[3]-}" ] || {
          # toggle secondary switch
          chmod +w ${chargingSwitch[3]} && echo "${chargingSwitch[5]//::/ }" > ${chargingSwitch[3]} || {
            $isAccd || print_switch_fails
            unset_switch
            $isAccd || return 1
          }
        }
        sleep $switchDelay
        not_charging || {
          unset_switch
          return 3
        }
      else
        $isAccd || print_switch_fails
        unset_switch
        $isAccd || return 1
      fi
    else
      $isAccd || print_invalid_switch
      unset_switch
      $isAccd || return 1
    fi
  else
    ! $prioritizeBattIdleMode || cycle_switches off not
    not_charging || cycle_switches off
  fi

  if not_charging; then
    # if maxTemp is reached, keep charging paused for ${temperature[2]} seconds more
    ! $isAccd || {
      [ ! $(cat $batt/temp 2>/dev/null || cat $batt/batt_temp) -ge $(( ${temperature[1]} * 10 )) ] \
        || sleep ${temperature[2]}
    }
  else
    return 3
  fi

  if [ -n "${1-}" ]; then
    case $1 in
      *%)
        print_charging_disabled_until $1
        echo
        (until [ $(( $(cat $batt/capacity) ${capacity[4]} )) -le ${1%\%} ]; do
          sleep ${loopDelay[1]}
          set +x
        done)
        enable_charging || try_enabling_again
      ;;
      *[hms])
        print_charging_disabled_for $1
        echo
        case $1 in
          *h) sleep $(( ${1%h} * 3600 ));;
          *m) sleep $(( ${1%m} * 60 ));;
          *s) sleep ${1%s};;
        esac
        enable_charging || try_enabling_again
      ;;
      *)
        print_charging_disabled
      ;;
    esac
  else
    $isAccd || print_charging_disabled
  fi
}


enable_charging() {

  if ! $ghostCharging || { $ghostCharging && [[ "$(acpi -a)" == *on-line* ]]; }; then

    $isAccd || apply_on_plug

    if [[ ${chargingSwitch[0]:-x} == */* ]]; then
      if [ -f ${chargingSwitch[0]} ]; then
        # toggle primary switch
        if chmod +w ${chargingSwitch[0]} && echo "${chargingSwitch[1]//::/ }" > ${chargingSwitch[0]}; then
          # toggle secondary switch
          [ ! -f "${chargingSwitch[3]-}" ] || {
            chmod +w ${chargingSwitch[3]} && echo "${chargingSwitch[4]//::/ }" > ${chargingSwitch[3]} || {
              $isAccd || print_switch_fails
              unset_switch
              $isAccd || return 1
            }
          }
          sleep $switchDelay
        else
          $isAccd || print_switch_fails
          unset_switch
          $isAccd || return 1
        fi
      else
        $isAccd || print_invalid_switch
        unset_switch
        $isAccd || return 1
      fi
    else
      cycle_switches on
    fi

    # detect and block ghost charging
    if ! $ghostCharging && ! not_charging && [[ "$(acpi -a)" != *on-line* ]]; then
      ghostCharging=true
      { disable_charging || try_disabling_again; } > /dev/null
      touch $TMPDIR/.ghost-charging
      $isAccd || {
        echo "(i) ghostCharging=true"
        print_unplugged
      }
      $isAccd || return 2
    fi

    if [ -n "${1-}" ]; then
      case $1 in
        *%)
          print_charging_enabled_until $1
          echo
          (until [ $(( $(cat $batt/capacity) ${capacity[4]} )) -ge ${1%\%} ]; do
            sleep ${loopDelay[1]}
            set +x
          done)
          [ -n "${2-}" ] || {
            disable_charging || try_disabling_again
          }
        ;;
        *[hms])
          print_charging_enabled_for $1
          echo
          case $1 in
            *h) sleep $(( ${1%h} * 3600 ));;
            *m) sleep $(( ${1%m} * 60 ));;
            *s) sleep ${1%s};;
          esac
          disable_charging || try_disabling_again
        ;;
        *)
          print_charging_enabled
        ;;
      esac
    else
      $isAccd || print_charging_enabled
    fi

  else
    $isAccd || {
      echo "(i) ghostCharging=true"
      print_unplugged
    }
    $isAccd || return 2
  fi
}


not_charging() { grep -Eiq 'dis|not' $batt/status; }


try_disabling_again() {
  local n=""
  disable_charging "$@" && return 0 || {
    n=$?
    [ $n -ne 3 ] && return $n || {
      while [ $n -le 18 ]; do
        [ ! ${switchDelay%.?} -lt $n ] || {
          switchDelay=$n
          disable_charging "$@" && break || {
            [ $n -ne 18 ] || {
              $isAccd || print_unsupported
              exit 7
            }
          }
        }
        n=$(( n + 3 ))
      done
      # save working switchDelay
      ! not_charging || . $modPath/write-config.sh
    }
  }
}


try_enabling_again() {
  ! $ghostCharging || {
    (while [[ "$(acpi -a)" != *on-line* ]]; do
      sleep ${loopDelay[1]}
      set +x
    done)
  }
  enable_charging "$@"
}


unset_switch() {
  chargingSwitch=()
  . $modPath/write-config.sh
}


vibrate() {
  local c=0
  while [ $c -lt $1 ]; do
    echo -en '\a'
    sleep $2
    c=$(( c + 1 ))
  done
}
