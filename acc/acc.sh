#!/system/bin/sh
# Advanced Charging Controller
# Copyright (c) 2017-2020, VR25 (xda-developers)
# License: GPLv3+


daemon_ctrl() {

  local isRunning=true
  set +eo pipefail 2>/dev/null
  local pid="$(pgrep -f '/ac(c|ca) (-|--)[def]|/accd\.sh' | sed s/$$//)"
  set -eo pipefail 2>/dev/null || :
  [[ ${pid:-x} == *[0-9]* ]] || isRunning=false

  case ${1:-} in

    start)
      if $isRunning; then
        print_already_running
        return 8
      else
        print_started
        /sbin/accd $config
        return 0
      fi
    ;;

    stop)
      if $isRunning; then
        set +eo pipefail 2>/dev/null
        echo "$pid" | xargs kill -9 2>/dev/null
        { dumpsys battery reset
        not_charging && enable_charging
        if [ ${2:-x} != skipab ]; then
          . $modPath/apply-on-boot.sh
          case ${2-} in
            forceab) apply_on_boot default force;;
            *) apply_on_boot default;;
          esac
        fi
        . $modPath/apply-on-plug.sh
        apply_on_plug default; } > /dev/null 2>&1
        print_stopped
        return 0
      else
        print_not_running
        return 8
      fi
    ;;

    restart)
      if $isRunning; then
        print_restarted
      else
        print_started
      fi
      /sbin/accd $config
    ;;

    *)
      if $isRunning; then
        print_is_running "$accVer ($accVerCode)" "(PID $pid)"
        return 0
      else
        print_not_running
        return 1
      fi
    ;;
  esac
}


edit() {
  [ "$1" != no-quit-msg ] || { local noQuitMsg=true; shift; }
  local file="$1"
  shift
  if [ -n "${1-}" ]; then
    eval "$@ $file"
  else
    if ! ${noQuitMsg:-false}; then
      print_quit ":q [enter]"
      sleep 1.5
      echo
    fi
    { vim $file || vi $file; } 2>/dev/null
  fi
}


