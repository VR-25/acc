#!/system/bin/sh
# Advanced Charging Controller
# Copyright (c) 2017-2020, VR25 (xda-developers)
# License: GPLv3+


daemon_ctrl() {

  local isRunning=false

  flock -n 0 <>$TMPDIR/acc.lock \
    && flock -u 0 <>$TMPDIR/acc.lock \
    || isRunning=true

  case "${1-}" in

    start)
      if $isRunning; then
        print_already_running
        return 8
      else
        print_started
        exec /dev/accd $config
      fi
    ;;

    stop)
      if $isRunning; then
        . $execDir/release-lock.sh
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
      exec /dev/accd $config
    ;;

    *)
      if $isRunning; then
        print_is_running "$accVer ($accVerCode)" "(PID $(cat $TMPDIR/acc.lock))"
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

  local failed=false switchDelay=${switchDelay_-${mtksd-7}}

  chmod u+w $1 ${4-} \
    && run_xtimes "echo ${3//::/ } > $1 && echo ${6//::/ } > ${4:-/dev/null}" \
    && sleep $switchDelay

  ! not_charging && failed=true || {
    eval "${chargDisabledNotifCmd[@]-}"
    grep -iq 'not' $batt/status \
      && battIdleMode=true \
      || battIdleMode=false
  }

  if ! $failed \
    && run_xtimes "echo ${2//::/ } > $1 && echo ${5//::/ } > ${4:-/dev/null}" \
    && sleep $switchDelay && ! not_charging && eval "${chargEnabledNotifCmd[@]-}"
  then
    print_switch_works "$@"
    echo "- battIdleMode=$battIdleMode"
    return 0
  else
    print_switch_fails "$@"
    run_xtimes "echo ${2//::/ } > $1; echo ${5//::/ } > ${4:-/dev/null}" 2>/dev/null
    return 1
  fi
}


exxit() {
  local exitCode=$?
  set +eux
  ! ${noEcho:-false} && ${verbose:-true} && echo
  [[ $exitCode == [05689] ]] || {
    [[ $exitCode == [127] || $exitCode == 10 ]] && {
      logf --export
      eval "${errorAlertCmd[@]-}"
    }
    echo
  }
  rm /dev/.acc-config 2>/dev/null
  exit $exitCode
}


set_prop_() {
  . $execDir/set-prop.sh
  set_prop "$@"
}


! ${verbose:-true} || echo
isAccd=false
execDir=/data/adb/acc
defaultConfig=$execDir/default-config.txt

# load generic functions
. $execDir/logf.sh
. $execDir/misc-functions.sh

log=$TMPDIR/acc-${device}.log


# verbose
if ${verbose:-true} && [[ "${1-}" != *-w* ]]; then
    touch $log
    [ $(du -m $log | cut -f 1) -ge 2 ] && : > $log
    echo "###$(date)###" >> $log
    echo "versionCode=$(sed -n s/versionCode=//p $execDir/module.prop 2>/dev/null)" >> $log
    set -x 2>>$log
fi


accVer=$(get_prop version $execDir/module.prop)
accVerCode=$(get_prop versionCode $execDir/module.prop)

unset -f get_prop


