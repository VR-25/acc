#!/system/bin/sh
# Advanced Charging Controller
# Copyright 2017-2022, VR25
# License: GPLv3+


_batt_info() {
  set +e
  dsys="$(dumpsys battery)"

  {
    {

      if tt "${dsys:-x}" "*reset*"; then

        status=$(echo "$dsys" | sed -n 's/^  status: //p')
        level=$(echo "$dsys" | sed -n 's/^  level: //p')
        powered=$(echo "$dsys" | grep ' powered: true' > /dev/null && echo true || echo false)

        cmd_batt reset
        dumpsys battery
        cmd_batt set status $status
        cmd_batt set level $level

        if $powered; then
          cmd_batt set ac 1
        else
          cmd_batt unplug
        fi

      else
        echo "$dsys"
      fi

    } | grep -Ei "${1-.*}" \
        | sed -e '1s/.*/Battery Service/' && echo

    . $execDir/batt-info.sh
    echo Uevent
    batt_info "${1-}" | sed 's/^/  /'

  } | more
}


daemon_ctrl() {

  local isRunning=false

  flock -n 0 <>$TMPDIR/acc.lock || isRunning=true

  case "${1-}" in

    start)
      if $isRunning; then
        print_already_running
        return 8
      else
        print_started
        echo
        exec $TMPDIR/accd $config
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
      echo
      exec $TMPDIR/accd $config
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
    IFS="$(printf ' \t\n')" eval "$* $file"
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
  chargingSwitch=($@)

  flip_sw off && sleep_sd not_charging

  $blacklisted && {
    print_blacklisted "$@"
    return 10
  }

  ! not_charging && failed=true || {
    [ $_status = Idle ] \
      && battIdleMode=true \
      || { [ ${chargingSwitch[2]:-.} = voltage_now ] && battIdleMode=true || battIdleMode=false; }
  }

  flip_sw on 2>/dev/null

  if ! $failed && sleep_sd "! not_charging"; then
    print_switch_works "$@"
    echo "- battIdleMode=$battIdleMode"
    return 0
  else
    print_switch_fails "$@"
    return 1
  fi
}


exxit() {
  local exitCode=$?
  set +eux
  ! ${noEcho:-false} && ${verbose:-true} && echo
  tt "$exitCode" "[05689]" || {
    tt "$exitCode" "[127]|10" && logf --export
    echo
  }
  cd /
  exit $exitCode
}


parse_switches() {

  local f=$TMPDIR/.parse_switches.tmp
  local i=
  local n=

  [ -n "${2-}" ] || set -- $TMPDIR/ch-switches "${1-}"

  if [ -z "${2-}" ]; then
    set -- $1 $(echo $dataDir/logs/power_supply-${device}.log)
    [ -f $2 ] || $execDir/power-supply-logger.sh
  fi

  cat -v "$2" > $f

  for i in $(grep -Ein '^  ((1|0)$|.*able.*)' $f | cut -d: -f1); do

    n=$i
    i="$(sed -n "$(($n - 1))p" "$f")"
    n=$(sed -n ${n}p $f)
    n="$([ $n -eq 1 ] && echo "1 0" || echo "0 1")"

    i="$(echo "$i $n" | grep -Eiv 'brightness|curr|online|present|runtime|status|temp|volt|wakeup' \
      | sed 's|^/.*/power_supply/||')"

    if [ -n "$i" ] && ! grep -q "^$i" $1; then
      echo "$i"
    fi

  done

  rm $f
}