disable_charging() {

  . $modPath/apply-on-boot.sh; apply_on_boot default
  . $modPath/apply-on-plug.sh; apply_on_plug default
  . $modPath/set-prop.sh

  if [[ ${chargingSwitch[0]:-x} == */* ]]; then
    if [ -f ${chargingSwitch[0]} ]; then
      if chmod +w ${chargingSwitch[0]} && echo "${chargingSwitch[2]//::/ }" > ${chargingSwitch[0]}; then
        # secondary switch
        if [ -f "${chargingSwitch[3]-}" ]; then
          chmod +w ${chargingSwitch[3]} && echo "${chargingSwitch[5]//::/ }" > ${chargingSwitch[3]} \
            || { print_switch_fails; set_prop charging_switch=; exit 1; }
        fi
        sleep $switchDelay
      else
        print_switch_fails
        set_prop charging_switch=
        exit 1
      fi
    else
      print_invalid_switch
      set_prop charging_switch=
      exit 1
    fi
  else
    . $modPath/cycle-switches.sh
    ! $prioritizeBattIdleMode || cycle_switches off not
    not_charging || cycle_switches off
  fi

  if [ -n "${1:-}" ]; then
    if [[ $1 == *% ]]; then
      print_charging_disabled_until $1
      echo
      (until [ $(( $(cat $batt/capacity) ${capacity[4]} )) -le ${1%\%} ]; do
        sleep ${loopDelay[1]}
        set +x
      done)
      enable_charging
    elif [[ $1 == *[smh] ]]; then
      print_charging_disabled_for $1
      echo
      if [[ $1 == *s ]]; then
        sleep ${1%s}
      elif [[ $1 == *m ]]; then
        sleep $(( ${1%m} * 60 ))
      else
        sleep $(( ${1%h} * 3600 ))
      fi
      enable_charging
    else
      print_charging_disabled
    fi
  else
    print_charging_disabled
  fi
}


enable_charging() {

  if ! $ghostCharging || { $ghostCharging && [[ "$(acpi -a)" == *on-line* ]]; }; then

    . $modPath/apply-on-plug.sh; apply_on_plug
    . $modPath/set-prop.sh

    if [[ ${chargingSwitch[0]:-x} == */* ]]; then
      if [ -f ${chargingSwitch[0]} ]; then
        if chmod +w ${chargingSwitch[0]} && echo "${chargingSwitch[1]//::/ }" > ${chargingSwitch[0]}; then
          # secondary switch
          if [ -f "${chargingSwitch[3]-}" ]; then
            chmod +w ${chargingSwitch[3]} && echo "${chargingSwitch[4]//::/ }" > ${chargingSwitch[3]} \
              || { print_switch_fails; set_prop charging_switch=; exit 1; }
          fi
          sleep $switchDelay
        else
          print_switch_fails
          set_prop charging_switch=
          exit 1
        fi
      else
        print_invalid_switch
        set_prop charging_switch=
        exit 1
      fi
    else
      . $modPath/cycle-switches.sh
      cycle_switches on
    fi

    # detect and block ghost charging
    if ! $ghostCharging && ! not_charging && [[ "$(acpi -a)" != *on-line* ]]; then
      disable_charging > /dev/null
      ghostCharging=true
      echo "(i) ghostCharging=true"
      print_unplugged
      exit 2
    fi

    if [ -n "${1:-}" ]; then
      if [[ $1 == *% ]]; then
       print_charging_enabled_until $1
        echo
        (until [ $(( $(cat $batt/capacity) ${capacity[4]} )) -ge ${1%\%} ]; do
          sleep ${loopDelay[0]}
          set +x
        done)
        [ "${2:-x}" == --no-disable ] || disable_charging
      elif [[ $1 == *[smh] ]]; then
        print_charging_enabled_for $1
        echo
        if [[ $1 == *s ]]; then
          sleep ${1%s}
        elif [[ $1 == *m ]]; then
          sleep $(( ${1%m} * 60 ))
        else
          sleep $(( ${1%h} * 3600 ))
        fi
        disable_charging
      else
        print_charging_enabled
      fi
    else
      print_charging_enabled
    fi

  else
    echo "(i) ghost_charging=true"
    print_unplugged
    exit 2
  fi
}


get_prop() { sed -n "s|^$1=||p" ${2:-$config}; }


test_charging_switch() {

  local failed=false

  if [ -n "${1-}" ]; then

    chmod +w $1 ${4-} && echo "${3//::/ }" > $1 && echo "${6//::/ }" > ${4:-/dev/null} && sleep $switchDelay
    ! not_charging && failed=true || { grep -iq not $batt/status && battIdleMode=true || battIdleMode=false; }

    if ! $failed && echo "${2//::/ }" > $1 && echo "${5//::/ }" > ${4:-/dev/null} \
      && sleep $switchDelay && ! not_charging
    then
      print_switch_works "$@"
      echo "- battIdleMode=$battIdleMode"
      return 0
    else
      print_switch_fails "$@"
      { echo "${2//::/ }" > $1
      echo "${5//::/ }" > ${4:-/dev/null}; } 2>/dev/null
      return 1
    fi

  else

    { disable_charging
    ! not_charging && failed=true || enable_charging; } > /dev/null

    if ! $failed && ! not_charging; then
      print_supported
      return 0
    else
      print_unsupported
      (enable_charging > /dev/null 2>&1 &) &
      return 1
    fi

  fi
}


not_charging() { grep -Eiq 'dis|not' $batt/status; }


exxit() {
  local exitCode=$?
  ${noEcho-false} || echo
  [[ $exitCode != [127] ]] || logf --export > /dev/null 2>&1
  exit $exitCode
}