misc_stuff "${1-}"
[[ "${1-}" != */* ]] || shift


# reset broken/obsolete config
(set +x; . $config) > /dev/null 2>&1 || cp -f $execDir/default-config.txt $config

. $config


# load default language (English)
. $execDir/strings.sh

# load translations
if ${verbose:-true} && [ -f $execDir/translations/$language/strings.sh ]; then
  . $execDir/translations/$language/strings.sh
fi
grep -q .. $execDir/translations/$language/README.md 2>/dev/null \
  && readMe=$execDir/translations/$language/README.md \
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
    . $execDir/wizard.sh
    wizard
  ;;

  [0-9]*)
    capacity[2]=$2
    capacity[3]=$1
    . $execDir/write-config.sh
  ;;

  -c|--config)
    shift; edit $config "$@"
  ;;

  -d|--disable)
    shift
    print_m_mode
    ! daemon_ctrl stop > /dev/null || print_stopped
   . $execDir/acquire-lock.sh
    disable_charging "$@"
  ;;

  -D|--daemon)
    shift; daemon_ctrl "$@"
  ;;

  -e|--enable)
    shift
    print_m_mode
    ! daemon_ctrl stop > /dev/null || print_stopped
    . $execDir/acquire-lock.sh
    enable_charging "$@"
  ;;


  -f|--force|--full)

    shutdown_capacity=
    cooldown_capacity=
    cooldown_temp=
    cooldown_charge=
    cooldown_pause=
    max_temp=
    max_temp_pause=
    cooldown_custom=
    apply_on_boot=
    apply_on_plug=
    max_charging_current=
    max_charging_voltage=

    pause_capacity=${2:-100}
    resume_capacity=$(( pause_capacity - 5 ))
    run_cmd_on_pause="exec /dev/accd"

    cp -f $config $TMPDIR/.acc-f-config
    config=$TMPDIR/.acc-f-config
    . $execDir/write-config.sh
    print_charging_enabled_until ${2:-100}%
    echo
    exec /dev/accd $config
  ;;


  -F|--flash)
    shift
    set +eux
    trap - EXIT
    $execDir/flash-zips.sh "$@"
  ;;


  -i|--info)

    dsys="$(dumpsys battery)"

    { if [[ "$dsys" == *reset* ]] > /dev/null; then
      status=$(echo "$dsys" | sed -n 's/^  status: //p')
      level=$(echo "$dsys" | sed -n 's/^  level: //p')
      powered=$(echo "$dsys" | grep ' powered: true' > /dev/null && echo true || echo false)
      dumpsys battery reset
      dumpsys battery
      dumpsys battery set status $status
      dumpsys battery set level $level
      if $powered; then
        dumpsys battery set ac 1
      else
        dumpsys battery unplug
      fi
    else
      echo "$dsys"
    fi \
      | grep -Ei "${2-.*}" \
      | sed -e '1s/.*/dumpsys battery/' && echo; } || :

    . $execDir/batt-info.sh
    echo "/sys/class/power_supply/$batt/uevent"
    batt_info "${2-}" | sed 's/^/  /'
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

  -r|--readme)
    shift; edit $readMe "$@"
  ;;

  -R|--resetbs)
    dumpsys batterystats --reset || :
    rm /data/system/batterystats* 2>/dev/null || :
  ;;

  -sc)
    set_prop_ --current ${2-}
  ;;

  -sd)
    set_prop_ --print-default "${2-.*}"
  ;;

  -sl)
    set_prop_ --lang
  ;;

  -sp)
    set_prop_ --print "${2-.*}"
  ;;

  -sr)
    set_prop_ --reset
  ;;

  -ss)
    shift
    set_prop_ --charging_switch
  ;;

  -ss:)
    set_prop_ --charging_switch:
  ;;

  -sv)
    shift
    set_prop_ --voltage "$@"
  ;;

  -s|--set)
    shift
    set_prop_ "$@"
  ;;


  -t|--test)

    shift
    print_unplugged
    daemon_ctrl stop > /dev/null && daemonWasUp=true || daemonWasUp=false

    . $execDir/acquire-lock.sh

    cp $config /dev/.acc-config
    config=/dev/.acc-config
    fd3=true
    exec 3>&1

    set +e
    trap '! $daemonWasUp || exec /dev/accd $config_' EXIT

    not_charging && enable_charging > /dev/null
    not_charging && {
      (print_wait_plug
      while not_charging; do
        sleep 1
        set +x
      done)
    }

    print_wait

    # custom switch delay
    case "${1-}" in
      [0-9]|[0-9][0-9]|[0-9].[0-9])
        switchDelay_=$1
        shift
      ;;
    esac

    case "${1-}" in
      */*)
        echo
        test_charging_switch "$@"
        echo
      ;;
      *)
        [ "${1-}" != -- ] || shift ### legacy
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
    esac

    : ${exitCode=$?}
    exit $exitCode
  ;;


  -T|--logtail|-L) # legacy
    if ${verbose:-true} && [ $1 != -L ]; then
      print_quit CTRL-C
      sleep 1.5
    fi
    tail -F $TMPDIR/accd-*.log
  ;;


  -u|--upgrade)
    shift
    local reference=""

    case "$@" in
      *beta*|*dev*|*rc\ *|*\ rc*)
        reference=dev
      ;;
      *master*|*stable*)
        reference=master
      ;;
      *)
        grep -Eq '^version=.*-(beta|rc)' $execDir/module.prop \
          && reference=dev \
          || reference=master
      ;;
    esac

    case "$@" in
      *--insecure*|*-k*) insecure=--insecure;;
      *) insecure=;;
    esac

    [ ! -f /data/adb/bin/curl ] || {
      [ -x /data/adb/bin/curl ] || chmod -R 0700 /data/adb/bin
      export curlPath=true PATH=/data/adb/bin:$PATH
    }

    curl $insecure -Lo $TMPDIR/install-online.sh https://raw.githubusercontent.com/VR-25/acc/$reference/install-online.sh
    trap - EXIT
    set +eu
    installDir=$(readlink -f $execDir)
    installDir=${installDir%/*}
    . $TMPDIR/install-online.sh "$@" %$installDir% $reference
  ;;

  -U|--uninstall)
    set +eu
    $execDir/uninstall.sh
  ;;

  -v|--version)
    echo "$accVer ($accVerCode)"
  ;;

  -w*|--watch*)
    sleepSeconds=${1#*h}
    sleepSeconds=${sleepSeconds#*w}
    : ${sleepSeconds:=3}
    . $execDir/batt-info.sh
    ! ${verbose:-true} || print_quit CTRL-C
    sleep 1.5
    while :; do
      clear
      for batt in $(ls */uevent); do
        chmod u+r $batt \
           && grep -q '^POWER_SUPPLY_CAPACITY=' $batt \
           && grep -q '^POWER_SUPPLY_STATUS=' $batt \
           && batt=${batt%/*} && break
      done 2>/dev/null || :
      batt_info "${2-}"
      sleep $sleepSeconds
      set +x
    done
  ;;

  *)
    shift
    . $execDir/print-help.sh
    print_help_
  ;;

esac

exit 0
