##########################################################################################
#
# Magisk Module Template Config Script
# by topjohnwu
#
##########################################################################################
##########################################################################################
#
# Instructions:
#
# 1. Place your files into system folder (delete the placeholder file)
# 2. Fill in your module's info into module.prop
# 3. Configure the settings in this file (config.sh)
# 4. If you need boot scripts, add them into common/post-fs-data.sh or common/service.sh
# 5. Add your additional or modified system properties into common/system.prop
#
##########################################################################################

##########################################################################################
# Configs
##########################################################################################

# Set to true if you need to enable Magic Mount
# Most mods would like it to be enabled
AUTOMOUNT=true

# Set to true if you need to load system.prop
PROPFILE=false

# Set to true if you need post-fs-data script
POSTFSDATA=true

# Set to true if you need late_start service script
LATESTARTSERVICE=true

##########################################################################################
# Installation Message
##########################################################################################

# Set what you want to show when installing your mod

print_modname() {
  ui_print " "
  ui_print "$(i name) $(i version)"
  ui_print "$(i author)"
  ui_print " "
}

##########################################################################################
# Replace list
##########################################################################################

# List all directories you want to directly replace in the system
# Check the documentations for more info about how Magic Mount works, and why you need this

# This is an example
REPLACE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# Construct your own list here, it will override the example above
# !DO NOT! remove this if you don't need to replace anything, leave it empty as it is now
REPLACE="
"

##########################################################################################
# Permissions
##########################################################################################

