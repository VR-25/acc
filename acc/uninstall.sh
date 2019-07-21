#!/system/bin/sh
[ -f $PWD/${0##*/} ] && modPath=$PWD || modPath=${0%/*}
. $modPath/busybox.sh
pgrep -f '/acc (-|--)[def]|/accd.sh' | xargs kill 2>/dev/null
set -e
rm -rf $(readlink -f $modPath)
