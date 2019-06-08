########################################################################################################
#
# Magisk Module Installer Script
#
##########################################################################################
##########################################################################################
#
# Instructions:
#
# 1. Place your files into system folder (delete the placeholder file)
# 2. Fill in your module's info into module.prop
# 3. Configure and implement callbacks in this file
# 4. If you need boot scripts, add them into common/post-fs-data.sh or common/service.sh
# 5. Add your additional or modified system properties into common/system.prop
#
##########################################################################################

##########################################################################################
# Config Flags
##########################################################################################

# Set to true if you do *NOT* want Magisk to mount
# any files for you. Most modules would NOT want
# to set this flag to true
SKIPMOUNT=true

# Set to true if you need to load system.prop
PROPFILE=false

# Set to true if you need post-fs-data script
POSTFSDATA=false

# Set to true if you need late_start service script
LATESTARTSERVICE=false

##########################################################################################
# Replace list
##########################################################################################

# List all directories you want to directly replace in the system
# Check the documentations for more info why you would need this

# Construct your list in the following format
# This is an example
REPLACE_EXAMPLE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# Construct your own list here
REPLACE="
"

##########################################################################################
#
# Function Callbacks
#
# The following functions will be called by the installation framework.
# You do not have the ability to modify update-binary, the only way you can customize
# installation is through implementing these functions.
#
# When running your callbacks, the installation framework will make sure the Magisk
# internal busybox path is *PREPENDED* to PATH, so all common commands shall exist.
# Also, it will make sure /data, /system, and /vendor is properly mounted.
#
##########################################################################################
##########################################################################################
#
# The installation framework will export some variables and functions.
# You should use these variables and functions for installation.
#
# ! DO NOT use any Magisk internal paths as those are NOT public API.
# ! DO NOT use other functions in util_functions.sh as they are NOT public API.
# ! Non public APIs are not guranteed to maintain compatibility between releases.
#
# Available variables:
#
# MAGISK_VER (string): the version string of current installed Magisk
# MAGISK_VER_CODE (int): the version code of current installed Magisk
# BOOTMODE (bool): true if the module is currently installing in Magisk Manager
# MODPATH (path): the path where your module files should be installed
# TMPDIR (path): a place where you can temporarily store files
# ZIPFILE (path): your module's installation zip
# ARCH (string): the architecture of the device. Value is either arm, arm64, x86, or x64
# IS64BIT (bool): true if $ARCH is either arm64 or x64
# API (int): the API level (Android version) of the device
#
# Availible functions:
#
# ui_print <msg>
#     print <msg> to console
#     Avoid using 'echo' as it will not display in custom recovery's console
#
# abort <msg>
#     print error message <msg> to console and terminate installation
#     Avoid using 'exit' as it will skip the termination cleanup steps
#
# set_perm <target> <owner> <group> <permission> [context]
#     if [context] is empty, it will default to "u:object_r:system_file:s0"
#     this function is a shorthand for the following commands
#       chown owner.group target
#       chmod permission target
#       chcon context target
#
# set_perm_recursive <directory> <owner> <group> <dirpermission> <filepermission> [context]
#     if [context] is empty, it will default to "u:object_r:system_file:s0"
#     for all files in <directory>, it will call:
#       set_perm file owner group filepermission context
#     for all directories in <directory> (including itself), it will call:
#       set_perm dir owner group dirpermission context
#
##########################################################################################
##########################################################################################
# If you need boot scripts, DO NOT use general boot scripts (post-fs-data.d/service.d)
# ONLY use module scripts as it respects the module status (remove/disable) and is
# guaranteed to maintain the same behavior in future Magisk releases.
# Enable boot scripts by setting the flags in the config section above.
##########################################################################################

print() { grep_prop $1 $TMPDIR/module.prop; }

author=$(print author)
name=$(print name)
version=$(print version)
versionCode=$(print versionCode)

unset -f print

# Set what you want to display when installing your module

print_modname() {
  ui_print " "
  ui_print "$name $version"
  ui_print "Copyright (C) 2017-2019, $author"
  ui_print "License: GPLv3+"
  ui_print " "
}

# Copy/extract your module files into $MODPATH in on_install.

