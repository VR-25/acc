#!/system/bin/sh
# Workaround for EdXposed's service.sh bug

id=acc
domain=vr25
for f in /data/adb/modules/riru_edxposed_*/module.prop
do
  [ -f "$f" ] && {
    [ -f "${f%/*}/disable" ] && continue
    exec /data/adb/$domain/$id/service.sh
  }  
done
exit 0
