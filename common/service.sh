#!/system/bin/sh
# mcs daemon starter
# (c) 2017-2018, VR25 @ xda-developers
# License: GPL v3+

main() {
  modPath=${0%/*}
  PATH="$modPath/system/xbin:$modPath/system/bin"
  mcs daemon
}

(main) &
