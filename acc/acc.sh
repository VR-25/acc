#!/system/bin/sh
# Advanced Charging Controller
# Copyright (c) 2017-2019, VR25 (xda-developers.com)
# License: GPLv3+


daemon() {

  local isRunning=true
  set +eo pipefail
  local pid="$(pgrep -f '/acc (-|--)[def]|/accd.sh' | sed s/$$//)"
  set -eo pipefail
  [[ x$pid == *[0-9]* ]] || isRunning=false

  case ${1:-} in
    start)
      if $isRunning; then
        print_already_running
        return 8
      else
        print_started
        set +x
        /sbin/accd
        return 0
      fi
    ;;
    stop)
      if $isRunning; then
        set +eo pipefail
        echo "$pid" | xargs kill -9 2>/dev/null
        { dumpsys battery reset
        not_charging && enable_charging
        set_charging_voltage -; } > /dev/null 2>&1
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
      set +x
      /sbin/accd
    ;;
    *)
      if $isRunning; then
        print_is_running
        return 0
      else
        print_not_running
        return 1
      fi
    ;;
  esac
}


edit() {
  file=$1
  shift
  if [ -n "${1:-}" ]; then
    $@ $file
  else
    nano -l $file 2>/dev/null || vim $file 2>/dev/null || vi $file
  fi
}


set_value() {
  local var=$1 PS3="$(print_var_prompt)"
  if [ $var == s ]; then
    var=chargingSwitch
  else
    if grep -q "^$var=" $config; then
      :
    elif [ 0$(grep -Ec "$var.*=" $config) -ge 02 ]; then
      eval 'select var in $(sed -n "/$var.*=/s/=.*//p" $config) "<EXIT>"; do
        var=$var
        [ $var != "<EXIT>" ] || exit 0
        break
      done'
    else
      var=$(sed -n "/$var.*=/s/=.*//p" $config)
    fi
  fi
  [ -n "$var" ] || var=$1
  shift
  if grep -q "^$var=" $config; then
    sed -i "s|^$var=.*|$var=$*|" $config
  else
    print_invalid_var
    exit 1
  fi
}


set_values() {
  case ${1:-} in
    8090|lite) set_value capacity 5,60,80-90;;
    9095|travel) set_value capacity 5,60,90-95;;
    7580|default) set_value capacity 5,60,75-80;;
    5960|endurance) set_value capacity 5,60,59-60;;
    4041|endurance+) set_value capacity 5,60,40-41;;
    r|reset)
      daemon > /dev/null && daemonWasUp=true || daemonWasUp=false
      cp $defaultConfig $config
      print_config_reset
      ! $daemonWasUp || /sbin/accd
      return 0
    ;;
    *)
      if [ -n "${1:-}" ]; then
        if [ -z "${2:-}" ] && [[ $1 == s || $1 == chargingSwitch ]]; then
          set_charging_switch
        elif [ "${2:-x}" == : ] || [[ $1 == s: || $1 == chargingSwitch: ]]; then
          ls_charging_switches
        elif [ "${2:-x}" == "-" ] || [[ $1 == s- || $1 == chargingSwitch- ]]; then
          set_value chargingSwitch
          print_cs_reset
        else
          set_value $@
        fi
      else
        grep '^[a-z].*=' $config
      fi
    ;;
  esac
}


set_charging_switch() {
  local chargingSwitch="" IFS=$'\n'
  local PS3="
$(print_choice_prompt)"
  print_supported_cs
  echo
  eval 'select chargingSwitch in $(print_auto) $(ls_charging_switches) $(print_exit); do
    [ ${chargingSwitch:-x} != $(print_exit) ] || exit 0
    [ ${chargingSwitch:-x} == $(print_auto) ] && set_values chargingSwitch- > /dev/null && exit 0 || :
    set_value chargingSwitch "$chargingSwitch"
    break
  done'
}


