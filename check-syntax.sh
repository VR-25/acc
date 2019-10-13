#!/usr/bin/env sh
# Basic Shell Syntax Checker
# Copyright (c) 2018-2019, VR25 (xda-developers.com)
# License: GPLv3+

(echo
cd ${0%/*} 2>/dev/null
exitCode=0
for f in $(find . \( -path ./_builds -o -path ./_resources -o -path ./META-INF \) -prune -o -type f -name '*.sh'); do
  if [ -f "$f" ]; then
    bash -n $f || exitCode=$?
  fi
done
[ $exitCode -eq 0 ] || echo
if [ -z "$1" ]; then
  read -p "(i) Press ENTER to continue..."
  echo
fi
exit $exitCode)
