#!/system/bin/sh
# CS Service Ignitor
# VR25 @ XDA Developers

ModPath=${0%/*}
OLD_PATH=$PATH
PATH=$PATH:/sbin/.core/busybox:/dev/magisk/bin
persist_dir=/data/media/cs

# Exit if no config is found
if [ -f $persist_dir/config ] || [ -f $persist_dir/manual_ctrl ]; then
	:
else
	exit 0
fi

{ rm $persist_dir/pause_service
mkdir $persist_dir; } 2>/dev/null
touch $persist_dir/auto_run
export service_is_running=true
PATH=$OLD_PATH
cs service &