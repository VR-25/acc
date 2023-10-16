#!/system/bin/sh
# Advanced Charging Controller
# Copyright 2017-2023, VR25
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

    } | grep -Ei "${1-.*}" | sed -e '1s/.*/Battery Service\n/' && echo

    . $execDir/batt-info.sh
    printf "Uevent\n\n"
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
  case "${1-}" in
    a) echo >> $file; shift; echo "$@" >> $file;;
    d) sed -Ei "\#$2#d" $file;;

    g) [ "$file" = "$config" ] || {
         install -m 666 $file /data/local/tmp/
         file=/data/local/tmp/${file##*/}
       }
       shift
       ext_app $file "$@";;

    "") case $file in
          *.log|*.md|*.help) less $file;;
          *) nano -$ $file || vim $file || vi $file || ext_app $file;;
        esac 2>/dev/null;;
    *) IFS="$(printf ' \t\n')" eval "$* $file";;
  esac
}


ext_app() {
  am start -a android.intent.action.${2:-EDIT} \
           -t "text/${3:-plain}" \
           -d file://$1 \
           --grant-read-uri-permission &>/dev/null || :
}


get_prop() { sed -n "s|^$1=||p" ${2:-$config}; }


switch_fails() {
  print_switch_fails
  ! not_charging >/dev/null || {
    print_resume
    while not_charging; do
      sleep 1
    done
  }
  return 10
}


