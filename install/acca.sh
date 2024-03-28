#!/system/bin/sh
# acca: acc for front-ends (faster and more efficient than acc)
# Copyright 2020-2024, VR25
# License: GPLv3+


at() { :; }

online() { :; }


daemon_ctrl() {
  case "${1-}" in
    start|restart)
      exec $TMPDIR/accd $config
    ;;
    stop)
      . $execDir/release-lock.sh
      exit 0
    ;;
    *)
      flock -n 0 <>$TMPDIR/acc.lock && exit 9 || exit 0
    ;;
  esac
}


# extended test
tt() {
  eval "case \"$1\" in
    $2) return 0;;
  esac"
  return 1
}


set -eu

execDir=/data/adb/vr25/acc
dataDir=/data/adb/vr25/acc-data
config=$dataDir/config.txt
defaultConfig=$execDir/default-config.txt

export TMPDIR=/dev/.vr25/acc
export verbose=false

cd /sys/class/power_supply/
. $execDir/setup-busybox.sh

mkdir -p $dataDir

# custom config path
case "${1-}" in
  */*)
    [ -f $1 ] || cp $config $1
    config=$1
    shift
  ;;
esac


case "$@" in

  # check daemon status
  -D*|--daemon*)
    daemon_ctrl ${2-}
  ;;

  # print battery uevent data
  -i*|--info*)
    . $config
    . $execDir/batt-interface.sh
    . $execDir/batt-info.sh
    batt_info "${2-}"
    exit 0
  ;;


  # set multiple properties
  -s\ *=*|--set\ *=*)

    ${async:-false} || {
      async=true setsid $0 $config "$@" > /dev/null 2>&1 < /dev/null
      exit 0
    }

    set +o sh 2>/dev/null || :
    exec 4<>$0
    flock 0 <&4
    shift

    . $defaultConfig
    . $config

    export "$@"

    [ .${mcc-${max_charging_current-x}} = .x ] || {
      . $execDir/set-ch-curr.sh
      set_ch_curr ${mcc:-${max_charging_current:--}} || :
    }

    [ ".${mcv-${max_charging_voltage-x}}" = .x ] || {
      . $execDir/set-ch-volt.sh
      set_ch_volt "${mcv:-${max_charging_voltage:--}}" || :
    }

    . $execDir/write-config.sh
    exit 0
  ;;


  # print default config
  -s\ d*|-s\ --print-default*|--set\ d*|--set\ --print-default*|-sd*)
    [ $1 = -sd ] && shift || shift 2
    . $defaultConfig
    one="${1//,/|}"
    . $execDir/print-config.sh ns | grep -E "${one:-.}" | sed 's/^$//' || :
    exit 0
  ;;

  # print current config
  -s\ p*|-s\ --print|-s\ --print\ *|--set\ p|--set\ --print|--set\ --print\ *|-sp*)
    [ $1 = -sp ] && shift || shift 2
    . $config
    one="${1//,/|}"
    . $execDir/print-config.sh | grep -E "${one:-.}" | sed 's/^$//' || :
    exit 0
  ;;

esac


# other acc commands
set +eu
exec $TMPDIR/acc $config "$@"
