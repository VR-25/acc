#!/usr/bin/env sh
# Installation Archives Builder
# Copyright (c) 2018-2019, VR25 (xda-developers.com)
# License: GPLv3+

(cd ${0%/*} 2>/dev/null

. check-syntax.sh || exit $?

updateBinary=https://raw.githubusercontent.com/topjohnwu/Magisk/master/scripts/module_installer.sh

set_value() { sed -i "s/^$1=.*/$1=$2/" module.prop; }

id=$(sed -n "s/^id=//p" module.prop)

version=$(grep '\*\*.*\(.*\)\*\*' README.md \
  | head -n1 | sed 's/\*\*//; s/ .*//')

versionCode=$(grep '\*\*.*\(.*\)\*\*' README.md \
  | head -n1 | sed 's/\*\*//g; s/.* //' | tr -d ')' | tr -d '(')

set_value version $version
set_value versionCode $versionCode

rm -rf _builds/${id}-*/ 2>/dev/null
mkdir -p _builds/${id}-$versionCode
cp install-tarball.sh _builds/install
cp -R acc/ install-c* *.md module.prop _builds/${id}-$versionCode/

if [ -z "${1:-}" ]; then
  echo "(i) Downloading latest update-binary..."
  if wget $updateBinary --output-document _builds/update-binary \
    || curl -#L $updateBinary > _builds/update-binary
  then
    mv -f _builds/update-binary META-INF/com/google/android/
  fi
  echo
fi

echo "=> ${id}-${versionCode}.zip"
rm _builds/${id}-${versionCode}.zip 2>/dev/null
zip -r9 _builds/${id}-${versionCode}.zip \
  * .gitattributes .gitignore \
  -x _\*/\* | sed 's/^.*adding: //' | grep -iv 'zip warning:' | grep .. && echo

cd _builds
echo "=> acc_bundle"
tar -cvf - ${id}-${versionCode} | gzip -9 > acc_bundle
rm -rf ${id}-*/
echo
exit 0)
