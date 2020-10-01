#!/system/bin/sh
# Workaround for EdXposed's service.sh bug

id=acc
ls -d /data/adb/modules/riru_edxposed_* > /dev/null 2>&1 \
  && exec /data/adb/vr25/$id/service.sh
exit 0
