#!/usr/bin/env sh
# Installation Archives Builder
# Copyright (c) 2018-2020, VR25 (xda-developers)
# License: GPLv3+
#
# usage: $0 [any_random_arg]
#   e.g.,
#     build.sh (builds $id and generates installable archives)
#     build.sh any_random_arg (only builds $id)


(cd ${0%/*} 2>/dev/null

. check-syntax.sh || exit $?


set_prop() {
  sed -i -e "s/^($1=.*/($1=$2/" -e "s/^$1=.*/$1=$2/" \
    ${3:-module.prop} 2>/dev/null
}


id=$(sed -n "s/^id=//p" module.prop)

version=$(grep '\*\*.*\(.*\)\*\*' README.md \
  | head -n 1 | sed 's/\*\*//; s/ .*//')

versionCode=$(grep '\*\*.*\(.*\)\*\*' README.md \
  | head -n 1 | sed 's/\*\*//g; s/.* //' | tr -d ')' | tr -d '(')

tmpDir=.tmp/META-INF/com/google/android


# update module.prop
if ! grep -q "$versionCode" module.prop; then
  set_prop version $version
  set_prop versionCode $versionCode
fi


# set ID
for file in ./install-*.sh ./$id/*.sh ./bundle.sh; do
  if [ -f "$file" ] && grep -Eq '(^|\()id=' $file; then
    grep -Eq "(^|\()id=$id" $file || set_prop id $id $file
  fi
done


# update README

if [ README.md -ot $id/default-config.txt ] \
  || [ README.md -ot $id/strings.sh ]
then
# default config
  set -e
  { sed -n '1,/#DC#/p' README.md; echo; cat $id/default-config.txt; \
    echo; sed -n '/^#\/DC#/,$p' README.md; } > README.md.tmp
# terminal commands
  { sed -n '1,/#TC#/p' README.md.tmp; \
    echo; sed -n '/^Usage/,/^  Run a/p' $id/strings.sh; \
    echo; sed -n '/^#\/TC#/,$p' README.md.tmp; } > README.md
    rm README.md.tmp
  set +e
fi


# update busybox config (from acc/setup-busybox.sh) in $id/uninstall.sh and install scripts
set -e
for file in ./$id/uninstall.sh ./install-*.sh; do
  if [ $file -ot $id/setup-busybox.sh ]; then
    { sed -n '1,/#BB#/p' $file; \
    sed -n '/^if /,/^fi/p' $id/setup-busybox.sh; \
    sed -n '/^#\/BB#/,$p' $file; } > ${file}.tmp
    mv -f ${file}.tmp $file
  fi
done
set +e


# unify installers for flashable zip (customize.sh and update-binary are copies of install-current.sh)
{ cp -u install-current.sh customize.sh
cp -u install-current.sh META-INF/com/google/android/update-binary; } 2>/dev/null


if [ bin/${id}-uninstaller.zip -ot $id/uninstall.sh ] || [ ! -f bin/${id}-uninstaller.zip ]; then
  # generate $id uninstaller flashable zip
  echo "=> bin/${id}-uninstaller.zip"
  rm -rf bin/${id}-uninstaller.zip $tmpDir 2>/dev/null
  mkdir -p bin $tmpDir
  cp $id/uninstall.sh $tmpDir/update-binary
  echo "#MAGISK" > $tmpDir/updater-script
  (cd .tmp
  zip -r9 ../bin/${id}-uninstaller.zip * \
    | sed 's|^.*adding: ||' | grep -iv 'zip warning:')
  rm -rf .tmp
  echo
fi


if [ -z "$1" ]; then

  # cleanup
  rm -rf _builds/${id}-$versionCode/ 2>/dev/null
  mkdir -p _builds/${id}-$versionCode/${id}-$versionCode

  # generate $id flashable zip
  echo "=> _builds/${id}-${versionCode}/${id}-${versionCode}.zip"
  zip -r9 _builds/${id}-${versionCode}/${id}-${versionCode}.zip \
    * .gitattributes .gitignore \
    -x _\*/\* | sed 's|^.*adding: ||' | grep -iv 'zip warning:'
  echo

  # prepare files to be included in $id installable tarball
  cp install-tarball.sh _builds/${id}-${versionCode}/
  cp -R ${id}/ install-c* *.md module.prop bin/ \
    _builds/${id}-$versionCode/${id}-${versionCode} 2>&1 \
    | grep -iv "can't preserve"

  # generate $id installable tarball
  cd _builds/${id}-${versionCode}
  echo "=> _builds/${id}-${versionCode}/${id}-${versionCode}.tar.gz"
  tar -cvf - ${id}-${versionCode} | gzip -9 > ${id}-${versionCode}.tar.gz
  rm -rf ${id}-${versionCode}/
  echo

fi
exit 0)
