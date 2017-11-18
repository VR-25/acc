#!/system/bin/sh
# cs service

mod_path=/magisk/cs
persist_dir=/data/media/cs
rm $persist_dir/pause_service 2>/dev/null
[ -d $persist_dir ] || mkdir $persist_dir
echo "$(date)" > $persist_dir/service_run.log
cs auto