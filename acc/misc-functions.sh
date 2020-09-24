apply_on_boot() {

  local entry="" file="" value="" default="" arg=${1:-value} exitCmd=false force=false

  [ ${2:-x} != force ] || force=true

  [[ "${applyOnBoot[@]-}${maxChargingVoltage[@]-}" != *--exit* ]] || exitCmd=true

  for entry in "${applyOnBoot[@]-}" "${maxChargingVoltage[@]-}"; do
    [ "$entry" != --exit ] || continue
    set -- ${entry//::/ }
    file=${1-}
    value=${2-}
    { $exitCmd && ! $force; } && default=${2-} || default=${3:-${2-}}
    [ -f "$file" ] && chmod u+w $file && run_xtimes "echo \$$arg > $file" || :
  done

  $exitCmd && [ $arg = value ] && exit 0 || :
}


apply_on_plug() {
  local entry="" file="" value="" default="" arg=${1:-value}
  for entry in "${applyOnPlug[@]-}" "${maxChargingCurrent[@]-}" \
    "${maxChargingVoltage[@]-}"
  do
    set -- ${entry//::/ }
    file=${1-}
    value=${2-}
    default=${3:-${2-}}
    [ -f "$file" ] && chmod u+w $file && run_xtimes "echo \$$arg > $file" || :
  done
}


cycle_switches() {

  local on="" off=""

  while read -A chargingSwitch; do

    [ ! -f ${chargingSwitch[0]} ] || {

      # toggle primary switch
      on="${chargingSwitch[1]//::/ }"
      off="${chargingSwitch[2]//::/ }"
      chmod u+w ${chargingSwitch[0]} \
        && run_xtimes "echo \$$1 > ${chargingSwitch[0]}" \
        || continue

      # toggle secondary switch
      [ ! -f "${chargingSwitch[3]-}" ] || {
        on="${chargingSwitch[4]//::/ }"
        off="${chargingSwitch[5]//::/ }"
        chmod u+w ${chargingSwitch[3]} \
          && run_xtimes "echo \$$1 > ${chargingSwitch[3]}" || :
      }

      [ "$1" != off ] || {
        if sleep_sd not_charging ${2-}; then
          # enforce working charging switch(es)
          . $execDir/write-config.sh
        else
          # reset switch/group that fails to disable charging
          run_xtimes "echo ${chargingSwitch[1]//::/ } > ${chargingSwitch[0]} || :;
            echo ${chargingSwitch[4]//::/ } > ${chargingSwitch[3]:-/dev/null} || :" 2>/dev/null
          break
        fi
      }
    }
  done < $TMPDIR/ch-switches
}


cycle_switches_off() {
  ! $prioritizeBattIdleMode || cycle_switches off not
  not_charging || cycle_switches off
}


disable_charging() {

  local autoMode=true
  [[ "${chargingSwitch[*]-}" = *-- ]] || autoMode=false

  if $isAccd; then
    ! not_charging || return 0
  else
    apply_on_boot default
    apply_on_plug default
  fi

  if [[ "${chargingSwitch[0]-}" = */* ]]; then
    if [ -f ${chargingSwitch[0]} ]; then
      # toggle primary switch
      if chmod u+w ${chargingSwitch[0]} && run_xtimes "echo ${chargingSwitch[2]//::/ } > ${chargingSwitch[0]}"; then
        [ ! -f "${chargingSwitch[3]-}" ] || {
          # toggle secondary switch
          chmod u+w ${chargingSwitch[3]} && run_xtimes "echo ${chargingSwitch[5]//::/ } > ${chargingSwitch[3]}" || {
            $isAccd || print_switch_fails
            unset_switch
            cycle_switches_off
          }
        }
        if $autoMode && ! sleep_sd not_charging; then
          unset_switch
          cycle_switches_off
        fi
      else
        $isAccd || print_switch_fails
        unset_switch
        cycle_switches_off
      fi
    else
      $isAccd || print_invalid_switch
      unset_switch
      cycle_switches_off
    fi
  else
    cycle_switches_off
  fi

  not_charging || ! $autoMode || return 7 # total failure

  eval "${runCmdOnPause[@]-}"

  if [ -n "${1-}" ]; then
    case $1 in
      *%)
        print_charging_disabled_until $1
        echo
        (until [ $(cat $batt/capacity) -le ${1%\%} ]; do
          sleep ${loopDelay[1]}
          set +x
        done)
        enable_charging
      ;;
      *[hms])
        print_charging_disabled_for $1
        echo
        case $1 in
          *h) sleep $(( ${1%h} * 3600 ));;
          *m) sleep $(( ${1%m} * 60 ));;
          *s) sleep ${1%s};;
        esac
        enable_charging
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

  ! $isAccd || not_charging || return 0

  if ! $ghostCharging || { $ghostCharging && [[ $(cat */online) = *1* ]]; }; then

    $isAccd || apply_on_plug

    chmod u+w ${chargingSwitch[0]-} ${chargingSwitch[3]-} 2>/dev/null \
      && run_xtimes "echo ${chargingSwitch[1]//::/ } > ${chargingSwitch[0]-}
        echo ${chargingSwitch[4]//::/ } > ${chargingSwitch[3]:-/dev/null}" 2>/dev/null \
      || cycle_switches on

    # detect and block ghost charging
    if ! $ghostCharging && ! not_charging && [[ $(cat */online) != *1* ]] \
      && sleep ${loopDelay[0]} && ! not_charging && [[ $(cat */online) != *1* ]]
    then
      ghostCharging=true
      disable_charging > /dev/null
      touch $TMPDIR/.ghost-charging
      wait_plug
      return 0
    fi

    if [ -n "${1-}" ]; then
      case $1 in
        *%)
          print_charging_enabled_until $1
          echo
          (until [ $(cat $batt/capacity) -ge ${1%\%} ]; do
            sleep ${loopDelay[1]}
            set +x
          done)
          disable_charging
        ;;
        *[hms])
          print_charging_enabled_for $1
          echo
          case $1 in
            *h) sleep $(( ${1%h} * 3600 ));;
            *m) sleep $(( ${1%m} * 60 ));;
            *s) sleep ${1%s};;
          esac
          disable_charging
        ;;
        *)
          print_charging_enabled
        ;;
      esac
    else
      $isAccd || print_charging_enabled
    fi

  else
    wait_plug
  fi
}