disable_charging() {
  local file="" value=""
  if [[ "$(get_value chargingSwitch)" == */* ]]; then
    file=$(echo $(get_value chargingSwitch) | awk '{print $1}')
    value=$(get_value chargingSwitch | awk '{print $3}')
    if [ -f $file ]; then
      chmod +w $file && echo $value > $file && sleep $(get_value chargingOnOffDelay) 2>/dev/null \
        || { print_cs_fails
          set_value chargingSwitch
          exit 1; }
    else
      print_invalid_cs
      set_value chargingSwitch
      exit 1
    fi
  else
    ! eval $(get_value prioritizeBattIdleMode) || switch_loop off not
    not_charging || switch_loop off
  fi
  if [ -n "${1:-}" ]; then
    if [[ $1 == *% ]]; then
      print_ch_disabled_until $1
      echo
      until [ $(( $(cat $batt/capacity) $(get_value capacityOffset) )) -le ${1%\%} ]; do
        sleep $(get_value loopDelay | cut -d, -f2)
      done
      enable_charging
    elif [[ $1 == *[smh] ]]; then
      print_ch_disabled_for $1
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
      print_ch_disabled
    fi
  else
    print_ch_disabled
  fi
}


enable_charging() {
  local file="" value="" file2="" value2=""
  if [[ "$(get_value chargingSwitch)" == */* ]]; then
    file=$(echo $(get_value chargingSwitch) | awk '{print $1}')
    value=$(get_value chargingSwitch | awk '{print $2}')
    if [ -f $file ]; then
      chmod +w $file && echo $value > $file && sleep $(get_value chargingOnOffDelay) 2>/dev/null \
        || { print_cs_fails
          set_value chargingSwitch
          exit 1; }
      # applyOnPlug
      for file2 in $(get_value applyOnPlug); do
        value2=${file2##*:}
        file2=${file2%:*}
        [ -f $file2 ] && chmod +w $file2 && echo $value2 > $file2 || :
      done
    else
      print_invalid_cs
      set_value chargingSwitch
      exit 1
    fi
  else
    switch_loop on
  fi
  if [ -n "${1:-}" ]; then
    if [[ $1 == *% ]]; then
     print_ch_enabled_until $1
      echo
      until [ $(( $(cat $batt/capacity) $(get_value capacityOffset) )) -ge ${1%\%} ]; do
        sleep $(get_value loopDelay | cut -d, -f1)
      done
      [ "${2:-x}" == --nodisable ] || disable_charging
    elif [[ $1 == *[smh] ]]; then
      print_ch_enabled_for $1
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
      print_ch_enabled
    fi
  else
    print_ch_enabled
  fi
}


get_value() { sed -n "s|^$1=||p" ${2:-$config}; }


# acc <pause> <resume>
set_capacity() {
  local shutdown=$(get_value capacity | cut -d, -f1)
  local coolDown=$(get_value capacity | cut -d, -f2)
  set_value capacity $shutdown,$coolDown,$2-$1
}


switch_loop() {
  local file="" on="" off=""
  while IFS= read -r file; do
    if [ -f $(echo $file | awk '{print $1}') ]; then
      on=$(echo $file | awk '{print $2}')
      off=$(echo $file | awk '{print $3}')
      file=$(echo $file | awk '{print $1}')
      chmod +w $file && eval "echo \$$1" > $file 2>/dev/null && sleep $(get_value chargingOnOffDelay) || continue
      if [ $1 == off ] && ! grep -Eiq "${2:-dis|not}" $batt/status; then
        echo $on > $file 2>/dev/null || :
      elif [ $1 == on ] && grep -Eiq "${2:-dis|not}" $batt/status; then
        echo $on > $file 2>/dev/null || :
      else
        break
      fi
    fi
  done << EOF
$(grep -Ev '#|^$' ${modPath%/*}/switches)
EOF
}


set_charging_voltage() {

  local setVoltage=false
  local dVolt=${modPath%/*}/default_voltage
  local file=$(get_value maxChargingVoltage)
  local value=${file##*:}
  local oValue=""
  file=${file%:*}

  if echo ${1:-} | grep -q '^[34]' && [ $1 -ge 3500 ] && [ $1 -le 4350 ] ; then
    setVoltage=true
    value=$1
    [ -f ${file:-x} ] || v_ctrl_files_prompt $value
  elif echo ${1:-} | grep -q ':[34]' && [ ${1##*:} -ge 3500 ] && [ ${1##*:} -le 4350 ]; then
    setVoltage=true
    value=${1##*:}
    [[ $1 == */* ]] && file=$(echo ${1%:*}) || v_ctrl_files_prompt $value
  elif [ -z "${1:-}" ]; then
    # show current voltage
    if [ -f $dVolt ]; then
      file=$(awk '{print $1}' $dVolt)
      echo "$(grep -o '^....' $file)mV"
    else
      print_default
    fi
    return 0
  elif  echo ${1:-} | grep -q '^\-$'; then
    if [ -f $dVolt ]; then
      # restore default voltage
      file=$(awk '{print $1}' $dVolt)
      value=$(awk '{print $2}' $dVolt)
      chmod +w $file && echo $value > $file \
        && print_dvolt_restored && rm $dVolt
    else
      print_dvolt_already_set
    fi
    return 0
  elif [ ${1:-x} == : ]; then
    ls_voltage_ctrl_files
    return 0
  elif [[ ${1:-x} == a || ${1:-x} == apply ]]; then
    setVoltage=true
  else
    print_invalid_input $@
    print_accepted_volt
    return 1
  fi

  if $setVoltage; then
    if [ -f $file ]; then
      oValue=$value
      value=$(sed "s/^..../$value/" $file)
      [ -f $dVolt ] || echo "$file $(sed -n 1p $file)" > $dVolt
      if chmod +w $file && echo $value > $file 2>/dev/null && grep -q "^$oValue" $file; then
        [ x$(get_value maxChargingVoltage) == x$file:$oValue ] || set_value maxChargingVoltage $file:$oValue
        print_cvolt_set
      else
        print_cvolt_unsupported
        rm $dVolt
        return 1
      fi
    else
      print_no_such_file
      rm $dVolt
      return 1
    fi
  fi
}


ls_voltage_ctrl_files() {
  cat -v ${modPath%/*}/acc-power_supply-*.log \
    | grep -E '/BatterySenseVoltage$|/ChargerVoltage$|/ADC_Charger_Voltage$|/ISenseVoltage$|/batt_vol$|/InstatVolt$|/constant_charge_voltage$|/voltage_max$|/batt_tune_float_voltage$' \
    | sed -e 's|^.*power_supply/||' -e 's/$/\n/'
}


v_ctrl_files_prompt() {
  local file="" success=false
  local PS3="
$(print_choice_prompt)"
  print_supported_cvolt_files
  echo
  eval 'select file in $(ls_voltage_ctrl_files) $(print_exit); do
    echo
    [ ${file:-x} != $(print_exit) ] || exit 0
    set_charging_voltage $file:$1 && success=true || :
    if $success; then
      echo
      set_value maxChargingVoltage $file:$1
      print_cvolt_limit_set
      exit 0
    else
      echo
      v_ctrl_files_prompt $1
    fi
  done'
}


ls_charging_switches() {
  local file=""
  while IFS= read -r file; do
    [ ! -f $(echo $file | awk '{print $1}') ] || echo $file
  done << EOF
$(grep -Ev '#|^$' ${modPath%/*}/switches)
EOF
}


test_charging_switch() {

  local on=$(echo "$@" | awk '{print $2}')
  local off=$(echo "$@" | awk '{print $3}')
  local file=$(echo "$@" | awk '{print $1}')

  not_charging && enable_charging > /dev/null

  if not_charging; then
    print_unplugged
    $daemonWasUp && /sbin/accd
    exit 2
  fi

  if [ -n "${1:-}" ]; then

    chmod +w $file && echo $off > $file && sleep $(get_value chargingOnOffDelay)
    grep -iq not $batt/status && battIdleMode=true || battIdleMode=false

    if not_charging \
      && echo $on > $file \
      && sleep $(get_value chargingOnOffDelay) \
      && ! not_charging
    then
      print_file_works
      echo "- battIdleMode=$battIdleMode"
      return 0
    else
      print_file_fails
      echo $on > $file
      return 1
    fi

  else

    disable_charging > /dev/null

    if not_charging && enable_charging > /dev/null && ! not_charging; then
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
  echo
  # config backup
  if [ -d /data/media/0/?ndroid ]; then
    [ /data/media/0/.acc-config-backup.txt -nt $config ] \
      || install -m 0777 $config /data/media/0/.acc-config-backup.txt 2>/dev/null || :
  fi
  exit $exitCode
}


echo
umask 077
set -euo pipefail
trap exxit EXIT

modPath=/sbin/.acc/acc
config=/data/adb/acc-data/config.txt
defaultConfig=$modPath/default-config.txt

. $modPath/busybox.sh

readmeSuffix=""
device=$(getprop ro.product.device | grep .. || getprop ro.build.product)
log=${modPath%/*}/acc-${device}.log

# verbose
if [[ ${1:-x} == -*x* ]]; then
  shift
  exec 2>$log
  set -x
fi

batt=$(echo /sys/class/power_supply/*attery/capacity | awk '{print $1}' | sed 's|/capacity||')

# load default strings (English)
. $modPath/strings.sh

# load translations
if [[ $0 != *acc-en ]] && [ -f $modPath/strings_$(get_value language).sh ]; then
  . $modPath/strings_$(get_value language).sh
  readmeSuffix=_$(get_value language)
  [ -f ${config%/*}/info/README$readmeSuffix.md ] || readmeSuffix=""
fi

if [ ! -f $modPath/module.prop ]; then
  print_no_modpath
  exit 7
fi

mkdir -p ${config%/*}
cd /sys/class/power_supply/
[ -f $config ] || cp $modPath/default-config.txt $config


case ${1:-} in
  [0-9]*) set_capacity $@;;
  -c|--config) shift; edit $config $@;;

  -d|--disable)
    shift
    daemon stop > /dev/null || :
    set -eo pipefail
    disable_charging $@
  ;;

  -D|--daemon) shift; daemon $@;;

  -e|--enable)
    shift
    daemon stop > /dev/null || :
    set -eo pipefail
    enable_charging $@
  ;;

  -f|--force|--full)
    daemon stop > /dev/null && daemonWasUp=true || daemonWasUp=false
    set -eo pipefail
    print_ch_enabled_until ${2:-100}%
    (enable_charging ${2:-100}% --nodisable > /dev/null 2>&1
    ! $daemonWasUp || /sbin/.acc/acc/accd.sh &) &
  ;;

  -i|--info) sed s/POWER_SUPPLY_// $batt/uevent | sed "/^CAPACITY=/s/=.*/=$(( $(cat $batt/capacity) $(get_value capacityOffset) ))/";;

  -I|--lang)
    [ $(get_value language) == en ] && echo "- en (default, set)" \
      || echo "- en (default)"
    ls -1 $modPath/strings_*.sh \
      | sed -e 's/^.*strings_/- /' -e 's/.sh$//' -e "/$(get_value language)/s/$/ (set)/"
    print_set_lang
  ;;

  -l|--log)
    shift
    if [[ "${1:-x}" == -*e* ]]; then
      set +eo pipefail
      ls_charging_switches | grep -v '^$' > ${modPath%/*}/charging-ctrl-files.txt
      cd ${modPath%/*}
      ls_voltage_ctrl_files | grep -v '^$' > charging-voltage-ctrl-files.txt
      for file in /cache/magisk.log /data/cache/magisk.log; do
        [ -f $file ] && cp $file ./ && break
      done
      cp $config ${config%/*}/logs/* ./
      tar -c *.log *.txt magisk.log 2>/dev/null | bzip2 -9 > /data/media/0/acc-logs-$device.tar.bz2
      chmod 0777 /data/media/0/acc-logs-$device.tar.bz2
      rm *.txt magisk.log in*.log 2>/dev/null
      echo "(i) /sdcard/acc-logs-$device.tar.bz2"
    else
      if [[ "${1:-x}" == -*a* ]]; then
        shift
        edit $log $@
      else
        edit ${modPath%/*}/accd-*.log $@
      fi
    fi
  ;;

  -L|--logwatch) tail -F ${modPath%/*}/accd-*.log;;

  -p|--preset)
    shift
  ;;

  -P|--performance)
    print_quit
    sleep 1.5
    htop -p $(pgrep -f accd.sh)
  ;;

  -r|--readme) shift; edit ${config%/*}/info/README$readmeSuffix.md $@;;

  -R|--resetbs)
    dumpsys batterystats --reset > /dev/null 2>&1 || :
    rm /data/system/batterystats* 2>/dev/null || :
  ;;

  -s|--set) shift; set_values $@;;

  -t|--test)
    shift
    daemon > /dev/null && daemonWasUp=true || daemonWasUp=false
    set +eo pipefail
    pkill -f '/acc (-|--)[def]|/accd.sh'
    if [ -z "${1:-}" ]; then
      test_charging_switch
    elif [ $1 == -- ]; then
      while IFS= read -r switch; do
        [ -f $(echo "$switch" | awk '{print $1}') ] && echo && test_charging_switch $switch
        e=$?
        [ $e -eq 0 ] && exitCode=0
        [ -z "${exitCode:-}" ] && exitCode=$e
      done << EOF
$(grep -Ev '^#|^$' ${2:-${modPath%/*}/switches})
EOF
      echo
    else
      test_charging_switch $@
    fi
    exitCode_=$?
    [ -z "${exitCode:-}" ] && exitCode=$exitCode_
    $daemonWasUp && /sbin/accd
    [ $exitCode -eq 1 ] && (acc --log --export | grep -v '^$')
    exit $exitCode
  ;;

  -u|--upgrade)
    shift
    local reference="$(echo "$*" | sed -E 's/-c|--changelog|-f|--force|-n|--non-interactive| //g')"
    case ${reference:-x} in
      dev|master) :;;
      *) reference=master;;
    esac
    curl -Lo ${modPath%/*}/install-latest.sh https://raw.githubusercontent.com/VR-25/acc/$reference/install-latest.sh
    trap - EXIT
    set +euo pipefail
    installDir=$(readlink -f $modPath)
    installDir=${installDir%/*}
    . ${modPath%/*}/install-latest.sh $@ %$installDir%
  ;;

  -U|--uninstall)
    set +euo pipefail
    $modPath/uninstall.sh
  ;;

  -v|--voltage) shift; set_charging_voltage $@;;
  -V|--version) get_value versionCode $modPath/module.prop;;
  *) print_help;;

esac

exit 0