logf() {
  if [[ "${1:-x}" == -*e* ]]; then
    set +eo pipefail 2>/dev/null
    cd $TMPDIR
    cp oem-custom oem-custom.txt 2>/dev/null
    cp charging-switches charging-switches.txt
    cp ch-curr-ctrl-files charging-current-ctrl-files.txt
    cp ch-volt-ctrl-files charging-voltage-ctrl-files.txt
    for file in /cache/magisk.log /data/cache/magisk.log; do
      [ -f $file ] && cp $file ./ && break
    done
    cp $config ${config%/*}/logs/* ./
    dumpsys battery > dumpsys-battery.txt
    acpi -V > acpi-V.txt
    tar -c *.log *.txt 2>/dev/null \
      | gzip -9 > /data/media/0/acc-logs-$device.tar.gz
    chmod 777 /data/media/0/acc-logs-$device.tar.gz
    rm *.txt magisk.log in*.log power*.log 2>/dev/null
    echo "(i) /sdcard/acc-logs-$device.tar.gz"
  else
    if [[ "${1:-x}" == -*a* ]]; then
      shift
      edit $log "$@"
    else
      edit $TMPDIR/accd-*.log "$@"
    fi
  fi
}


umask 077
ghostCharging=false
modPath=/sbin/.acc/acc
export TMPDIR=${modPath%/*}
config=/data/adb/acc-data/config.txt
defaultConfig=$modPath/default-config.txt


echo
. $modPath/setup-busybox.sh

device=$(getprop ro.product.device | grep .. || getprop ro.build.product)
log=$TMPDIR/acc-${device}.log

# verbose
if [[ ${verbose:-true} && "${1-}" != *-w* ]]; then
    touch $log
    trap exxit EXIT
    if [ $(du -m $log | cut -f 1) -lt 2 ]; then
      echo "###$(date)###" >> $log
      set -x 2>>$log
    else
      set -x 2>$log
    fi
fi

set -euo pipefail 2>/dev/null || :
cd /sys/class/power_supply/
mkdir -p ${config%/*}
[ -f $config ] || cp $defaultConfig $config
. $config

# config backup
if [ -d /data/media/0/?ndroid ]; then
  [ /data/media/0/.acc-config-backup.txt -nt $config ] \
    || install -m 777 $config /data/media/0/.acc-config-backup.txt 2>/dev/null || :
fi

# load config from a custom path
if [[ "${1:-x}" == */* ]]; then
  [ -f $1 ] || cp $config $1
  config=$1
  . $config
  shift
fi

accVer=$(get_prop version $modPath/module.prop)
accVerCode=$(get_prop versionCode $modPath/module.prop)

batt=$(echo *attery/capacity | cut -d ' ' -f 1 | sed 's|/capacity||')

# load default language (English)
. $modPath/strings.sh

