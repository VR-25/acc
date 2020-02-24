#!/usr/bin/env sh
# Installation Archives Builder
# Copyright (c) 2018-2020, VR25 (xda-developers)
# License: GPLv3+
#
# usage: $0 [any_random_arg]
#   e.g.,
#     build.sh (builds $id and generates installable archives)
#     build.sh any_random_arg (only builds $id)
#
# devs: triple hashtags (###) mark custom code


(cd ${0%/*} 2>/dev/null

. check-syntax.sh || exit $?


set_prop() {
  sed -i -e "s/^($1=.*/($1=$2/" -e "s/^$1=.*/$1=$2/" \
    ${3:-module.prop} 2>/dev/null
}


id=$(sed -n "s/^id=//p" module.prop)

version=$(grep '\*\*.*\(.*\)\*\*' README.md \
  | head -n1 | sed 's/\*\*//; s/ .*//')

versionCode=$(grep '\*\*.*\(.*\)\*\*' README.md \
  | head -n1 | sed 's/\*\*//g; s/.* //' | tr -d ')' | tr -d '(')


set_prop version $version
set_prop versionCode $versionCode


# set ID
for file in ./install-*.sh ./$id/*.sh ./bundle.sh \
  ./uninstaller-src/META-INF/com/google/android/update-binary
do
  if [ -f "$file" ] && grep -Eq '(^|\()id=' $file; then
    grep -Eq "(^|\()id=$id" $file || set_prop id $id $file
  fi
done


# update README ###

if [ README.md -ot acc/default-config.txt ] \
  || [ README.md -ot acc/strings.sh ]
then
# default config
  set -e
  { sed -n '1,/#DC#/p' README.md; echo; cat acc/default-config.txt; \
    echo; sed -n '/^#\/DC#/,$p' README.md; } > README.md.tmp
# terminal commands
  { sed -n '1,/#TC#/p' README.md.tmp; \
    echo; sed -n '/^Usage/,/^Run a/p' acc/strings.sh; \
    echo; sed -n '/^#\/TC#/,$p' README.md.tmp; } > README.md
    rm README.md.tmp
  set +e
fi


# update busybox config in scripts outside $id/
set -e
for file in ./install-*.sh \
  ./uninstaller-src/META-INF/com/google/android/update-binary
do
  if [ $file -ot acc/setup-busybox.sh ]; then
    { sed -n '1,/#BB#/p' $file; \
    sed -n '/^if /,/^fi/p' acc/setup-busybox.sh; \
    sed -n '/^#\/BB#/,$p' $file; } > ${file}.tmp
    mv -f ${file}.tmp $file
  fi
done
set +e


# unify installers
{ cp -u install-current.sh customize.sh
cp -u install-current.sh META-INF/com/google/android/update-binary; } 2>/dev/null


# initial cleanup
rm -rf _builds/${id}-${versionCode}/ 2>/dev/null
mkdir -p bin _builds/${id}-$versionCode/${id}-${versionCode}


# generate $id uninstaller flashable zip
echo "=> bin/${id}-uninstaller.zip"
rm bin/${id}-uninstaller.zip 2>/dev/null
(cd uninstaller-src; zip -r9 ../bin/${id}-uninstaller.zip META-INF \
  | sed 's|^.*adding: ||' | grep -iv 'zip warning:')
echo


if [ -z "$1" ]; then

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