misc_stuff() {
  set -eu
  mkdir -p ${config%/*} 2>/dev/null || :
  [ -f $config ] || cp $execDir/default-config.txt $config

  # custom config path
  case "${1-}" in
    */*)
      [ -f $1 ] || cp $config $1
      config=$1
    ;;
  esac
  unset -f misc_stuff
}


not_charging() { grep -Eiq "${1-dis|not}" $batt/status; }


print_header() {
  echo "Advanced Charging Controller $accVer ($accVerCode)
Copyright 2017-2020, VR25
GPLv3+"
}


print_wait_plug() {
  print_unplugged
  print_quit CTRL-C
}


run_xtimes() {
  eval "$@"
  return $?
  #wip
  local count=0
  for count in $(seq ${ctrlFileWrites[0]}); do
    eval "$@"
    sleep ${ctrlFileWrites[1]}
  done
}


sleep_sd() {
  local i=
  for i in $(seq $switchDelay); do
    eval "$@" && return 0 || sleep 1
  done
  return 1
}


unset_switch() {
  charging_switch=
  . $execDir/write-config.sh
}


wait_plug() {
  $isAccd || {
    echo "(i) ghostCharging=true"
    print_wait_plug
  }
  (while [[ $(cat */online) != *1* ]]; do
    sleep ${loopDelay[1]}
    ! $isAccd || sync_capacity
    set +x
  done)
  enable_charging "$@"
}


# environment

id=acc
umask 0077
switchDelay=7
loopDelay=(5 10)
execDir=/data/adb/acc
ctrlFileWrites=(3 0.3)
export TMPDIR=/dev/.acc
config=/sdcard/Download/$id/config.txt
config_=$config

[ -f $TMPDIR/.ghost-charging ] \
  && ghostCharging=true \
  || ghostCharging=false

trap exxit EXIT

. $execDir/setup-busybox.sh

device=$(getprop ro.product.device | grep .. || getprop ro.build.product)

cd /sys/class/power_supply/

for batt in $(ls */uevent); do
  chmod u+r $batt \
   && grep -q '^POWER_SUPPLY_CAPACITY=' $batt \
   && grep -q '^POWER_SUPPLY_STATUS=' $batt \
   && batt=${batt%/*} \
   && break
done 2>/dev/null || :

# dumpsys wrapper for Termux
[[ $(readlink -f $execDir) != *com.termux* ]] || {
  bin=$(su -c "which dumpsys")
  eval "dumpsys() { su -c $bin; }"
  unset bin
}

# dumpsys wrapper for recovery
pgrep -f zygote > /dev/null || dumpsys() { :; }

# set max switch_delay for mtk devices
! grep -q mtk_battery_cmd $TMPDIR/ch-switches || switchDelay=20
