#!/usr/bin/env sh
# Installation Archives Builder
# Copyright (c) 2018-2019, VR25 (xda-developers.com)
# License: GPLv3+

(cd ${0%/*} 2>/dev/null

. check-syntax.sh noprompt || exit $?

set_value() { sed -i -e "s/^($1=.*/($1=$2/" -e "s/^$1=.*/$1=$2/" ${3:-module.prop}; }

id=$(sed -n "s/^id=//p" module.prop)

version=$(grep '\*\*.*\(.*\)\*\*' README.md \
  | head -n1 | sed 's/\*\*//; s/ .*//')

versionCode=$(grep '\*\*.*\(.*\)\*\*' README.md \
  | head -n1 | sed 's/\*\*//g; s/.* //' | tr -d ')' | tr -d '(')

set_value version $version
set_value versionCode $versionCode

# prepare files to be included in tarball
rm -rf _builds/${id}-${versionCode}/ 2>/dev/null
mkdir -p bin _builds/${id}-$versionCode/${id}-${versionCode}
cp install-tarball.sh _builds/${id}-${versionCode}/
cp -R ${id}/ install-c* *.md module.prop bin/ _builds/${id}-$versionCode/${id}-${versionCode} 2>&1 | grep -iv "can't preserve"

# set ID
for file in ./install-*.sh ./$id/*.sh ./bundle.sh \
  ./uninstaller-src/META-INF/com/google/android/update-binary
do
  if [ -f "$file" ] && grep -Eq '(^|\()id=' $file; then
    grep -Eq "(^|\()id=$id" $file || set_value id $id $file
  fi
done

# unify installers
cp -u install-current.sh install.sh 2>/dev/null
cp -u install-current.sh META-INF/com/google/android/update-binary 2>/dev/null

# generate flashable zips
echo "=> _builds/${id}-${versionCode}/${id}-${versionCode}.zip"
rm bin/${id}-uninstaller.zip 2>/dev/null
(cd uninstaller-src; zip -r9q ../bin/${id}-uninstaller.zip META-INF)
zip -r9 _builds/${id}-${versionCode}/${id}-${versionCode}.zip \
  * .gitattributes .gitignore \
  -x _\*/\* | sed 's|^.*adding: ||' | grep -iv 'zip warning:'
echo

# generate tarball
cd _builds/${id}-${versionCode}
echo "=> _builds/${id}-${versionCode}/${id}-${versionCode}.tar.gz"
tar -cvf - ${id}-${versionCode} | gzip -9 > ${id}-${versionCode}.tar.gz
rm -rf ${id}-${versionCode}/
echo
read -p "(i) Press ENTER to continue..."
echo
exit 0)
