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
    [ -f "$file" ] && chmod 0644 $file && run_xtimes "echo \$$arg > $file" || :
  done

  $exitCmd && [ $arg = value ] && exit 0 || :
}


apply_on_plug() {
  local entry="" file="" value="" default="" arg=${1:-value}
  for entry in "${applyOnPlug[@]-}" \
    "${maxChargingCurrent[@]:-$([ .$arg != .default ] || cat $TMPDIR/ch-curr-ctrl-files 2>/dev/null)}" \
    "${maxChargingVoltage[@]-}"
  do
    set -- ${entry//::/ }
    file=${1-}
    value=${2-}
    default=${3:-${2-}}
    [ -f "$file" ] && chmod 0644 $file && run_xtimes "echo \$$arg > $file" || :
  done
}


cmd_batt() {
  /system/bin/cmd battery "$@" < /dev/null > /dev/null 2>&1 || :
}


cycle_switches() {

  local on="" off=""

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

  if ! switch_mA "${chargingSwitch[0]:-/}"
  then

    local autoMode=true
    [[ "${chargingSwitch[*]-}" = *-- ]] || autoMode=false

    ! $isAccd || ! not_charging || return 0

    if [[ "${chargingSwitch[0]-}" = */* ]]; then
      if [ -f ${chargingSwitch[0]} ]; then
        # toggle primary switch
        if chmod 0644 ${chargingSwitch[0]} && run_xtimes "echo ${chargingSwitch[2]//::/ } > ${chargingSwitch[0]}"; then
          [ ! -f "${chargingSwitch[3]-}" ] || {
            # toggle secondary switch
            chmod 0644 ${chargingSwitch[3]} && run_xtimes "echo ${chargingSwitch[5]//::/ } > ${chargingSwitch[3]}" || {
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

  else
    maxChargingCurrent0=${maxChargingCurrent[0]-}
    set +e
    set_ch_curr ${chargingSwitch[0]:-0}
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


dumpsys() { /system/bin/dumpsys "$@" || :; }


enable_charging() {

  if ! switch_mA "${chargingSwitch[0]:-/}"
  then

    ! $isAccd || not_charging || return 0

    if ! $ghostCharging || { $ghostCharging && [[ $(cat */online) = *1* ]]; }; then

      chmod 0644 ${chargingSwitch[0]-} ${chargingSwitch[3]-} 2>/dev/null \
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

    else
      wait_plug
      return 0
    fi

  else
    set +e
    set_ch_curr ${maxChargingCurrent0:--}
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


not_charging() {
  grep -Eiq "${1-dis|not}" $batt/status
}


print_header() {
  echo "Advanced Charging Controller $accVer ($accVerCode)
Copyright 2017-present, VR25
GPLv3+"
}


print_wait_plug() {
  print_unplugged
  print_quit CTRL-C
}


run_xtimes() {
  local count=0
  for count in $(seq ${ctrlFileWrites[0]}); do
    eval "$@"
    sleep ${ctrlFileWrites[1]}
  done
}


sleep_sd() {
  local i
  for i in 1 2 3 4; do
    eval "$@" && return 0 || sleep $switchDelay
  done
  return 1
}


switch_mA() {
  case "$1" in
    */*) return 1;;
    *) return 0;;
  esac
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
domain=vr25
umask 0077
switchDelay=2
loopDelay=(10 10)
execDir=/data/adb/$domain/acc
ctrlFileWrites=(3 0.3)
export TMPDIR=/dev/.vr25/acc
config=/sdcard/Documents/$domain/$id/config.txt
config_=$config

[ -f $TMPDIR/.ghost-charging ] \
  && ghostCharging=true \
  || ghostCharging=false

trap exxit EXIT

. $execDir/setup-busybox.sh
. $execDir/set-ch-curr.sh

device=$(getprop ro.product.device | grep .. || getprop ro.build.product)

cd /sys/class/power_supply/

# find battery uevent
for batt in */uevent; do
  chmod 0644 $batt \
   && grep -q '^POWER_SUPPLY_CAPACITY=' $batt \
   && grep -q '^POWER_SUPPLY_STATUS=' $batt \
   && batt=${batt%/*} \
   && break
done 2>/dev/null || :

# set temperature reporter
temp=$batt/temp
[ -f $temp ] || {
  temp=$batt/batt_temp
  [ -f $temp ] || {
    temp=bms/temp
    [ -f $temp ] || {
      echo 250 > $TMPDIR/.dummy-temp
      temp=$TMPDIR/.dummy-temp
    }
  }
}

# cmd and dumpsys wrappers for Termux and recovery
[[ $(readlink -f $execDir) != *com.termux* ]] || {
  cmd_batt() { su -c /system/bin/cmd battery "$@" < /dev/null > /dev/null 2>&1 || :; }
  dumpsys() { su -c /system/bin/dumpsys "$@" || :; }
}
pgrep -f zygote > /dev/null || {
  cmd_batt() { :; }
  dumpsys() { :; }
}

# set switchDelay for mtk devices
! grep -q mtk_battery_cmd $TMPDIR/ch-switches || switchDelay=5
