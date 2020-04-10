#!/system/bin/sh
# Advanced Charging Controller
# Copyright (c) 2017-2020, VR25 (xda-developers)
# License: GPLv3+


daemon_ctrl() {

  local isRunning=true
  set +eo pipefail 2>/dev/null
  local pid="$(pgrep -f '/ac(c|ca) (-|--)(calibrate|test|[Cdeft])|/accd\.sh' | sed /$$/d)"
  set -eo pipefail 2>/dev/null || :
  [[ ${pid:-x} == *[0-9]* ]] || isRunning=false

  case "${1-}" in

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
        (set +euo pipefail
        echo "$pid" | xargs kill $2) 2>/dev/null || :
        sleep 0.2
        while [ -n "$(pgrep -f '/ac(c|ca) (-|--)(calibrate|test|[Cdeft])|/accd\.sh' | sed /$$/d)" ]; do
          sleep 0.2
        done
        print_stopped
        return 0
      else
        print_not_running
        return 9
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
        return 9
      fi
    ;;
  esac
}


edit() {
  local file="$1"
  shift
  if [ -n "${1-}" ]; then
    eval "$@ $file"
  else
    ! ${verbose:-true} || {
      case $file in
        *.txt)
          if which nano > /dev/null; then
            print_quit CTRL-X
          else
            print_quit "[esc] :q [enter]" "[esc] :wq [enter]"
          fi
        ;;
        *.log|*.md|*.help)
          print_quit q
        ;;
      esac
      sleep 2
      echo
    }
    case $file in
     *.txt) nano -$ $file || vim $file || vi $file;;
     *.log|*.md|*.help) less $file;;
    esac 2>/dev/null
  fi
}


get_prop() { sed -n "s|^$1=||p" ${2:-$config}; }


test_charging_switch() {

  local failed=false switchDelay=20

  chmod +w $1 ${4-} \
    && echo "${3//::/ }" > $1 \
    && echo "${6//::/ }" > ${4:-/dev/null} \
    && sleep $switchDelay

  ! not_charging && failed=true || {
    vibrate ${vibrationPatterns[8]} ${vibrationPatterns[9]}
    grep -iq 'not' $batt/status \
      && battIdleMode=true \
      || battIdleMode=false
  }

  if ! $failed && echo "${2//::/ }" > $1 \
    && echo "${5//::/ }" > ${4:-/dev/null} \
    && sleep $switchDelay && ! not_charging && vibrate ${vibrationPatterns[4]} ${vibrationPatterns[5]}
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
}


exxit() {
  local exitCode=$?
  set +euxo pipefail 2>/dev/null
  ! ${noEcho:-false} && ${verbose:-true} && echo
  [[ $exitCode == [05689] ]] || {
    [[ $exitCode == [127] || $exitCode == 10 ]] && logf --export
    echo
    vibrate ${vibrationPatterns[6]-6} ${vibrationPatterns[7]-0.1}
  }
  rm /dev/.acc-config 2>/dev/null
  ! ${restartDaemon-false} || {
    ! $daemonWasUp || /sbin/accd $config
  }
  exit $exitCode
}


! ${verbose:-true} || echo
isAccd=false
modPath=/sbin/.acc/acc
defaultConfig=$modPath/default-config.txt

# load generic functions
. $modPath/logf.sh
. $modPath/misc-functions.sh

log=$TMPDIR/acc-${device}.log


# verbose
if ${verbose:-true} && [[ "${1-}" != *-w* ]]; then
    touch $log
    [ $(du -m $log | cut -f 1) -ge 2 ] && : > $log
    echo "###$(date)###" >> $log
    echo "versionCode=$(sed -n s/versionCode=//p $modPath/module.prop 2>/dev/null)" >> $log
    set -x 2>>$log
fi


accVer=$(get_prop version $modPath/module.prop)
accVerCode=$(get_prop versionCode $modPath/module.prop)

unset -f get_prop


