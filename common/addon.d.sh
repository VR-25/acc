#!/sbin/sh
# Preserves acc across ROM updates
# Based on 50-cm.s

umask 000
modId=acc
. /tmp/backuptool.functions

list_files() {
cat <<EOF
bin/$modId
etc/$modId/accd
etc/$modId/autorun.sh
etc/$modId/default_config.txt
etc/$modId/module.prop
etc/$modId/switches.txt
xbin/$modId
EOF
}

case "$1" in
  backup)
    list_files | while read FILE DUMMY; do
      backup_file $S/"$FILE"
    done
  ;;
  restore)
    list_files | while read FILE REPLACEMENT; do
      R=""
      [ -n "$REPLACEMENT" ] && R="$S/$REPLACEMENT"
      [ -f "$C/$S/$FILE" ] && restore_file $S/"$FILE" "$R"
    done
  ;;
  pre-backup)
    # Stub
  ;;
  post-backup)
    # Stub
  ;;
  pre-restore)
    # Stub
  ;;
  post-restore)
    # set ownership & permissions
    for executable in /system/*bin/$modId /system/etc/$modId/$modId* /system/etc/autorun.sh
    do
      if [ -f $executable ]; then
        chown 0:0 $executable
        chmod 0755 $executable
      fi
    done
    # recreate symlinks
    [ -d /system/etc/init.d ] && ln -sf /system/etc/$modId/autorun.sh /system/etc/init.d/$modId
    if [ -d /system/xbin ]; then
      ln -sf $modPath/autorun.sh /system/xbin/accd
    else
      ln -sf $modPath/autorun.sh /system/bin/accd
    fi
  ;;
esac
 