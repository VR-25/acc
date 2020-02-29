#!/system/bin/sh
# /sbin/acca: ACC executable for front-ends (more efficiency than /sbin/acc)
# Copyright (c) 2020, VR25 (xda-developers)


export verbose=false
set -euo pipefail 2>/dev/null || :
. /sbin/.acc/acc/setup-busybox.sh


case ${1-} in

  -D|--daemon)
    [ -n "${2-}" ] || { pgrep -f '/ac(c|ca) (-|--)[def]|/accd\.sh' && exit 0 || exit 8; }
  ;;

  -i|--info)
    cd /sys/class/power_supply/
    batt=$(echo *attery/capacity | cut -d ' ' -f 1 | sed 's|/capacity||')
    . /sbin/.acc/acc/batt-info.sh
    batt_info "${2-}"
    exit $?
  ;;

esac


# other acc commands
set +euo pipefail 2>/dev/null || :
. /sbin/.acc/acc/acc.sh "$@"
