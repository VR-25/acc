#!/usr/bin/env bash
# Flashable Zip Builder
# Copyright (C) 2018-2019, VR25 @ xda-developers
# License: GPLv3+

echo
get_value() { sed -n "s/^$1=//p" module.prop; }
set_value() { sed -i "s/^$1=.*/$1=$2/" module.prop; }

cd ${0%/*} 2>/dev/null

version=$(grep '\*\*.*\(.*\)\*\*' README.md \
  | head -n1 | sed 's/\*\*//; s/ .*//')

versionCode=$(grep '\*\*.*\(.*\)\*\*' README.md \
  | head -n1 | sed 's/\*\*//g; s/.* //' | tr -d ')' | tr -d '(')

set_value version $version
set_value versionCode $versionCode

mkdir -p _builds

if [[ ${1:-x} != f ]]; then
  echo "Downloading latest update-binary..."
  curl -L https://raw.githubusercontent.com/topjohnwu/Magisk/master/scripts/module_installer.sh 2>/dev/null > _builds/update-binary \
    && mv -f _builds/update-binary META-INF/com/google/android/
fi

zip -r9u _builds/$(get_value id)-$(get_value versionCode).zip \
  * .gitattributes .gitignore \
  -x _\*/\* | grep .. && echo
