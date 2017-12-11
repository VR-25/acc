#!/system/bin/sh
# CS Service Ignitor
# VR25 @ XDA Developers

ModPath=${0%/*}
OLD_PATH=$PATH
PATH=$PATH:/sbin/.core/busybox:/dev/magisk/bin
export service_is_running=true

persist_dir=/data/media/cs
{ rm $persist_dir/pause_service
mkdir $persist_dir; } 2>/dev/null
touch $persist_dir/auto_run

PATH=$OLD_PATH
cs service &