rollback() {
  rm -rf $execDir/*
  cp -a $dataDir/backup/* $execDir/
  mv -f $execDir/config.txt $config
  $TMPDIR/accd --init
}


set_prop_() {
  . $execDir/set-prop.sh
  set_prop "$@"
}


! ${verbose:-true} || echo
execDir=/data/adb/vr25/acc
defaultConfig=$execDir/default-config.txt

# load generic functions
. $execDir/logf.sh
. $execDir/misc-functions.sh

if [ "${1:-y}" = -x ]; then
  log=/sdcard/acc-${device}.log
  shift
else
  log=$TMPDIR/acc-${device}.log
fi

# verbose
if ${verbose:-true} && ! tt "${1-}" "*-w*"; then
  [ -z "${LINENO-}" ] || export PS4='$LINENO: '
  touch $log
  [ $(du -k $log | cut -f 1) -ge 256 ] && : > $log
  echo "###$(date)###" >> $log
  echo "versionCode=$(sed -n s/versionCode=//p $execDir/module.prop 2>/dev/null)" >> $log
  set -x 2>>$log
fi


accVer=$(get_prop version $execDir/module.prop)
accVerCode=$(get_prop versionCode $execDir/module.prop)

unset -f get_prop


misc_stuff "${1-}"
! tt "${1-}" "*/*" || shift


# reset broken/obsolete config
(set +x; . $config) > /dev/null 2>&1 \
  || cat -f $execDir/default-config.txt > $config

. $config


# load default language (English)
. $execDir/strings.sh

# load translations
if ${verbose:-true} && [ -f $execDir/translations/$language/strings.sh ]; then
  . $execDir/translations/$language/strings.sh
fi
grep -q .. $execDir/translations/$language/README.md 2>/dev/null \
  && readMe=$execDir/translations/$language/README.md \
  || readMe=$dataDir/README.md


# aliases/shortcuts
# daemon_ctrl status (acc -D|--daemon): "accd,"
# daemon_ctrl stop (acc -D|--daemon stop): "accd."
! tt "$0" "*accd*" || {
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
    if [ $1 -gt 3000 ]; then
      capacity[2]=${2:-$((${1}-50))}
    else
      capacity[2]=${2:-$((${1}-5))}
    fi
    capacity[3]=$1
    . $execDir/write-config.sh
  ;;

  -b|--rollback)
    rollback
  ;;

  -c|--config)
    shift; edit $config "$@"
  ;;

  -d|--disable)
    shift
    ${verbose:-true} || exec > /dev/null
    ! daemon_ctrl stop > /dev/null || print_stopped
   . $execDir/acquire-lock.sh
    disable_charging "$@"
  ;;

  -D|--daemon)
    shift; daemon_ctrl "$@"
  ;;

  -e|--enable)
    shift
    ${verbose:-true} || exec > /dev/null
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
    resume_capacity=$(( pause_capacity - 1 ))
    runCmdOnPause_="exec $TMPDIR/accd"

    cp -f $config $TMPDIR/.acc-f-config
    config=$TMPDIR/.acc-f-config
    . $execDir/write-config.sh
    print_charging_enabled_until ${2:-100}%
    echo
    exec $TMPDIR/accd $config
  ;;


  -F|--flash)
    shift
    set +eux
    trap - EXIT
    $execDir/flash-zips.sh "$@"
  ;;

  -i|--info)
    _batt_info "${2-.*}"
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

  -p|--parse)
    shift
    parse_switches "$@"
  ;;

  -r|--readme)
    shift; edit $readMe "$@"
  ;;

  -R|--resetbs)
    dumpsys batterystats --reset
    rm -rf /data/system/battery*stats* 2>/dev/null || :
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

    daemon_ctrl stop > /dev/null \
      && daemonWasUp=true || daemonWasUp=false

    . $execDir/acquire-lock.sh

    grep -Ev '^$|^#' $config > $TMPDIR/.config
    config=$TMPDIR/.config

    set +e
    trap '! $daemonWasUp || exec $TMPDIR/accd $config_' EXIT

    not_charging && enable_charging > /dev/null

    not_charging && {
      (print_wait_plug
      while not_charging; do
        sleep 1
        set +x
      done)
    }

    print_wait
    [ "${1-}" != -- ] || shift #legacy

    case "${2-}" in
      "")
        exitCode=10
        # [ -n "${1-}" ] || { ###
        #   set -- $dataDir/logs/acc-t.log
        #   cp $TMPDIR/ch-switches $1
        # }
        while read _chargingSwitch; do
          echo "x$_chargingSwitch" | grep -Eq '^x$|^x#' && continue
          [ -f "$(echo "$_chargingSwitch" | cut -d ' ' -f 1)" ] && {
            echo
            # sed -i "\|^$_chargingSwitch$|s|^|##|" "$1"
            test_charging_switch $_chargingSwitch
            # sed -i "\|^##$_chargingSwitch$|s|^#||" "$1"
          }
          [ $? -eq 0 ] && exitCode=0
        # done < "$1"
        done < ${1-$TMPDIR/ch-switches}
        echo
      ;;
      *)
        echo
        test_charging_switch "$@"
        echo
      ;;
    esac

    : ${exitCode=$?}
    exit $exitCode
  ;;


  -T|--logtail|-L) #legacy
    if ${verbose:-true} && [ $1 != -L ]; then
      print_quit CTRL-C
      sleep 1.5
    fi
    tail -F $TMPDIR/accd-*.log
  ;;

  -u|--upgrade)
    shift
    local array[0]=
    local insecure=
    local reference=

    for i; do
      array+=("$i")
      case "$i" in
        -c|--changelog)
        ;;
        -f|--force)
        ;;
        -k|--insecure)
          insecure=--insecure
        ;;
        -n|--non-interactive)
        ;;
        *)
          unset array[$((${#array[@]}-1))]
          reference="$i"
        ;;
      esac
    done
    test ${#array[@]} -lt 2 || unset array[0]

    test -n "$reference" || {
      grep -Eq '^version=.*-(beta|rc)' $execDir/module.prop \
        && reference=dev \
        || reference=master
    }

    ! test -f /data/adb/vr25/bin/curl || {
      test -x /data/adb/vr25/bin/curl \
        || chmod -R 0700 /data/adb/vr25/bin
    }

    curl $insecure -Lo $TMPDIR/install-online.sh https://raw.githubusercontent.com/VR-25/acc/$reference/install-online.sh
    trap - EXIT
    set +eu
    installDir=$(readlink -f $execDir)
    installDir=${installDir%/*}
    . $TMPDIR/install-online.sh "${array[@]}" %$installDir% $reference
  ;;

  -U|--uninstall)
    set +eu
    /system/bin/sh $execDir/uninstall.sh
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
      batt_info "${2-}"
      sleep $sleepSeconds
      set +x
    done
  ;;

  *)
    . $execDir/print-help.sh
    print_help_
  ;;

esac

exit 0
