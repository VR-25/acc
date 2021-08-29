apply_on_boot() {

  local entry
  local file
  local value
  local default
  local arg=${1:-value}
  local exitCmd=false
  local force=false

  [ ${2:-x} != force ] || force=true

  ! tt "${applyOnBoot[@]-}${maxChargingVoltage[@]-}" "*--exit*" || exitCmd=true

  for entry in "${applyOnBoot[@]-}" "${maxChargingVoltage[@]-}"; do
    [ "$entry" != --exit ] || continue
    set -- ${entry//::/ }
    file=${1-}
    value=${2-}
    { $exitCmd && ! $force; } && default=${2-} || default=${3:-${2-}}
    if [ -f "$file" ] && chmod 0644 $file; then
      run_xtimes "echo \$$arg > $file" &
    fi || :
  done

  $exitCmd && [ $arg = value ] && exit 0 || :
}


apply_on_plug() {
  local entry
  local file
  local value
  local default
  local arg=${1:-value}
  for entry in "${applyOnPlug[@]-}" \
    "${maxChargingCurrent[@]:-$([ .$arg != .default ] || cat $TMPDIR/ch-curr-ctrl-files 2>/dev/null)}" \
    "${maxChargingVoltage[@]-}"
  do
    set -- ${entry//::/ }
    file=${1-}
    value=${2-}
    default=${3:-${2-}}
    if [ -f "$file" ] && chmod 0644 $file; then
      run_xtimes "echo \$$arg > $file" &
    fi || :
  done
}


cmd_batt() {
  /system/bin/cmd battery "$@" < /dev/null > /dev/null 2>&1 || :
}


cycle_switches() {

  local on
  local off

  while read -A chargingSwitch; do

    [ ! -f ${chargingSwitch[0]} ] || {

      # toggle primary switch
      on="${chargingSwitch[1]//::/ }"
      off="${chargingSwitch[2]//::/ }"
      chmod 0644 ${chargingSwitch[0]} \
        && run_xtimes "echo \$$1 > ${chargingSwitch[0]}" \
        || continue

      # toggle secondary switch
      [ ! -f "${chargingSwitch[3]-}" ] || {
        on="${chargingSwitch[4]//::/ }"
        off="${chargingSwitch[5]//::/ }"
        chmod 0644 ${chargingSwitch[3]} \
          && run_xtimes "echo \$$1 > ${chargingSwitch[3]}" || :
      }

      if [ "$1" = on ]; then
        not_charging || break
      else
        if sleep_sd not_charging ${2-}; then
          # set working charging switch(es)
          s="${chargingSwitch[*]}" # for some reason, without this, the array is null
          . $execDir/write-config.sh
          break
        else
          # reset switch/group that fails to disable charging
          run_xtimes "echo ${chargingSwitch[1]//::/ } > ${chargingSwitch[0]} || :;
            echo ${chargingSwitch[4]//::/ } > ${chargingSwitch[3]:-/dev/null} || :" 2>/dev/null
        fi
      fi
    }
  done < $TMPDIR/ch-switches
}


cycle_switches_off() {
  ! $prioritizeBattIdleMode || cycle_switches off not
  not_charging || cycle_switches off
}


disable_charging() {

  if ! switch_mA "${chargingSwitch[0]:-/}"; then

    local autoMode=true
    ! tt "${chargingSwitch[*]-}" "*--" || autoMode=false

    ! $isAccd || ! not_charging || return 0

    if tt "${chargingSwitch[0]-}" "*/*"; then
      if [ -f ${chargingSwitch[0]} ]; then
        # toggle primary switch
        if chmod 0644 ${chargingSwitch[0]} \
          && run_xtimes "echo ${chargingSwitch[2]//::/ } > ${chargingSwitch[0]}"
        then
          if tt "${chargingSwitch[3]-}" "*/*"; then
            if t -f "${chargingSwitch[3]-}"; then
              # toggle secondary switch
              chmod 0644 ${chargingSwitch[3]} \
                && run_xtimes "echo ${chargingSwitch[5]//::/ } > ${chargingSwitch[3]}" \
                || switch_fails
            else
              invalid_switch
            fi
          fi
        else
          switch_fails
        fi
        sleep_sd not_charging || switch_fails
      else
        invalid_switch
      fi
    else
      cycle_switches_off
    fi

    if $autoMode && ! not_charging; then
      return 7 # total failure
    fi

  else
    set +e
    if [ ${chargingSwitch[0]:-0} -lt 3700 ]; then
      maxChargingCurrent0=${maxChargingCurrent[0]-}
      set_ch_curr ${chargingSwitch[0]:-0}
    else
      maxChargingVoltage0=${maxChargingVoltage[0]-}
      set_ch_volt ${chargingSwitch[0]:-0}
    fi
    set -e
    chargingDisabled=true
  fi

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
          *h) sleep $(( ${1%h} * 3700 ));;
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


dumpsys() { /system/bin/dumpsys "$@" || :; }


enable_charging() {

  if ! switch_mA "${chargingSwitch[0]:-/}"; then

    ! $isAccd || not_charging || return 0

    if ! $ghostCharging || { $ghostCharging && tt "$(cat */online)" "*1*"; }; then

      chmod 0644 ${chargingSwitch[0]-} ${chargingSwitch[3]-} 2>/dev/null \
        && run_xtimes "echo ${chargingSwitch[1]//::/ } > ${chargingSwitch[0]-}
          echo ${chargingSwitch[4]//::/ } > ${chargingSwitch[3]:-/dev/null}" 2>/dev/null \
        || cycle_switches on

      # detect and block ghost charging
      if ! $ghostCharging && ! not_charging && ! tt "$(cat */online)" "*1*" \
        && sleep ${loopDelay[0]} && ! not_charging && ! tt "$(cat */online)" "*1*"
      then
        ghostCharging=true
        disable_charging > /dev/null
        touch $TMPDIR/.ghost-charging
        wait_plug
        return 0
      fi

    else
      wait_plug
      return 0
    fi

  else
    set +e
    if [ ${chargingSwitch[0]:-0} -lt 3700 ]; then
      set_ch_curr ${maxChargingCurrent0:--}
    else
      set_ch_volt ${maxChargingVoltage0:--}
    fi
    set -e
    chargingDisabled=false
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
          *h) sleep $(( ${1%h} * 3700 ));;
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
}


invalid_switch() {
  $isAccd || print_invalid_switch
  unset_switch
  cycle_switches_off
}


misc_stuff() {
  set -eu
  mkdir -p ${config%/*} 2>/dev/null || :
  [ -f $config ] || cat $execDir/default-config.txt > $config

  # custom config path
  case "${1-}" in
    */*)
      [ -f $1 ] || cp $config $1
      config=$1
    ;;
  esac
  unset -f misc_stuff
}


print_header() {
  echo "Advanced Charging Controller $accVer ($accVerCode)
Copyright 2017-2021, VR25
GPLv3+"
}


print_wait_plug() {
  print_unplugged
  print_quit CTRL-C
}


run_xtimes() {
  local count=0
  for count in $(seq ${ctrlFileWrites[0]}); do
    eval "$@" || break
    sleep ${ctrlFileWrites[1]}
  done
}


sync_capacity() {
  isCharging=${isCharging:-false}
  local isCharging_=$isCharging
  ! $capacitySync || {
    ! $cooldown || isCharging=true
    if $isCharging; then
      cmd_batt set ac 1
      cmd_batt set status $chgStatusCode
    else
      cmd_batt unplug
      cmd_batt set status $dischgStatusCode
    fi
    isCharging=$isCharging_
    if ! ${capacity[4]} \
      || { ${capacity[4]} && [ $(cat $batt/capacity) -ge 2 ]; }
    then
      cmd_batt set level $(cat $batt/capacity)
    fi
  }
}


sleep_sd() {
  local i
  for i in 1 2 3 4; do
    eval "$@" && return 0 || sleep $switchDelay
  done
  return 1
}


switch_fails() {
  $isAccd || print_switch_fails "${chargingSwitch[@]}"
  if $autoMode; then
    unset_switch
    cycle_switches_off
  fi
}


switch_mA() {
  case "$1" in
    */*) return 1;;
    *) return 0;;
  esac
}


# test
t() { test "$@"; }


# extended test
tt() {
  eval "case \"$1\" in
    $2) return 0;;
  esac"
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
  (while ! tt "$(cat */online)" "*1*"; do
    sleep ${loopDelay[1]}
    ! $isAccd || sync_capacity
    set +x
  done)
  enable_charging "$@"
}


# environment

id=acc
domain=vr25
switchDelay=2
loopDelay=(10 10)
execDir=/data/adb/$domain/acc
ctrlFileWrites=(3 0.3)
export TMPDIR=/dev/.vr25/acc
config=/data/adb/$domain/${id}-data/config.txt
config_=$config

[ -f $TMPDIR/.ghost-charging ] \
  && ghostCharging=true \
  || ghostCharging=false

trap exxit EXIT

. $execDir/setup-busybox.sh
. $execDir/set-ch-curr.sh
. $execDir/set-ch-volt.sh

device=$(getprop ro.product.device | grep .. || getprop ro.build.product)

cd /sys/class/power_supply/

. $execDir/batt-interface.sh

# cmd and dumpsys wrappers for Termux and recovery
! tt "$(readlink -f $execDir)" "*com.termux*" || {
  cmd_batt() { su -c /system/bin/cmd battery "$@" < /dev/null > /dev/null 2>&1 || :; }
  dumpsys() { su -c /system/bin/dumpsys "$@" || :; }
}
pgrep -f zygote > /dev/null || {
  cmd_batt() { :; }
  dumpsys() { :; }
}

# set switchDelay for mtk devices
! grep -q mtk_battery_cmd $TMPDIR/ch-switches || switchDelay=5

# load plugins
for f in /data/adb/vr25/acc-data/pluggins/*.sh; do
  [ ! -f "$f" ] || . "$f"
done
unset f
