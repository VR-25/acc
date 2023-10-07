apply_on_boot() {

  local entry=
  local file=
  local value=
  local default=
  local arg=${1:-value}
  local exitCmd=false
  local force=false
  local oppositeValue=

  [ ${2:-x} != force ] || force=true

  ! tt "${applyOnBoot[*]-}${maxChargingVoltage[*]-}" "*--exit*" || exitCmd=true

  for entry in ${applyOnBoot[@]-} ${maxChargingVoltage[@]-}; do
    set -- ${entry//::/ }
    [ -f ${1-//} ] || continue
    file=${1-}
    value=${2-}
    if $exitCmd && ! $force; then
      default=${2-}
    else
      default=${3:-${2-}}
    fi
    [ $arg = default ] && oppositeValue="$value" || oppositeValue="$default"
    write \$$arg $file 0 || :
  done

  $exitCmd && [ $arg = value ] && exit 0 || :
}


apply_on_plug() {

  local entry=
  local file=
  local value=
  local default=
  local arg=${1:-value}
  local oppositeValue=

  for entry in ${applyOnPlug[@]-} ${maxChargingVoltage[@]-} \
    ${maxChargingCurrent[@]:-$([ .$arg != .default ] || cat $TMPDIR/ch-curr-ctrl-files 2>/dev/null || :)}
  do
    set -- ${entry//::/ }
    [ -f ${1-//} ] || continue
    file=${1-}
    value=${2-}
    default=${3:-${2-}}
    [ $arg = default ] && oppositeValue="$value" || oppositeValue="$default"
    write \$$arg $file 0 || :
  done
}


at() {
  local one=$1
  local time=$(date +%H:%M)
  local file=$TMPDIR/schedules/$one
  shift
  if [ ! -f $file ] && [ ${one#0} = ${time#0} ]; then
    mkdir -p ${file%/*}
    echo "#!/system/bin/sh
      sleep 60
      rm $file
      exit" > $file
    chmod 0755 $file
    start-stop-daemon -bx $file -S --
    eval "$@"
  fi
}


calc() {
  awk "BEGIN {print $*}" | tr , .
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
        if not_charging ${2-}; then
          # set working charging switch(es)
          s="${chargingSwitch[*]}" # for some reason, without this, the array is null
          . $execDir/write-config.sh
          break
        else
          # reset switch/group that fails to comply, and move it to the end of the list
          flip_sw on 2>/dev/null || :
          if ! ${acc_t:-false}; then
            sed -i "\|^${chargingSwitch[*]}$|d" $TMPDIR/ch-switches
            echo "${chargingSwitch[*]}" >> $TMPDIR/ch-switches
          fi
        fi
      fi
    }
  done < $TMPDIR/ch-switches
}


cycle_switches_off() {
  case $prioritizeBattIdleMode in
    true) cycle_switches off Idle;;
    no)   cycle_switches off Discharging;;
  esac
  not_charging || cycle_switches off
}


disable_charging() {

  local autoMode=true

  not_charging || {

    ! tt "${chargingSwitch[*]-}" "*--" || autoMode=false

    if tt "${chargingSwitch[0]-}" "*/*"; then
      if [ -f ${chargingSwitch[0]} ]; then
        if ! { flip_sw off && not_charging; }; then
          $isAccd || print_switch_fails "${chargingSwitch[@]-}"
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

    (set +eux; eval '${runCmdOnPause-}') || :
    chDisabledByAcc=true
  }

  if [ -n "${1-}" ]; then
    case $1 in
      *%)
        print_charging_disabled_until $1
        echo
        (set +x
        until [ $(cat $battCapacity) -le ${1%\%} ]; do
          sleep ${loopDelay[1]}
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
      *m[vV])
        print_charging_disabled_until $1 v
        echo
        (set +x
        until [ $(volt_now) -le ${1%m*} ]; do
          sleep ${loopDelay[1]}
        done)
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

  ! not_charging || {

    set_temp_level
    [ ! -f $TMPDIR/.sw ] || (. $TMPDIR/.sw; rm $TMPDIR/.sw; flip_sw on) 2>/dev/null || :

    if ! $ghostCharging || { $ghostCharging && online; }; then

      flip_sw on || cycle_switches on

      # detect and block ghost charging
      if ! $ghostCharging && ! not_charging && ! online \
        && sleep ${loopDelay[0]} && ! not_charging && ! online
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

    chDisabledByAcc=false
  }

  if [ -n "${1-}" ]; then
    case $1 in
      *%)
        print_charging_enabled_until $1
        echo
        (set +x
        until [ $(cat $battCapacity) -ge ${1%\%} ]; do
          sleep ${loopDelay[0]}
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
      *m[vV])
        print_charging_enabled_until $1 v
        echo
        (set +x
        until [ $(volt_now) -ge ${1%m*} ]; do
          sleep ${loopDelay[0]}
        done)
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

  flip=$1
  local on=
  local off=
  local oppositeValue=

  set -- ${chargingSwitch[@]-}
  [ -f ${1:-//} ] || return 2
  swValue=

  while [ -f ${1:-//} ]; do

    on="$(parse_value "$2")"
    if [ $3 = 3600mV ]; then
      off=$(cat $1)
      [ $off -lt 10000 ] && off=3600 || off=3600000
    else
      off="$(parse_value "$3")"
    fi

    [ $flip = on ] && oppositeValue="$off" || { oppositeValue="$on"; cat $currFile > $curThen; }
    write \$$flip $1 || return 1

    [ $# -lt 3 ] || shift 3
    [ $# -ge 3 ] || break

  done
}


invalid_switch() {
  $isAccd || print_invalid_switch
  unset_switch
  cycle_switches_off
}


is_android() {
  [ ! -d /data/usbmsc_mnt/ ] && [ -x /system/bin/dumpsys ] \
    && ! tt "$(readlink -f $execDir)" "*com.termux*" \
    && pgrep -f zygote >/dev/null
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
  su -lp ${2:-2000} -c "/system/bin/cmd notification post -S bigtext -t '🔋ACC' 'Tag' \"${1:-:)}\"" < /dev/null > /dev/null 2>&1 || :
}


parse_value() {
  if [ -f "$1" ]; then
    chmod a+r $1 2>/dev/null || :
    cat $1
  else
    echo "$1" | sed 's/::/ /g'
  fi
}


print_header() {
  echo "Advanced Charging Controller (ACC) $accVer ($accVerCode)
(C) 2017-2023, VR25
GPLv3+"
}


print_wait_plug() {
  print_unplugged
}


src_cfg() {
  /system/bin/sh -n $config 2>/dev/null || cat $execDir/default-config.txt > $config
  . $config
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
    echo "ghostCharging=true"
    print_wait_plug
  }
  (while ! online; do
    sleep ${loopDelay[1]}
    ! $isAccd || sync_capacity 2>/dev/null || :
    set +x
  done)
  enable_charging "$@"
}


write() {
  local i=y
  local f=$dataDir/logs/write.log
  blacklisted=false
  if [ -f "$2" ] && chown 0:0 $2 && chmod 0644 $2; then
    case "$(grep -E "^(#$2|$2)$" $f 2>/dev/null || :)" in
      \#*) blacklisted=true;;
      */*) eval "echo $1 > $2" || i=x;;
      *) echo \#$2 >> $f
         eval "echo $1 > $2" || i=x
         sed -i "s|^#$2$|$2|" $f;;
    esac
  else
    i=x
  fi
  f="$(cat $2)" 2>/dev/null || :
  rm $TMPDIR/.nowrite 2>/dev/null || :
  if [ -n "$f" ]; then
    [ "$f" != "$oppositeValue" ] || { touch $TMPDIR/.nowrite; i=x; }
  fi
  if [ -n "${exitCode_-}" ]; then
    [ -n "${swValue-}" ] && swValue="$swValue, $f" || swValue="$f"
  fi
  [ $i = x ] && return ${3-1} || {
    for i in 1 2 3; do
      usleep 330000
      eval "echo $1 > $2" || :
    done
  }
}


# environment

id=acc
domain=vr25
: ${isAccd:=false}
loopDelay=(3 9)
execDir=/data/adb/$domain/acc
export TMPDIR=/dev/.vr25/acc
: ${config:=/data/adb/$domain/${id}-data/config.txt}
config_=$config
dataDir=/data/adb/$domain/${id}-data

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

# cmd battery and dumpsys wrappers
if is_android; then
  cmd_batt() { /system/bin/cmd battery "$@" < /dev/null > /dev/null 2>&1 || :; }
  dumpsys() { /system/bin/dumpsys "$@" || :; }
else
  cmd_batt() { :; }
  dumpsys() { :; }
  ! ${isAccd:-false} || {
    chgStatusCode=0
    dischgStatusCode=0
  }
fi

# load plugins
mkdir -p ${execDir}-data/plugins $TMPDIR/plugins
for f in ${execDir}-data/plugins/*.sh $TMPDIR/plugins/*.sh; do
  if [ -f "$f" ] && [ ${f##*/} != ctrl-files.sh ]; then
    . "$f"
  fi
done
unset f