misc_stuff "${1-}"
[[ "${1-}" != */* ]] || shift
config__=$config


# reset broken config
(. $config 2>/dev/null) \
  || cp -f $modPath/default-config.txt $config
. $config


# load default language (English)
. $modPath/strings.sh

# load translations
if ${verbose:-true} && [ -f $modPath/translations/$language/strings.sh ]; then
  . $modPath/translations/$language/strings.sh
fi
grep -q .. $modPath/translations/$language/README.md 2>/dev/null \
  && readMe=$modPath/translations/$language/README.md \
  || readMe=${config%/*}/info/README.md


# aliases/shortcuts
# daemon_ctrl status (acc -D|--daemon): "accd,"
# daemon_ctrl stop (acc -D|--daemon stop): "accd."
[[ $0 != *accd* ]] || {
  case $0 in
    *accd.) daemon_ctrl stop;;
    *) daemon_ctrl;;
  esac
  exit $?
}


case "${1-}" in

  "")
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

  -C|--calibrate)
    daemon_ctrl stop > /dev/null && daemonWasUp=true || daemonWasUp=false
    restartDaemon=true
    [ -f $batt/charge_counter -a -f $batt/charge_full ] || {
      acca --watch${2-} "$(print_calibration)"
      return 0
    }
    print_quit CTRL-C
    sleep 2
    while [[ $(cat $batt/charge_counter) -lt $(cat $batt/charge_full) ]]; do
      for i in "¦     %     ¦" "\\ >   %   < /" "- >>  %  << -" "/ >>> % <<< \\"; do
        clear
        echo -n "$i" | sed "s/%/[$(cat $batt/capacity)%]/"
        sleep 0.2
      done
      unset i
    done
    vibrate ${vibrationPatterns[2]} ${vibrationPatterns[3]}
    print_discharge
  ;;

  -d|--disable)
    shift
    not_charging && print_already_discharging || {
      print_m_mode
      ! daemon_ctrl stop > /dev/null || print_stopped
      disable_charging "$@"
    }
  ;;

  -D|--daemon)
    shift; daemon_ctrl "$@"
  ;;

  -e|--enable)
    shift
    ! not_charging && print_already_charging || {
      print_m_mode
      ! daemon_ctrl stop > /dev/null || print_stopped
      enable_charging "$@"
    }
  ;;

  -f|--force|--full)
    daemon_ctrl stop > /dev/null && daemonWasUp=true || daemonWasUp=false
    print_charging_enabled_until ${2:-100}%
    (enable_charging ${2:-100}% noap
    ! $daemonWasUp || /sbin/accd $config &) > /dev/null 2>&1 &
  ;;

  -F|--flash)
    shift
    set +euxo pipefail 2>/dev/null
    trap - EXIT
    $modPath/flash-zips.sh "$@"
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
    ! ${verbose:-true} || {
      print_quit CTRL-C
      sleep 1.5
    }
    tail -F $TMPDIR/accd-*.log
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
    ! not_charging || print_unplugged
    print_wait
    cp $config /dev/.acc-config
    config=/dev/.acc-config
    exec 3>&1
    forceVibrations=true
    daemon_ctrl stop && daemonWasUp=true || daemonWasUp=false

    set +eo pipefail 2>/dev/null
    enable_charging

    not_charging && {
      (print_wait_plug
      trap '$daemonWasUp && {
        /sbin/accd $config__
        print_started
      }' EXIT
      while not_charging; do
        sleep 1
        set +x
      done)
    }

    case "${2-}" in
      "")
        exitCode=10
        while read chargingSwitch; do
          [ -f "$(echo "$chargingSwitch" | cut -d ' ' -f 1)" ] && {
            echo
            test_charging_switch $chargingSwitch
          }
          [ $? -eq 0 ] && exitCode=0
        done < ${1-$TMPDIR/ch-switches}
        echo
      ;;
      *)
        test_charging_switch "$@"
      ;;
    esac

    : ${exitCode=$?}

    $daemonWasUp && {
      /sbin/accd $config__
      print_started
    }

    exit $exitCode
  ;;


  -u|--upgrade)
    shift
    local reference=""

    case "$@" in
      *beta*|*dev*)
        reference=dev
      ;;
      *master*|*stable*)
        reference=master
      ;;
      *)
        grep -q '^version=.*-beta' $modPath/module.prop \
          && reference=dev \
          || reference=master
      ;;
    esac

    case "$@" in
      *--insecure*|*-k*) insecure=--insecure;;
      *) insecure=;;
    esac

    curl $insecure -Lo $TMPDIR/install-online.sh https://raw.githubusercontent.com/VR-25/acc/$reference/install-online.sh
    trap - EXIT
    set +euo pipefail 2>/dev/null
    installDir=$(readlink -f $modPath)
    installDir=${installDir%/*}
    . $TMPDIR/install-online.sh "$@" %$installDir% $reference
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
    [ "${2-}" == "$(print_calibration)" ] && { calibration=true; shift; } || calibration=false
    while :; do
      clear
      ! $calibration || {
        print_calibration
        echo
      }
      batt_info "${2-}"
      sleep $sleepSeconds
      set +x
    done
  ;;

  *)
    shift
    . $modPath/print-help.sh
    print_help_
  ;;

esac

exit 0
