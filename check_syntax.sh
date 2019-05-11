#!/usr/bin/env bash
# Basic Shell Syntax Checker
# Copyright (C) 2018-2019, VR25 @ xda-developers
# License: GPLv3+

echo
cd ${0%/*} 2>/dev/null
for f in $(find . \( -path ./_builds -o -path ./_resources \) -prune \
  -o -type f -name '*.sh') \
  ./common/MODPATH/acc* ./common/MODPATH/psl \
  ./common/MODPATH/system/xbin/acc
do
  [ -f "$f" ] && bash -n $f
done
echo