# load translations
! [[ ${verbose:-true} && -f $modPath/translations/$language/strings.sh ]] || . $modPath/translations/$language/strings.sh
grep -q .. $modPath/translations/$language/README.md 2>/dev/null \
    && readMe=$modPath/translations/$language/README.md \
    || readMe=${config%/*}/info/README.md

# aliases/shortcuts
# daemon_ctrl status (acc -D|--daemon): "accd,"
# daemon_ctrl stop (acc -D|--daemon stop): "accd."
if [[ $0 == *accd* ]]; then
  if [[ $0 == *accd. ]]; then
    daemon_ctrl stop
  else
    daemon_ctrl
  fi
  exit $?
fi


case ${1-} in

  "")
    PS3="$(echo; print_choice_prompt)"
    . $modPath/wizard.sh
    wizard
  ;;

  [0-9]*)
    capacity[2]=$2
    capacity[3]=$1
    . $modPath/write-config.sh
  ;;

  -c|--config)
    shift; edit $config "$@"
  ;;

  -d|--disable)
    shift
    ! daemon_ctrl || daemon_ctrl stop
    disable_charging "$@"
  ;;

  -D|--daemon)
    shift; daemon_ctrl "$@"
  ;;

  -e|--enable)
    shift
    ! daemon_ctrl || daemon_ctrl stop
    enable_charging "$@"
  ;;

  -f|--force|--full)
    daemon_ctrl stop > /dev/null && daemonWasUp=true || daemonWasUp=false
    print_charging_enabled_until ${2:-100}%
    (enable_charging ${2:-100}% --no-disable > /dev/null 2>&1
    ! $daemonWasUp || /sbin/.acc/acc/accd.sh $config &) &
  ;;

  -F|--flash)
    shift
    set +euxo pipefail 2>/dev/null
    trap - EXIT
    $modPath/install-zip.sh "$@"
  ;;


  -i|--info)
    . $modPath/batt-info.sh
    batt_info "${2-}"
  ;;


  -la)
    shift
    logf --acc "$@"
  ;;

  -le)
    logf --export
  ;;

  -l|--log)
    shift
    logf "$@"
  ;;

  -T|--logtail)
    print_quit CTRL-C
    sleep 1.5
    tail -F $TMPDIR/accd-*.log
  ;;

  -p|--performance)
    print_quit q
    sleep 1.5
    htop -p $(pgrep -f '/accd\.sh')
  ;;

  -r|--readme)
    shift; edit $readMe "$@"
  ;;

  -R|--resetbs)
    dumpsys batterystats --reset || :
    rm /data/system/batterystats* 2>/dev/null || :
  ;;

  -s|--set)
    shift; . $modPath/set-prop.sh; set_prop "$@"
  ;;


  -t|--test)

    shift
    daemon_ctrl stop > /dev/null && daemonWasUp=true || daemonWasUp=false
    set +eo pipefail 2>/dev/null
    not_charging && enable_charging > /dev/null
    if not_charging; then
      print_unplugged
      $daemonWasUp && /sbin/accd $config
      exit 2
    fi

    if [ -z "${1-}" ]; then
      test_charging_switch
    elif [ $1 == -- ]; then
      exitCode=1
      while read chargingSwitch; do
        [ -f "$(echo "$chargingSwitch" | cut -d ' ' -f 1)" ] \
          && echo && test_charging_switch $chargingSwitch
        tmpExitCode=$?
        [ $tmpExitCode -eq 0 ] && exitCode=0
      done < ${2:-$TMPDIR/charging-switches}
      echo
    else
      test_charging_switch "$@"
    fi

    : ${exitCode=$?}
    $daemonWasUp && /sbin/accd $config

    if [ $exitCode -ne 0 ]; then
      logf --export
      exit 1
    else
      exit 0
    fi
  ;;


  -u|--upgrade)
    shift
    local reference=$(echo "$@" | sed -E 's/-c|--changelog|-f|--force|-n|--non-interactive| //g')
    if ! echo "${reference:-x}" | grep -Eq 'dev|master'; then
      grep -q '^version=.*-dev' $modPath/module.prop && reference=dev || reference=master
    fi
    curl -Lo $TMPDIR/install-latest.sh https://raw.githubusercontent.com/VR-25/acc/$reference/install-latest.sh
    trap - EXIT
    set +euo pipefail 2>/dev/null
    installDir=$(readlink -f $modPath)
    installDir=${installDir%/*}
    . $TMPDIR/install-latest.sh "$@" %$installDir% $reference
  ;;

  -U|--uninstall)
    set +euo pipefail 2>/dev/null
    $modPath/uninstall.sh
  ;;

  -v|--version)
    echo "$accVer ($accVerCode)"
  ;;

  -w*|--watch*)
    sleepSeconds=${1#*h}
    sleepSeconds=${sleepSeconds#*w}
    : ${sleepSeconds:=3}
    . $modPath/batt-info.sh
    print_quit CTRL-C
    sleep 1.5
    while :; do
      clear
      batt_info "${2-}"
      sleep $sleepSeconds
      set +x
    done
  ;;

  *)
    shift
    print_help > $TMPDIR/.help
    edit $TMPDIR/.help "$@"
    rm $TMPDIR/.help
  ;;

esac

exit 0
