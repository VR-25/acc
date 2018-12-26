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
POSTFSDATA=false

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

  umask 000
  set -euxo pipefail
  trap debug_exit EXIT

  local config=/data/media/0/$MODID/config.txt

  # magisk.img mount path
  if $BOOTMODE; then
    MOUNTPATH0=/sbin/.magisk/img
    [ -e $MOUNTPATH0 ] || MOUNTPATH0=/sbin/.core/img
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
  unzip -o "$ZIP" -x common/addon.d.sh -d ./ >&2
  mv common/$MODID $MODPATH/system/*bin/
  mv common/* $MODPATH/
  rm $MODPATH/addon.d.sh
  cp -f $MODPATH/service.sh $(echo -n $MODPATH/system/*bin)/accd
  $LATESTARTSERVICE && LATESTARTSERVICE=false \
    || rm $MODPATH/service.sh
  mv -f License* README* ${config%/*}/info/
  [ -f $config ] || cp $MODPATH/default_config.txt $config

  set +euxo pipefail
  debug
}


install_system() {

  umask 000
  set -euxo pipefail
  trap debug_exit EXIT

  local modId=acc
  local modPath=/system/etc/$modId
  local config=/data/media/0/$modId/config.txt

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
  }

  mount -o rw /system 2>/dev/null || mount -o remount,rw /system
  curVer=$(grep_prop versionCode $modPath/module.prop || :)
  [ -z "$curVer" ] && curVer=0

  # set OUTFD
  if [ -z $OUTFD ] || readlink /proc/$$/fd/$OUTFD | grep -q /tmp; then
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
      ln -sf $modPath/autorun.sh /system/xbin/accd
    else
      mv -f common/$modId /system/bin/
      ln -sf $modPath/autorun.sh /system/bin/accd
    fi
    set_perm /system/*bin/$modId
    [ -e /system/etc/init.d ] && $LATESTARTSERVICE \ && ln -sf $modPath/autorun.sh /system/etc/init.d/$modId || :
    if [ -e /system/addon.d ]; then
      mv -f common/addon.d.sh /system/addon.d/$modId.sh
      set_perm /system/addon.d/$modId.sh
    fi
    mv -f common/* module.prop $modPath/
    set_perm $modPath/accd
    mv -f License* README* ${config%/*}/info/
    [ -f $config ] || cp $modPath/default_config.txt $config

    set +euxo pipefail
    debug
    MAGISK_VER=0
    version_info
  fi
  exit 0
}


debug() {
  local d="" f=""
  date
  echo versionCode=$(i versionCode)
  echo; echo; echo
  for d in /sys/class/power_supply/*; do
    for f in $d/*; do
      if [ -f $f ]; then
        echo $f
        cat $f | sed 's/^/  /'
        echo
      fi
    done
    echo; echo
  done 2>/dev/null
  getprop | grep product
  echo; echo; echo
  getprop | grep version
} >${config%/*}/logs/acc-power_supply-$(getprop ro.product.device | grep . || getprop ro.build.product).log


debug_exit() {
  local exitCode=$?
  echo -e "\n***EXIT $exitCode***\n"
  set +euxo pipefail
  set
  echo
  echo "SELinux status: $(getenforce 2>/dev/null || sestatus 2>/dev/null)" \
    | sed 's/En/en/;s/Pe/pe/'
  if [ $e -ne 0 ]; then
    unmount_magisk_img
    $BOOTMODE || recovery_cleanup
    set -u
    rm -rf $TMPDIR
  fi 1>/dev/null 2>&1
  echo
  exit $exitCode
} 1>&2


# module.prop reader
i() {
  local p=$INSTALLER/module.prop
  [ -f $p ] || p=$MODPATH/module.prop
  grep_prop $1 $p
}


cleanup() {
  if [ -e $config ]; then
    if [ $curVer -lt 201812260 ]; then
      rm ${config%/*}/logs/acc-debug* 2>/dev/null || :
      sed -i s/misc/onBoot/g $config
      sed -i s/exitMisc/onBootExit/g $config
      unzip -o "$ZIP" common/default_config.txt -d $INSTALLER >&2
      sed -i "\|onBoot|s|#.*|$(sed -n 's:onBoot=.[^#]*::p' $INSTALLER/common/default_config.txt)|" $config
      sed -i "\|onBootExit|s|#.*|$(sed -n 's:onBootExit=.[^#]*::p' $INSTALLER/common/default_config.txt)|" $config
      if ! grep -q onPlugged $config; then
        unzip -o "$ZIP" common/default_config.txt -d $INSTALLER >&2
        echo >>$config
        grep 'onPlugged=' $INSTALLER/common/default_config.txt >>$config
      fi
    fi
    if [ $curVer -lt 201812180 ]; then
      sed -i /alwaysOverwrite/d $config 2>/dev/null || :
      sed -i "s|^switch=[^#]*|switch= |" $config 2>/dev/null || :
    fi
  fi
  if [ $curVer -lt 201812100 ] || [ $curVer -gt $(i versionCode) ]; then
    rm -rf /data/media/0/acc 2>/dev/null || :
  fi
}


version_info() {

  local c="" whatsNew="- [accd] Fixed \"not autostarting if data is encrypted\""

  set -euo pipefail

  # a note on untested Magisk versions
  if [ ${MAGISK_VER/.} -gt 180 ]; then
    ui_print " "
    ui_print "  (i) NOTE: this Magisk version hasn't been tested by @VR25!"
    ui_print "    - If you come across any issue, please report."
  fi

  ui_print " "
  ui_print "  WHAT'S NEW"
  echo "$whatsNew" | \
    while read c; do
      ui_print "    $c"
    done
  ui_print " "

  ui_print "  LINKS"
  ui_print "    - Battery University: batteryuniversity.com/learn/article/how_to_prolong_lithium_based_batteries/"
  ui_print "    - Facebook page: facebook.com/VR25-at-xda-developers-258150974794782/"
  ui_print "    - Git repository: github.com/Magisk-Modules-Repo/acc/"
  ui_print "    - Telegram channel: t.me/vr25_xda/"
  ui_print "    - Telegram profile: t.me/vr25xda/"
  ui_print "    - XDA thread: forum.xda-developers.com/apps/magisk/module-magic-charging-switch-cs-v2017-9-t3668427/"
  ui_print " "
}
