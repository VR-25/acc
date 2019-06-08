#!/usr/bin/env bash
# Basic Shell Syntax Checker
# Copyright (C) 2018-2019, VR25 @ xda-developers
# License: GPLv3+

echo
cd ${0%/*} 2>/dev/null
modId=${PWD##/}
for f in $(find . \( -path ./_builds -o -path ./_resources -o -path ./META-INF \) -prune -o -type f -name '*.sh'); do
  [ -f "$f" ] && bash -n $f
done
echo
