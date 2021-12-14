#!/usr/bin/env sh
# Installation Archives Builder
# Copyright 2018-2021, VR25
# License: GPLv3+
#
# usage: $0 [any_random_arg]
#   e.g.,
#     build.sh (builds $id and generates installable archives)
#     build.sh any_random_arg (only builds $id)


(cd ${0%/*} 2>/dev/null

. ./check-syntax.sh || exit $?


set_prop() {
  sed -i -e "s/^($1=.*/($1=$2/" -e "s/^$1=.*/$1=$2/" \
    ${3:-module.prop} 2>/dev/null
}


id=$(sed -n "s/^id=//p" module.prop)

domain=$(sed -n "s/^domain=//p" module.prop)

version=$(grep '\*\*.*\(.*\)\*\*' README.md \
  | tail -n 1 | sed 's/\*\*//; s/ .*//')

versionCode=$(grep '\*\*.*\(.*\)\*\*' README.md \
  | tail -n 1 | sed 's/\*\*//g; s/.* //' | tr -d ')' | tr -d '(')

tmpDir=.tmp/META-INF/com/google/android


# update module.prop
grep -q "$versionCode" module.prop || {
  set_prop version $version
  set_prop versionCode $versionCode
}


# set ID
for file in ./install*.sh ./$id/*.sh ./bundle.sh; do
  if [ -f "$file" ] && grep -Eq '(^|\()id=' $file; then
    grep -Eq "(^|\()id=$id" $file || set_prop id $id $file
  fi
done


# set domain
for file in ./install*.sh ./$id/*.sh ./bundle.sh; do
  if [ -f "$file" ] && grep -Eq '(^|\()domain=' $file; then
    grep -Eq "(^|\()domain=$domain" $file || set_prop domain $domain $file
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
    echo; . ./$id/strings.sh; print_help; \
    echo; sed -n '/^#\/TC#/,$p' README.md.tmp; } > README.md
    rm README.md.tmp
  set +e
fi


# update busybox config (from $id/setup-busybox.sh) in $id/uninstall.sh and install scripts
set -e
for file in ./$id/uninstall.sh ./install*.sh; do
  [ $file -ot $id/setup-busybox.sh ] && {
    { sed -n '1,/#BB#/p' $file; \
    grep -Ev '^$|^#' $id/setup-busybox.sh; \
    sed -n '/^#\/BB#/,$p' $file; } > ${file}.tmp
    mv -f ${file}.tmp $file
  }
done
set +e


# unify installers for flashable zip (customize.sh and update-binary are copies of install.sh)
{ cp -u install.sh customize.sh
cp -u install.sh META-INF/com/google/android/update-binary; } 2>/dev/null


if [ bin/${id}-uninstaller.zip -ot $id/uninstall.sh ] || [ ! -f bin/${id}-uninstaller.zip ]; then
  # generate $id uninstaller flashable zip
  echo "=> bin/${id}-uninstaller.zip"
  rm -rf bin/${id}-uninstaller.zip $tmpDir 2>/dev/null
  mkdir -p bin $tmpDir
  cp $id/uninstall.sh $tmpDir/update-binary
  echo "#MAGISK" > $tmpDir/updater-script
  (cd .tmp
  zip -r9 ../bin/${id}-uninstaller.zip * \
    | sed 's|.*adding: ||' | grep -iv 'zip warning:')
  rm -rf .tmp
  echo
fi


[ -z "$1" ] && {

  basename=${id}_${version}_$versionCode

  # cleanup
  rm -rf _builds/${basename}/ 2>/dev/null
  mkdir -p _builds/${basename}/${basename}

  cp bin/${id}-uninstaller.zip _builds/${basename}/

  # generate $id flashable zip
  echo "=> _builds/${basename}/${basename}.zip"
  zip -r9 _builds/${basename}/${basename}.zip \
    * .gitattributes .gitignore \
    -x _\*/\* | sed 's|.*adding: ||' | grep -iv 'zip warning:'
  echo

  # prepare files to be included in $id installable tarball
  cp install-tarball.sh _builds/${basename}/
  cp -R ${id}/ install.sh *.md module.prop bin/ \
    _builds/${basename}/${basename}/ 2>&1 \
    | grep -iv "can't preserve"

  # generate $id installable tarball
  cd _builds/${basename}
  echo "=> _builds/${basename}/${basename}.tar.gz"
  tar -cvf - ${basename} | gzip -9 > ${basename}.tar.gz
  rm -rf ${basename}/
  echo

})
exit 0
