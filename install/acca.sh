#!/system/bin/sh
# acca: acc for front-ends (faster and more efficient than acc)
# Copyright 2020-2023, VR25
# License: GPLv3+


at() { :; }


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


src_cfg() {
  /system/bin/sh -n $config 2>/dev/null || cat $execDir/default-config.txt > $config
  . $config
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
config=/data/adb/vr25/acc-data/config.txt
dataDir=/data/adb/vr25/acc-data
defaultConfig=$execDir/default-config.txt
TMPDIR=/dev/.vr25/acc
verbose=false

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

export config execDir TMPDIR verbose


case "$@" in

  # check daemon status
  -D*|--daemon*)
    daemon_ctrl ${2-}
  ;;

  # print battery uevent data
  -i*|--info*)
    src_cfg
    . $execDir/batt-interface.sh
    . $execDir/batt-info.sh
    batt_info "${2-}" | sed 's/=Idle$/=Not charging/' #legacy, AccA
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
    src_cfg

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
    . $execDir/print-config.sh | grep -E "${1:-.}" | sed 's/^$//' || :
    exit 0
  ;;

  # print current config
  -s\ p*|-s\ --print|-s\ --print\ *|--set\ p|--set\ --print|--set\ --print\ *|-sp*)
    [ $1 = -sp ] && shift || shift 2
    src_cfg
    . $execDir/print-config.sh | grep -E "${1:-.}" | sed 's/^$//' || :
    exit 0
  ;;

esac


# other acc commands
set +eu
exec $TMPDIR/acc $config "$@"
