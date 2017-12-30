#!/system/bin/sh
# CS Service Ignitor
# VR25 @ XDA Developers


ModPath=${0%/*}
PersistDir="/data/media/cs"
config="$PersistDir/config"
OLD_PATH=$PATH

PATH="/sbin/.core/busybox:/dev/magisk/bin:$PATH"
set_prop() { sed -i "s|^$1=.*|$1=$2|g" "$config"; }

if [ -f $config ]; then
	set_prop pause_svc false
	set_prop auto_run true
fi

PATH=$OLD_PATH
(cs service) &
