#!/system/bin/sh
# cs service

mod_path=/magisk/cs
persist_dir=/data/media/cs

if [ ! -d $mod_dir ]; then
	rm -rf $persist_dir /magisk/zzz-cs-service
	exit 0
fi

rm $persist_dir/pause_service 2>/dev/null
[ -d $persist_dir ] || mkdir $persist_dir
echo "$(date)" > $persist_dir/service_run.log
cs auto