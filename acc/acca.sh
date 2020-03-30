#!/system/bin/sh
# /sbin/acca: ACC executable for front-ends (more efficient than /sbin/acc)
# Copyright (c) 2020, VR25 (xda-developers)


set -euo pipefail 2>/dev/null || :
cd /sbin/.acc/acc/
. ./setup-busybox.sh

config=/data/adb/acc-data/config.txt
defaultConfig=$PWD/default-config.txt

mkdir -p ${config%/*}
[ -f $config ] || cp $defaultConfig $config

# config backup
[ ! -d /data/media/0/?ndroid ] || {
  [ /data/media/0/.acc-config-backup.txt -nt $config ] \
    || install -m 777 $config \
      /data/media/0/.acc-config-backup.txt 2>/dev/null || :
}

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
  -D|--daemon)
    pgrep -f '/ac(c|ca) (-|--)(calibrate|[Cdef])|/accd\.sh' && exit 0 || exit 8
  ;;

  # print battery uevent data
  -i|--info*)
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
    TMPDIR=${PWD%/*}
    . ./write-config.sh
    exit $?
  ;;

  # print default config
  -s\ d|-s\ --print-default|--set\ d|--set\ --print-default)
    . $defaultConfig
    . ./print-config.sh | grep -E "${3:-.}"
    exit $?
  ;;

  # print current config
  -s\ p|-s\ --print|--set\ p|--set\ --print)
    . $config
    . ./print-config.sh | grep -E "${3:-.}"
    exit $?
  ;;

esac


# other acc commands
set +euo pipefail 2>/dev/null || :
export verbose=false
/sbin/acc $config "$@"
