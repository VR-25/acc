#!/system/bin/sh
# MCS Service Ignitor
# VR25 @ xda-developers

export ModPath=${0%/*}
export PATH="$ModPath/system/xbin:$ModPath/system/bin:/sbin/.core/busybox:/dev/magisk/bin:$PATH"
(mcs service) &
