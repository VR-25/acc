#!/usr/bin/env sh
# Basic Shell Syntax Checker
# Copyright (c) 2018-2020, VR25 (xda-developers)
# License: GPLv3+

(echo
cd ${0%/*} 2>/dev/null
exitCode=0

for f in $(find . \( -path ./_builds -o -path ./_resources -o -path ./META-INF \) \
  -prune -o -type f -name '*.sh')
do
  [ -f "$f" ] && {
    bash -n $f || exitCode=$?
  }
done

[ $exitCode -eq 0 ] || echo
exit $exitCode)
