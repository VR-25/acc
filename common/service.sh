#!/system/bin/sh
# mcs daemon starter
# (c) 2017-2018, VR25 @ xda-developers
# License: GPL v3+

main() {
  modPath=${0%/*}
  [ -d $modPath/system/xbin ] && execDir=xbin || execDir=bin
  $modPath/system/$execDir/mcs daemon dpath
}

(main) &