test_charging_switch() {

  local idleMode=false
  local failed=false
  local acc_t=true
  chargingSwitch=($@)

  echo

  [ -n "${swCount-}" ] \
    && echo "$swCount/$swTotal: ${chargingSwitch[@]-}" \
    || echo "${chargingSwitch[@]-}"

  echo "chargingSwitch=($*)" > $TMPDIR/.sw
  flip_sw off
  ! [ $? -eq 2 ] || {
    flip_sw on
    switch_fails
    return 10
  }

  ${blacklisted:-false} && {
    print_blacklisted
    return 10
  }

  ! not_charging && failed=true || {
    [ $_status = Idle ] && idleMode=true
  }

  flip_sw on 2>/dev/null

  if ! $failed && ! not_charging; then
    print_switch_works
    echo "- battIdleMode=$idleMode"
    $idleMode && return 15 || return 0
  else
    switch_fails
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
    n=$(sed -n ${n}p $f | sed 's/^  //')

    case $n in
      0) n="$n 1";;
      1) n="$n 0";;
      disable) n="$n enable";;
      disabled) n="$n enabled";;
      enable) n="$n disable";;
      enabled) n="$n disabled";;
      DISABLE) n="$n ENABLE";;
      DISABLED) n="$n DISABLED";;
      ENABLE) n="$n DISABLE";;
      ENABLED) n="$n DISABLED";;
      *) continue;;
    esac

    i=${i#*/power_supply/}

    # exclude all known switches
    ! grep -q "$i " $1 || continue

    i="$(echo "$i $n" | grep -Eiv 'brightness|curr|online|present|runtime|status|temp|volt|wakeup|[^pP]reset|daemon|calibrat|init|resistance|capacitance|shutdown|parallel|cycle|shutdown|reboot|nvram|count|disk|mem_state|user|factory|timer|flash|otg|authentic|update|demo|report|info|mask')" || :

    [ -z "$i" ] || echo "$i"

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

if [ "${1:-y}" = -x ] || tt "${2-}" "p|parse"; then
  log=/sdcard/Download/acc-${device}.log
  [ $1 != -x ] || shift
else
  log=$TMPDIR/acc-${device}.log
fi

# verbose
if ${verbose:-true} && ! tt "${1-}" "-l*|--log*|-w*|--watch*"; then
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
  || cat $execDir/default-config.txt > $config

. $config


# load default language (English)
. $execDir/strings.sh

# load translations
: ${language:=en}
if ${verbose:-true} && [ -f $execDir/translations/$language/strings.sh ]; then
  . $execDir/translations/$language/strings.sh
fi

grep -q .. $execDir/translations/$language/README.html 2>/dev/null \
  && readMe=$execDir/translations/$language/README.html \
  || readMe=$dataDir/README.html


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
    pause_capacity=$1
    resume_capacity=${2:-5000}
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

    tt ".${2-}" ".-*" && _two= || _two="${2-}"

    apply_on_boot=
    apply_on_plug=
    cooldown_charge=
    cooldown_current=
    cooldown_custom=
    cooldown_pause=
    max_charging_current=
    max_charging_voltage=
    max_temp=
    off_mid=false
    resume_temp=
    temp_level=0
    pause_capacity=${_two:-100}
    resume_capacity=$((pause_capacity - 2))

    cp -f $defaultConfig $TMPDIR/.acc-f-config
    config=$TMPDIR/.acc-f-config
    . $execDir/write-config.sh
    print_charging_enabled_until ${_two:-100}%
    echo
    echo ':; ! online && [ $(cat $battCapacity) -ge ${capacity[2]} ] && exec $TMPDIR/accd || :' >> $config

     # additional options
    case "${2-}" in
      [0-9]*)
        shift 2
        ! tt "${1-}" "-*" || $TMPDIR/acca $config "$@" || :;;
      -*)
        shift
        $TMPDIR/acca $config "$@" || :;;
    esac

    exec $TMPDIR/accd $config
  ;;


  -F|--flash)
    shift
    set +eux
    trap - EXIT
    $execDir/flash-zips.sh "$@"
  ;;


  -H|--health)

    counter=$(set +e; grep -E '[1-9]+' */charge_counter 2>/dev/null | head -n 1 | sed 's/.*://' || :)
    health=
    level=$(cat $batt/capacity)
    mAh=${2-}

    [ -n "$mAh" ] || { echo "${0##*/} $1 <mAh>"; exit; }
    [ -n "$counter" ] || { echo "!"; exit; }

    [ $counter -lt 10000 ] || counter=$(calc $counter / 1000)
    health=$(calc "$counter * 100 / $level * 100 / $mAh" | xargs printf %.1f)
    [ ${health%.*} -le 99 ] && echo ${health}% || echo "!"
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

  -n|--notif)
    shift
    notif "${@-}"
  ;;

  -p|--parse)
    shift
    parse_switches "$@"
  ;;

  -r|--readme)
    if [ .${2-} = .g ]; then
      edit $readMe g VIEW html
    else
      edit ${readMe%html}md
    fi
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
    set_prop_ --reset "$@"
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
    parsed=
    exitCode_=10
    exitCode=$exitCode_
    print_wait
    print_unplugged

    ! daemon_ctrl stop > /dev/null && daemonWasUp=false || {
      daemonWasUp=true
      echo "#!/system/bin/sh
        sleep 2
        exec $TMPDIR/accd $config_" > $TMPDIR/.accdt
      chmod 0755 $TMPDIR/.accdt
    }

    . $execDir/acquire-lock.sh

    grep -Ev '^$|^#' $config > $TMPDIR/.config
    config=$TMPDIR/.config

    exxit() {
      [ -z "$parsed" ] || {
        cat $TMPDIR/ch-switches $_parsed 2>/dev/null > $parsed \
          && sort -u $parsed | sed 's/ $//; /^$/d' > $TMPDIR/ch-switches
      }
      [ ! -f $TMPDIR/.sw ] || {
        while IFS= read line; do
          [ -n "$line" ] || continue
          ! grep -q "$line " $TMPDIR/.sw || sed -i "\|$line|d" $dataDir/logs/write.log
        done < $dataDir/logs/write.log
      }
      ! $daemonWasUp || start-stop-daemon -bx $TMPDIR/.accdt -S --
      exit $exitCode
    }

    set +e
    trap exxit EXIT
    not_charging && enable_charging > /dev/null

    not_charging && {
      (print_wait_plug
      while not_charging; do
        sleep 1
        set +x
      done)
    }

    [ "${1-}" != -- ] || shift #legacy, AccA
    . $execDir/read-ch-curr-ctrl-files-p2.sh
    : > /sdcard/Download/acc-t_output-${device}.log

    if [ -z "${2-}" ]; then
      ! tt "${1-}" "p|parse" || parsed=$TMPDIR/.parsed
      [ -z "$parsed" ] || {
        _parsed=$dataDir/logs/parsed.log
        if parse_switches > $parsed; then
          set -- $parsed
          ! ${verbose:-true} || {
            print_panic
            read -n 1 a
            echo
            case "$a" in
              ""|y) edit $parsed;;
              a) exit;;
            esac
          }
        else
          echo
          exit
        fi
      }
      swCount=1
      swTotal=$(wc -l ${1-$TMPDIR/ch-switches} | cut -d ' ' -f 1)
      while read _chargingSwitch; do
        echo "x$_chargingSwitch" | grep -Eq '^x$|^x#' && continue
        [ -f "$(echo "$_chargingSwitch" | cut -d ' ' -f 1)" ] && {
          { test_charging_switch $_chargingSwitch; echo $? > $TMPDIR/.exitCode; } \
            | tee -a /sdcard/Download/acc-t_output-${device}.log
          rm $TMPDIR/.sw 2>/dev/null || :
          swCount=$((swCount + 1))
          exitCode_=$(cat $TMPDIR/.exitCode)
          if [ -n "$parsed" ] && [ $exitCode_ -ne 10 ]; then
            grep -q "^$_chargingSwitch$" $_parsed 2>/dev/null \
              || echo "$_chargingSwitch" >> $_parsed
          fi
          case $exitCode in
            15) ;;
            0) [ $exitCode_ -eq 15 ] && exitCode=15;;
            *) exitCode=$exitCode_;;
          esac
        }
      done < ${1-$TMPDIR/ch-switches}
      echo
    else
      { test_charging_switch "$@"; echo $? > $TMPDIR/.exitCode; } \
        | tee -a /sdcard/Download/acc-t_output-${device}.log
      rm $TMPDIR/.sw 2>/dev/null || :
      exitCode=$(cat $TMPDIR/.exitCode)
      echo
    fi

    print_acct_info
    echo
    exit $exitCode
  ;;


  -T|--logtail|-L) #legacy, AccA
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
      grep -Eq '^version=.*-(beta|dev|rc)' $execDir/module.prop \
        && reference=dev \
        || reference=master
    }

    ! test -f /data/adb/vr25/bin/curl || {
      test -x /data/adb/vr25/bin/curl \
        || chmod -R 0755 /data/adb/vr25/bin
    }

    if which curl >/dev/null; then
      curl $insecure -Lo $TMPDIR/install-online.sh https://raw.githubusercontent.com/VR-25/acc/$reference/install-online.sh
    else
      PATH=${PATH#*/busybox:} /dev/.vr25/busybox/wget -O $TMPDIR/install-online.sh --no-check-certificate \
        https://raw.githubusercontent.com/VR-25/acc/$reference/install-online.sh
    fi
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
    : ${sleepSeconds:=1}
    . $execDir/batt-info.sh
    while :; do
      clear
      batt_info "${2-}"
      sleep $sleepSeconds
      set +x
    done
  ;;

  *)
    . $execDir/print-help.sh
    shift
    print_help_ "$@"
  ;;

esac

exit 0
