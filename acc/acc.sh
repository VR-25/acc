#!/system/bin/sh
# Advanced Charging Controller
# Copyright (c) 2017-2020, VR25 (xda-developers)
# License: GPLv3+


daemon_ctrl() {

  local isRunning=true
  set +eo pipefail 2>/dev/null
  local pid="$(pgrep -f '/ac(c|ca) (-|--)(calibrate|[Cdef])|/accd\.sh' | sed s/$$//)"
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
        set +eo pipefail 2>/dev/null
        echo "$pid" | xargs kill -9 2>/dev/null
        { dumpsys battery reset
        not_charging && {
          enable_charging || try_enabling_again
        }
        [ ${2:-x} != skipab ] && {
          case "${2-}" in
            forceab) apply_on_boot default force;;
            *) apply_on_boot default;;
          esac
        }
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

  local failed=false

  if [ -n "${1-}" ]; then

    chmod +w $1 ${4-} && echo "${3//::/ }" > $1 && echo "${6//::/ }" > ${4:-/dev/null} && sleep $switchDelay

    ! not_charging && failed=true || {
      grep -iq 'not' $batt/status \
        && battIdleMode=true \
        || battIdleMode=false
    }

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

    {
      disable_charging || try_disabling_again
      ! not_charging && failed=true || {
        enable_charging || try_enabling_again
      }
    } > /dev/null

    if ! $failed && ! not_charging; then
      print_supported
      return 0
    else
      print_unsupported
      ({ enable_charging || try_enabling_again; } > /dev/null 2>&1 &) &
      return 1
    fi

  fi
}


exxit() {
  local exitCode=$?
  ! { ! ${noEcho:-false} && ${verbose:-true}; } || echo
  [[ $exitCode == [0568] ]] || {
    vibrate 3 0.3
    [[ $exitCode != [127] ]] || logf --export > /dev/null 2>&1
  }
  rm /dev/.acc-config 2>/dev/null
  exit $exitCode
}


umask 077
isAccd=false
modPath=/sbin/.acc/acc
export TMPDIR=${modPath%/*}
config=/data/adb/acc-data/config.txt
defaultConfig=$modPath/default-config.txt

[ -f $TMPDIR/.ghost-charging ] && ghostCharging=true || ghostCharging=false


# load generic functions
. $modPath/logf.sh
. $modPath/misc-functions.sh

! ${verbose:-true} || echo
. $modPath/setup-busybox.sh

device=$(getprop ro.product.device | grep .. || getprop ro.build.product)
log=$TMPDIR/acc-${device}.log


# verbose
if ${verbose:-true} && [[ "${1-}" != *-w* ]]; then
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
[ ! -d /data/media/0/?ndroid ] || {
  [ /data/media/0/.acc-config-backup.txt -nt $config ] \
    || install -m 777 $config /data/media/0/.acc-config-backup.txt 2>/dev/null || :
}

# load config from a custom path
case "${1-}" in
  */*)
    [ -f $1 ] || cp $config $1
    config=$1
    . $config
    shift
  ;;
esac


accVer=$(get_prop version $modPath/module.prop)
accVerCode=$(get_prop versionCode $modPath/module.prop)

unset -f get_prop

batt=$(echo *attery/capacity | cut -d ' ' -f 1 | sed 's|/capacity||')


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
    daemon_ctrl stop > /dev/null || :
    print_quit CTRL-C
    sleep 2
    until [ $(cat $batt/status) == Full ]; do
      for i in "¦     %     ¦" "\\ >   %   < /" "- >>  %  << -" "/ >>> % <<< \\"; do
        clear
        echo -n "$i" | sed "s/%/[$(cat $batt/capacity)%]/"
        sleep 0.2
      done
      unset i
    done
    vibrate 5 0.3
    print_discharge
  ;;

  -d|--disable)
    shift
    print_m_mode
    ! daemon_ctrl stop > /dev/null || print_stopped
    disable_charging "$@" || try_disabling_again "$@"
  ;;

  -D|--daemon)
    shift; daemon_ctrl "$@"
  ;;

  -e|--enable)
    shift
    print_m_mode
    ! daemon_ctrl stop > /dev/null || print_stopped
    enable_charging "$@" || try_enabling_again "$@"
  ;;

  -f|--force|--full)
    daemon_ctrl stop > /dev/null && daemonWasUp=true || daemonWasUp=false
    print_charging_enabled_until ${2:-100}%
    (enable_charging ${2:-100}% nodisable || try_enabling_again ${2:-100}% nodisable
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
    print_wait
    cp $config /dev/.acc-config
    oldConfig=$config
    config=/dev/.acc-config
    daemon_ctrl stop > /dev/null && daemonWasUp=true || daemonWasUp=false
    set +eo pipefail 2>/dev/null
    switchDelay=18 # to account for switches with absurdly slow responsiveness
    not_charging && { enable_charging || try_enabling_again; } > /dev/null

    not_charging && {
      print_unplugged
      config=$oldConfig
      $daemonWasUp && /sbin/accd $config
      exit 2
    }

    case "${1-}" in
      --)
        exitCode=1
        while read chargingSwitch; do
          [ -f "$(echo "$chargingSwitch" | cut -d ' ' -f 1)" ] && {
            echo
            test_charging_switch $chargingSwitch
          }
          [ $? -eq 0 ] && exitCode=0
        done < ${2:-$TMPDIR/charging-switches}
        echo
      ;;
      "")
        test_charging_switch
      ;;
      *)
        test_charging_switch "$@"
      ;;
    esac

    : ${exitCode=$?}
    config=$oldConfig
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
    local reference=$(echo "$@" | sed -E 's/-c|--changelog|-f|--force|-k|--insecure|-n|--non-interactive| //g')

    echo "$reference" | grep -Eiq 'dev|master' || {
      grep -q '^version=.*-dev' $modPath/module.prop \
        && reference=dev \
        || reference=master
    }

    case "$@" in
      *--insecure*|*-k*) insecure=--insecure;;
      *) insecure=;;
    esac

    curl $insecure -Lo $TMPDIR/install-latest.sh https://raw.githubusercontent.com/VR-25/acc/$reference/install-latest.sh
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
    . $modPath/print-help.sh
    print_help_
  ;;

esac

exit 0
