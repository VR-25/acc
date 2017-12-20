#!/system/bin/sh
# CS Service Ignitor
# VR25 @ XDA Developers

ModPath=${0%/*}
OLD_PATH=$PATH
PATH=$PATH:/sbin/.core/busybox:/dev/magisk/bin
PersistDir=/data/media/cs
{ rm $PersistDir/pause_service
mkdir $PersistDir; } 2>/dev/null
touch $PersistDir/auto_run
export service_is_running=true
PATH=$OLD_PATH
cs service &