on_install() {
  # The following is the default implementation: extract $ZIPFILE/system to $MODPATH
  # Extend/change the logic to whatever you want
  #ui_print "- Extracting module files"
  #unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2

  $BOOTMODE && pgrep -f "/$MODID.sh -?[edf]|/${MODID}d.sh$" | xargs kill -9 2>/dev/null
  set -euxo pipefail
  trap 'exxit $?' EXIT

  config=/data/media/0/$MODID/config.txt
  local configVer=$(sed -n 's|^versionCode=||p' $config 2>/dev/null || :)

  # extract module files
  ui_print "- Extracting module files"
  unzip -o "$ZIPFILE" "$MODID/*" -d ${MODPATH%/*}/ >&2
  ln $MODPATH/service.sh $MODPATH/post-fs-data.sh
  mkdir -p ${config%/*}/info
  unzip -o "$ZIPFILE" '*.md' -d ${config%/*}/info/ >&2

  # patch/upgrade config
  local newConfigVer=$(sed -n 's|^versionCode=||p' $MODPATH/config.txt)
  if [ -f $config ]; then
    if [ ${configVer:-0} -lt 201905110 ] || [ ${configVer:-0} -gt $newConfigVer ]; then
      rm $config
    else
      [ $configVer -lt 201905111 ] \
        && sed -i -e '/CapacityOffset/s/C/c/' -e '/^versionCode=/s/=.*/=201905111/' $config
      [ $configVer -lt 201905130 ] \
        && sed -i -e '/^capacitySync=/s/true/false/' -e '/^versionCode=/s/=.*/=201905130/' $config
      if [ $configVer -lt 201906020 ]; then
        echo >> $config
        grep rebootOnUnplug $MODPATH/config.txt >> $config
        echo >> $config
        grep "toggling interval" $MODPATH/config.txt >> $config
        grep chargingOnOffDelay $MODPATH/config.txt >> $config
        sed -i '/^versionCode=/s/=.*/=201906020/' $config
      fi
      if [ $configVer -lt 201906050 ]; then
        echo >> $config
        grep language $MODPATH/config.txt >> $config
        sed -i '/^versionCode=/s/=.*/=201906050/' $config
      fi
    fi
  fi

  set +euxo pipefail
  version_info
}

# Only some special files require specific permissions
# This function will be called after on_install is done
# The default permissions should be good enough for most cases

set_permissions() {
  local file=""
  # The following is the default rule, DO NOT remove
  set_perm_recursive $MODPATH 0 0 0755 0644

  # Here are some examples:
  # set_perm_recursive  $MODPATH/system/lib       0     0       0755      0644
  # set_perm  $MODPATH/system/bin/app_process32   0     2000    0755      u:object_r:zygote_exec:s0
  # set_perm  $MODPATH/system/bin/dex2oat         0     2000    0755      u:object_r:dex2oat_exec:s0
  # set_perm  $MODPATH/system/lib/libart.so       0     0       0644

  # permissions for executables
  for file in $MODPATH/*.sh; do
    [ -f $file ] && set_perm $file  0  0  0755
  done

  # finishing touches
  chmod -R 0777 ${config%/*}
  $BOOTMODE && $MODPATH/service.sh install
}

# You can add more functions to assist your custom script code

cancel() {
  imageless_magisk || unmount_magisk_image
  abort "$1"
}


exxit() {
  set +euxo pipefail
  [ $1 -ne 0 ] && cancel "$2"
  exit $1
}


version_info() {
  local line=""
  local println=false

  # a note on untested Magisk versions
  if [ $MAGISK_VER_CODE -gt 19300 ]; then
    ui_print " "
    ui_print "  (i) Note: this Magisk version hasn't been tested by $author!"
    ui_print "    - If you come across any issue, please report."
  fi

  ui_print " "
  ui_print "  LATEST CHANGES"
  ui_print " "
  cat ${config%/*}/info/README.md | while IFS= read -r line; do
    if $println; then
      line="$(echo "    $line")" && ui_print "$line"
    else
      echo "$line" | grep -q \($versionCode\) && println=true \
        && line="$(echo "    $line")" && ui_print "$line"
    fi
  done
  ui_print " "

  ui_print "  LINKS"
  ui_print "    - ACC app: github.com/MatteCarra/AccA/"
  ui_print "    - Battery company: cadex.com"
  ui_print "    - Battery University: batteryuniversity.com/learn/article/how_to_prolong_lithium_based_batteries/"
  ui_print "    - Donate: paypal.me/vr25xda/"
  ui_print "    - Facebook page: facebook.com/VR25-at-xda-developers-258150974794782/"
  ui_print "    - Git repository: github.com/VR-25/$MODID/"
  ui_print "    - Telegram channel: t.me/vr25_xda/"
  ui_print "    - Telegram group: t.me/${MODID}_magisk/"
  ui_print "    - Telegram profile: t.me/vr25xda/"
  ui_print "    - XDA thread: forum.xda-developers.com/apps/magisk/module-magic-charging-switch-cs-v2017-9-t3668427/"
  ui_print " "

  ui_print "(i) Important info: https://bit.ly/2TRqRz0"
  ui_print " "
  if $BOOTMODE; then
    ui_print "(i) Ignore the reboot button. You can use $MODID right away."
    ui_print " "
  fi
}
