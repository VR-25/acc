#!/system/bin/sh
# /sbin/acca: ACC executable for front-ends (faster and more efficient than /sbin/acc)
# © 2020, VR25 (xda-developers)


daemon_ctrl() {
  case "${1-}" in
    start|restart)
      exec /sbin/accd $config
    ;;
    stop)
      set +euo pipefail 2>/dev/null
      pkill -f '/ac(c|ca) (-|--)[deft]|/accd\.sh'
      for count in 1 2 3 4 5; do
        sleep 1
        [ -z "$(pgrep -f '/ac(c|ca) (-|--)[deft]|/accd\.sh')" ] && break
      done
      pkill -9 -f '/ac(c|ca) (-|--)[deft]|/accd\.sh'
      exit $?
    ;;
    *)
      pgrep -f '/ac(c|ca) (-|--)[deft]|/accd\.sh' && exit 0 || exit 9
    ;;
  esac
}


set -euo pipefail 2>/dev/null || :
cd /sbin/.acc/acc/
export TMPDIR=${PWD%/*} verbose=false
. ./setup-busybox.sh

config=/data/adb/acc-data/config.txt
defaultConfig=$PWD/default-config.txt

mkdir -p ${config%/*}
[ -f $config ] || cp $defaultConfig $config

# config backup
! [ -d /data/media/0/?ndroid -a $config -nt /data/media/0/.acc-config-backup.txt ] \
  || cp -f $config /data/media/0/.acc-config-backup.txt

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
    cd /sys/class/power_supply/
    batt=$(echo *attery/capacity | cut -d ' ' -f 1 | sed 's|/capacity||')
    . /sbin/.acc/acc/batt-info.sh
    batt_info "${2-}"
    exit $?
  ;;


  # set multiple properties
  -s\ *=*|--set\ *=*)
    shift
    . $defaultConfig
    . $config
    export "$@"

    [ .${mcc-${max_charging_current-x}} == .x ] || {
      . ./set-ch-curr.sh
      set_ch_curr ${mcc:-${max_charging_current:--}} || :
    }

    [ .${mcv-${max_charging_voltage-x}} == .x ] || {
      . ./set-ch-volt.sh
      set_ch_volt ${mcv:-${max_charging_voltage:--}} || :
    }

    . ./write-config.sh
    exit $?
  ;;


  # print default config
  -s\ d*|-s\ --print-default*|--set\ d*|--set\ --print-default*|-sd*)
    [ $1 == -sd ] && shift || shift 2
    . $defaultConfig
    . ./print-config.sh | grep -E "${1:-...}"
    exit $?
  ;;

  # print current config
  -s\ p*|-s\ --print|-s\ --print\ *|--set\ p|--set\ --print|--set\ --print\ *|-sp*)
    [ $1 == -sp ] && shift || shift 2
    . $config
    . ./print-config.sh | grep -E "${1:-...}"
    exit $?
  ;;

esac


# other acc commands
set +euo pipefail 2>/dev/null
exec /sbin/acc $config "$@"
