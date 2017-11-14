#!/system/bin/sh
# cs service

mod_dir=${0%/*}
grep -q true $mod_dir/.config/cs 2>/dev/null || exit 0
rm $mod_dir/.tmp/_ 2>/dev/null
[ -d $mod_dir/.tmp ] || mkdir $mod_dir/.tmp
echo "$(date)" > $mod_dir/.tmp/cs_service_run.log
cs auto