set_permissions() {
  # Only some special files require specific permissions
  # The default permissions should be good enough for most cases

  # Here are some examples for the set_perm functions:

  # set_perm_recursive  <dirname>                <owner> <group> <dirpermission> <filepermission> <contexts> (default: u:object_r:system_file:s0)
  # set_perm_recursive  $MODPATH/system/lib       0       0       0755            0644

  # set_perm  <filename>                         <owner> <group> <permission> <contexts> (default: u:object_r:system_file:s0)
  # set_perm  $MODPATH/system/bin/app_process32   0       2000    0755         u:object_r:zygote_exec:s0
  # set_perm  $MODPATH/system/bin/dex2oat         0       2000    0755         u:object_r:dex2oat_exec:s0
  # set_perm  $MODPATH/system/lib/libart.so       0       0       0644

  # The following is default permissions, DO NOT remove
  set_perm_recursive  $MODPATH  0  0  0755  0644

  # Permissions for executables
  for f in $MODPATH/bin/* $MODPATH/system/*bin/* $MODPATH/*.sh; do
    [ -f "$f" ] && set_perm $f 0 0 0755
  done
}

##########################################################################################
# Custom Functions
##########################################################################################

# This file (config.sh) will be sourced by the main flash script after util_functions.sh
# If you need custom logic, please add them here as functions, and call these functions in
# update-binary. Refrain from adding code directly into update-binary, as it will make it
# difficult for you to migrate your modules to newer template versions.
# Make update-binary as clean as possible, try to only do function calls in it.


install_module() {

  umask 0
  set -euxo pipefail
  trap 'exxit $?' EXIT

  config=/data/media/0/$MODID/config.txt

  # magisk.img mount path
  if $BOOTMODE; then
    MOUNTPATH0=/sbin/.magisk/img
    [ -d $MOUNTPATH0 ] || MOUNTPATH0=/sbin/.core/img
    if [ ! -e $MOUNTPATH0 ]; then
      ui_print " "
      ui_print "(!) \$MOUNTPATH0 not found"
      ui_print " "
      exit 1
    fi
  else
    MOUNTPATH0=$MOUNTPATH
  fi

  curVer=$(grep_prop versionCode $MOUNTPATH0/$MODID/module.prop || :)
  [ -z "$curVer" ] && curVer=0

  if [ $curVer -eq $(i versionCode) ] && ! $BOOTMODE; then
    touch $MODPATH/disable
    ui_print " "
    ui_print "(i) Module disabled"
    ui_print " "
    set +euo pipefail
    unmount_magisk_img
    $BOOTMODE || recovery_cleanup
    set -u
    rm -rf $TMPDIR
    exit 0
  fi

  # cleanup & create module paths
  cleanup
  rm -rf $MODPATH 2>/dev/null || :
  mkdir -p ${config%/*}/info ${config%/*}/logs
  [ -d /system/xbin ] && mkdir -p $MODPATH/system/xbin \
    || mkdir -p $MODPATH/system/bin

  # remove legacy (mcs)
  rm -rf /data/media/mcs 2>/dev/null || :
  touch $MOUNTPATH0/mcs/remove 2>/dev/null || :

  # extract module files
  ui_print "- Extracting module files"
  cd $INSTALLER
  unzip -o "$ZIP" -d ./ 1>&2
  mv common/$MODID $MODPATH/system/*bin/
  mv common/* $MODPATH/
  rm $MODPATH/addon.d.sh
  cp $MODPATH/service.sh $(echo -n $MODPATH/system/*bin)/accd
  sed -i '\|/dev/|s|^|#|' $MODPATH/system/*bin/accd
  $POSTFSDATA && POSTFSDATA=false \
    && cp -l $MODPATH/service.sh $MODPATH/post-fs-data.sh || :
  $LATESTARTSERVICE && LATESTARTSERVICE=false \
    || rm $MODPATH/service.sh
  mv -f License* README* ${config%/*}/info/
  [ -f $config ] || cp $MODPATH/default_config.txt $config

  # install acc app
  mkdir -p $MODPATH/system/priv-app/acc
  mv bin/acc*.apk $MODPATH/system/priv-app/acc/acc.apk 2>/dev/null || :
  ls $MODPATH/system/priv-app/acc 2>/dev/null | grep .. 2>/dev/null 1>&2 \
    || rm -rf $MODPATH/system/priv-app

  # prepare djs installation
  set +e
  if [ ! -f $MOUNTPATH0/djs/module.prop ] || [ $(grep_prop versionCode $MOUNTPATH0/djs/module.prop) -lt \
    $(echo bin/djs*.zip | sed -e 's|bin/djs-||' -e 's/.zip//') ]
  then
    mkdir -p /dev/djs_tmp
    mv -f bin/djs*.zip /dev/djs_tmp/djs.zip
    unzip -o /dev/djs_tmp/djs.zip META-INF/com/google/android/update-binary -d /dev/djs_tmp/ 1>&2
  fi

  set +uxo pipefail
}


install_system() {

  umask 0
  set -euxo pipefail
  trap 'exxit $?' EXIT

  local modId=acc
  local modPath=/system/etc/$modId
  config=/data/media/0/$modId/config.txt

  grep_prop() {
    local REGEX="s/^$1=//p"
    shift
    local FILES=$@
    [ -z "$FILES" ] && FILES='/system/build.prop'
    sed -n "$REGEX" $FILES 2>/dev/null | head -n 1
  }

  set_perm() {
    chown 0:0 "$@"
    chmod 0755 "$@"
    chcon u:object_r:system_file:s0 "$@" 2>/dev/null || :
  }

  mount -o rw /system 2>/dev/null || mount -o remount,rw /system
  curVer=$(grep_prop versionCode $modPath/module.prop || :)
  [ -z "$curVer" ] && curVer=0

  # set OUTFD
  if [ -z "${OUTFD:-}" ] || readlink /proc/$$/fd/$OUTFD | grep -q /tmp; then
    for FD in `ls /proc/$$/fd`; do
      if readlink /proc/$$/fd/$FD | grep -q pipe; then
        if ps | grep -v grep | grep -q " 3 $FD "; then
          OUTFD=$FD
          break
        fi
      fi
    done
  fi

  ui_print() { echo -e "ui_print $1\nui_print" >> /proc/self/fd/$OUTFD; }

  print_modname

  # uninstall
  if [ $curVer -eq $(i versionCode) ]; then
    ui_print "(i) Uninstalling"
    rm -rf /system/etc/init.d/$modId* \
           /system/etc/$modId \
           /system/addon.d/$modId* \
           /system/*bin/$modId* 2>/dev/null || :
    ui_print " "
  else

    # cleanup & create paths
    cleanup
    mkdir -p $modPath
    mkdir -p ${config%/*}/info ${config%/*}/logs

    # remove legacy (mcs)
    rm -rf /system/etc/init.d/mcs* \
           /system/etc/mcs \
           /system/addon.d/mcs* \
           /system/*bin/mcs* \
           /data/media/mcs 2>/dev/null || :

    # install
    ui_print "- Installing"
    cd $INSTALLER
    unzip -o "$ZIP" -d ./ >&2
    mv -f common/service.sh $modPath/autorun.sh
    set_perm $modPath/autorun.sh
    if [ -d /system/xbin ]; then
      mv -f common/$modId /system/xbin/
      cp -f $modPath/autorun.sh /system/xbin/accd
    else
      mv -f common/$modId /system/bin/
      cp -f $modPath/autorun.sh /system/bin/accd
    fi
    sed -i '\|/dev/|s|^|#|' /system/bin/accd
    set_perm /system/*bin/$modId*
    [ -d /system/etc/init.d ] && { $LATESTARTSERVICE || $POSTFSDATA; } \
      && cp -afl $modPath/autorun.sh /system/etc/init.d/$modId || :
    if [ -d /system/addon.d ]; then
      mv -f common/addon.d.sh /system/addon.d/$modId.sh
      set_perm /system/addon.d/$modId.sh
    fi
    mv -f common/* module.prop $modPath/
    set_perm $modPath/accd
    mv -f License* README* ${config%/*}/info/
    [ -f $config ] || cp $modPath/default_config.txt $config

    set +euxo pipefail
    MAGISK_VER=0
    version_info
  fi
  exit 0
}


gen_ps_log() {
  date
  echo "versionCode=$(i versionCode)"
  echo; echo
  gather_ps_data /sys
  gather_ps_data /proc
  echo
  getprop | grep product
  echo
  getprop | grep version
} > ${config%/*}/logs/acc-power_supply-$(getprop ro.product.device | grep .. || getprop ro.build.product).log


gather_ps_data() {
  local target="" target2=""
  for target in $(ls -1 $1 | grep -Ev '^[0-9]|^block$|^dev$|^fs$|^ram$'); do
    if [ -f $1/$target ]; then
      if echo $1/$target | grep -Eq 'batt|ch.*rg|power_supply'; then
        echo $1/$target
        sed 's/^/  /' $1/$target 2>/dev/null || :
        echo
      fi
    elif [ -d $1/$target ]; then
      for target2 in $(find $1/$target \( \( -type f -o -type d \) -a \( -ipath '*batt*' -o -ipath '*ch*rg*' -o -ipath '*power_supply*' \) \) -print 2>/dev/null || :); do
        if [ -f $target2 ]; then
          echo $target2
          sed 's/^/  /' $target2 2>/dev/null || :
          echo
        fi
      done
    fi
  done
}


exxit() {
  set +euxo pipefail
  if [ $1 -ne 0 ]; then
    unmount_magisk_img
    $BOOTMODE || recovery_cleanup
    set -u
    rm -rf $TMPDIR
  fi 1>/dev/null 2>&1
  rm -rf /dev/djs_tmp 2>/dev/null
  echo
  echo "***EXIT $1***"
  echo
  exit $1
} 1>&2


# module.prop reader
i() {
  local p=$INSTALLER/module.prop
  [ -f $p ] || p=$MODPATH/module.prop
  grep_prop $1 $p
}


cleanup() {

  local dConfig=$INSTALLER/common/default_config.txt

  ui_print "- [Background] Generating ${config%/*}/logs/acc-power_supply-$(getprop ro.product.device | grep .. || getprop ro.build.product).log"
  (gen_ps_log) &

  if [ $curVer -lt 201901090 ] || [ $curVer -gt $(i versionCode) ]; then
    rm -rf /data/media/0/acc 2>/dev/null || :

  else
    [ -f $config ] || return 0
    cd $INSTALLER
    unzip -o "$ZIP" common/default_config.txt -d ./ >&2
    if [ $curVer -lt 201902260 ]; then
      sed -i -e "\|onBoot=|s| # .*|$(sed -n 's|.*onBoot=.* # | # |p' $dConfig)|" \
        -e "\|onBootExit=|s| # .*|$(sed -n 's|.*onBootExit=.* # | # |p' $dConfig)|" \
        -e "\|onPlugged=|s| # .*|$(sed -n 's|.*onPlugged=.* # | # |p' $dConfig)|" \
        -e "s|dly high va|dly high temperature va|" \
        -e "\|maxLogSize=10|s|10|5|" $config
      if ! grep -q voltFile $config; then
        echo >> $config
        grep voltFile $dConfig >> $config
      fi
      if ! grep -q selfUpgrade $config; then
        echo >> $config
        grep selfUpgrade $dConfig >> $config
      fi
    fi
    if [ $curVer -lt 201903010 ]; then
      sed -i "s|voltFile=.*|$(grep cVolt $dConfig)|" $config
    fi
    if [ $curVer -lt 201903030 ]; then
      if ! grep -q rebootOnPause $config; then
        echo >> $config
        grep rebootOnPause $dConfig >> $config
      fi
      sed -i "\|selfUpgrade=|s| # .*|$(sed -n 's|.*selfUpgrade=.* # | # |p' $dConfig)|" $config
    fi
  fi
}



version_info() {
  local line=""
  local println=false

  # a note on untested Magisk versions
  if [ ${MAGISK_VER/.} -gt 181 ]; then
    ui_print " "
    ui_print "  (!) This Magisk version hasn't been tested by @VR25!"
    ui_print "    - If you come across any issue, please report."
  fi

  ui_print " "
  ui_print "  WHAT'S NEW"
  cat ${config%/*}/info/README.md | while read line; do
    echo "$line" | grep -q '\*\*.*\(.*\)\*\*' && println=true
    $println && echo "$line" | grep -q '^$' && break
    $println && line="$(echo "    $line" | grep -v '\*\*.*\(.*\)\*\*')" && ui_print "$line"
  done
  ui_print " "

  ui_print "  LINKS"
  ui_print "    - ACC App: github.com/MatteCarra/AccA/"
  ui_print "    - Battery University: batteryuniversity.com/learn/article/how_to_prolong_lithium_based_batteries/"
  ui_print "    - Daily Job Scheduler: github.com/Magisk-Modules-Repo/djs/"
  ui_print "    - Donate: paypal.me/vr25xda/"
  ui_print "    - Facebook page: facebook.com/VR25-at-xda-developers-258150974794782/"
  ui_print "    - Git repository: github.com/Magisk-Modules-Repo/acc/"
  ui_print "    - Telegram channel: t.me/vr25_xda/"
  ui_print "    - Telegram group: t.me/acc_magisk/"
  ui_print "    - Telegram profile: t.me/vr25xda/"
  ui_print "    - XDA thread: forum.xda-developers.com/apps/magisk/module-magic-charging-switch-cs-v2017-9-t3668427/"
  ui_print " "

  ui_print "(i) Important info: https://bit.ly/2TRqRz0"
  ui_print ""

  # install djs
  if [ -z "$modPath" ] && [ -d /dev/djs_tmp ]; then
    ui_print " "
    ui_print " "
    sh /dev/djs_tmp/META-INF/com/google/android/update-binary \
      dummy $OUTFD /dev/djs_tmp/djs.zip
  fi

  wait # until power supply log is fully generated
}


#acc --daemon stop 2>/dev/null | grep stopped | sed '\|stopped|s|^|\n|'
