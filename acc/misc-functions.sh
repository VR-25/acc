apply_on_boot() {

  local entry=
  local file=
  local value=
  local default=
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
    write \$$arg $file 0 &
  done

  wait
  $exitCmd && [ $arg = value ] && exit 0 || :
}


apply_on_plug() {

  local entry=
  local file=
  local value=
  local default=
  local arg=${1:-value}

  for entry in "${applyOnPlug[@]-}" \
    "${maxChargingCurrent[@]:-$([ .$arg != .default ] || cat $TMPDIR/ch-curr-ctrl-files 2>/dev/null)}" \
    "${maxChargingVoltage[@]-}"
  do
    set -- ${entry//::/ }
    file=${1-}
    value=${2-}
    default=${3:-${2-}}
    write \$$arg $file 0 &
  done

  wait
}


calc() {
  awk "BEGIN {print $*}"
}


cmd_batt() {
  /system/bin/cmd battery "$@" < /dev/null > /dev/null 2>&1 || :
}


cycle_switches() {

  local on=
  local off=

  while read -A chargingSwitch; do

    [ ! -f ${chargingSwitch[0]:-//} ] || {

      flip_sw $1 || :

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
          flip_sw on 2>/dev/null || :
        fi
      fi
    }
  done < $TMPDIR/ch-switches
}


cycle_switches_off() {
  ! $prioritizeBattIdleMode || cycle_switches off Idle
  not_charging || cycle_switches off
}


disable_charging() {

  local autoMode=true

  if ! switch_mA "${chargingSwitch[0]:-/}"; then

    ! tt "${chargingSwitch[*]-}" "*--" || autoMode=false
    ! $isAccd || ! not_charging || return 0

    if tt "${chargingSwitch[0]-}" "*/*"; then
      if [ -f ${chargingSwitch[0]} ]; then
        if ! { flip_sw off && sleep_sd not_charging; }; then
          $isAccd || print_switch_fails "${chargingSwitch[@]}"
          flip_sw on 2>/dev/null || :
          if $autoMode; then
            unset_switch
            cycle_switches_off
          fi
        fi
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

  (set +eux
  eval "${runCmdOnPause[@]-}"
  eval "${runCmdOnPause_-}") || :

  if [ -n "${1-}" ]; then
    case $1 in
      *%)
        print_charging_disabled_until $1
        echo
        (until [ $(cat $battCapacity) -le ${1%\%} ]; do
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

      flip_sw on || cycle_switches on

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
        (until [ $(cat $battCapacity) -ge ${1%\%} ]; do
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


flip_sw() {

  local on=
  local off=
  local off_=
  local flip=$1

  set -- ${chargingSwitch[@]-}
  [ -f ${1:-//} ] || return 1

  while [ -f ${1:-//} ]; do
    on="$(parse_value "$2")"
    if [ $flip = off ]; then
      #! tt "${chargingSwitch[*]:-.}" "battery/input_suspend?0?1?/proc/mtk_battery_cmd/en_power_path?1?1*" ] || sleep 6 # mtk idle mode workaround
      if [ ${chargingSwitch[2]:-.} = voltage_now ]; then
        off_="$off"
        ! off=$(cat $batt/voltage_now 2>/dev/null) \
          && off="$off_" \
          || { [ $off -lt 10000 ] && off=$((off - 50)) || off=$((off - 50000)); }
      else
        off="$(parse_value "$3")"
      fi
      cat $currFile > $TMPDIR/.curr
      sleep 1
    else
      echo null > $TMPDIR/.curr
    fi
    write \$$flip $1 || return 1
    shift 3 2>/dev/null || return 0
  done
}


invalid_switch() {
  $isAccd || print_invalid_switch
  unset_switch
  cycle_switches_off
}


misc_stuff() {
  set -eu
  mkdir -p $dataDir 2>/dev/null || :
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


notif() {
  su -lp 2000 -c "/system/bin/cmd notification post -S bigtext -t 'ACC' 'Tag' \"$*\"" < /dev/null > /dev/null 2>&1
}


parse_value() {
  local i=
  case $1 in
    */*) i="$(sed 's/ /::/g' $1 2>/dev/null || :)"; [ -z "$i" ] || echo $i;;
    *) echo $1;;
  esac
}


print_header() {
  echo "Advanced Charging Controller $accVer ($accVerCode)
Copyright 2017-2022, VR25
GPLv3+"
}


print_wait_plug() {
  print_unplugged
  print_quit CTRL-C
}


sleep_sd() {
  local i=
  for i in $(seq $switchSeq); do
    (set +eu; eval "$@") && return 0 || sleep 2
  done
  return 1
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


write() {
  local i=
  local l=$dataDir/logs/write.log
  local s=
  [ -f "$2" ] && chmod 0644 "$2" || return ${3-1}
  s="$(grep -E "^(#$2|$2)$" $l 2>/dev/null || :)"
  case "$s" in
    \#*) blacklisted=true; return ${3-1};;
    "") echo "#$2" >> $l; s=x;;
  esac
  for i in 1 2; do
    eval echo "$1" > "$2" || return ${3-1}
    sleep 0.5
  done
  blacklisted=false
  [ $s != x ] || sed -i "\|^#$2$|s|^#||" $l
}


# environment

id=acc
domain=vr25
switchSeq=4
isAccd=false
loopDelay=(5 10)
execDir=/data/adb/$domain/acc
export TMPDIR=/dev/.vr25/acc
config=/data/adb/$domain/${id}-data/config.txt
config_=$config
dataDir=${config%/*}

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

! grep -q mtk_battery_cmd $TMPDIR/ch-switches || switchSeq=11

# load plugins
mkdir -p ${execDir}-data/plugins $TMPDIR/plugins
for f in ${execDir}-data/plugins/*.sh $TMPDIR/plugins/*.sh; do
  if [ -f "$f" ] && [ ${f##*/} != ctrl-files.sh ]; then
    . "$f"
  fi
done
unset f
