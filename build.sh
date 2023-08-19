#!/usr/bin/env sh
# Installation Archives Builder
# Copyright 2018-2022, VR25
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

version="$(sed -n 1p changelog.md | sed 's/[*()]//g')"

versionCode=${version#* }

version=${version% *}

basename=${id}_${version}_$versionCode

tmpDir=.tmp/META-INF/com/google/android


# update module info
[ changelog.md -ot module.prop ] || {
  set_prop version $version
  set_prop versionCode $versionCode
  cat << EOF > module.json
{
    "busybox": "https://github.com/Magisk-Modules-Repo/busybox-ndk",
    "changelog": "https://raw.githubusercontent.com/VR-25/$id/master/changelog.md",
    "curl": "https://github.com/Zackptg5/Cross-Compiled-Binaries-Android/tree/master/curl",
    "onlineInstaller": "https://github.com/VR-25/$id/releases/download/$version/install-online.sh",
    "tgz": "https://github.com/VR-25/$id/releases/download/$version/${basename}.tgz",
    "tgzInstaller": "https://github.com/VR-25/$id/releases/download/$version/install-tarball.sh",
    "version": "$version",
    "versionCode": $versionCode,
    "zipUrl": "https://github.com/VR-25/$id/releases/download/$version/${basename}.zip"
}
EOF
}


# set ID
for file in ./install*.sh ./install/*.sh ./bundle.sh; do
  if [ -f "$file" ] && grep -Eq '(^|\()id=' $file; then
    grep -Eq "(^|\()id=$id" $file || set_prop id $id $file
  fi
done


# set domain
for file in ./install*.sh ./install/*.sh ./bundle.sh; do
  if [ -f "$file" ] && grep -Eq '(^|\()domain=' $file; then
    grep -Eq "(^|\()domain=$domain" $file || set_prop domain $domain $file
  fi
done


# update README

if [ README.md -ot install/default-config.txt ] \
  || [ README.md -ot install/strings.sh ] \
  || [ README.md -nt README.html ]
then
# default config
  set -e
  { sed -n '1,/#DC#/p' README.md; echo; sed 's/^# /\/\/ /' install/default-config.txt; \
    echo; sed -n '/^#\/DC#/,$p' README.md; } > README.md.tmp
# terminal commands
  { sed -n '1,/#TC#/p' README.md.tmp; \
    echo; . ./install/strings.sh; print_help; \
    echo; sed -n '/^#\/TC#/,$p' README.md.tmp; } > README.md
    rm README.md.tmp
  set +e
  markdown README.md > README.html
fi


# update busybox config (from install/setup-busybox.sh) in install/uninstall.sh and install scripts
set -e
for file in ./install/uninstall.sh ./install*.sh; do
  [ $file -ot install/setup-busybox.sh ] && {
    { sed -n '1,/#BB#/p' $file; \
    grep -Ev '^$|^#' install/setup-busybox.sh; \
    sed -n '/^#\/BB#/,$p' $file; } > ${file}.tmp
    mv -f ${file}.tmp $file
  }
done
set +e


# unify installers for flashable zip (customize.sh and update-binary are copies of install.sh)
{ cp -u install.sh customize.sh
cp -u install.sh META-INF/com/google/android/update-binary; } 2>/dev/null


if [ bin/${id}_flashable_uninstaller.zip -ot install/uninstall.sh ] || [ ! -f bin/${id}_flashable_uninstaller.zip ]; then
  # generate $id uninstaller flashable zip
  echo "=> bin/${id}_flashable_uninstaller.zip"
  rm -rf bin/${id}_flashable_uninstaller.zip $tmpDir 2>/dev/null
  mkdir -p bin $tmpDir
  cp install/uninstall.sh $tmpDir/update-binary
  echo "#MAGISK" > $tmpDir/updater-script
  (cd .tmp
  zip -r9 ../bin/${id}_flashable_uninstaller.zip * \
    | sed 's|.*adding: ||' | grep -iv 'zip warning:')
  rm -rf .tmp
  echo
fi


[ -z "$1" ] && {

  # cleanup
  rm -rf _builds/${basename}/ 2>/dev/null
  mkdir -p _builds/${basename}/${basename}

  cp bin/${id}_flashable_uninstaller.zip install-online.sh install-tarball.sh _builds/${basename}/

  # generate $id flashable zip
  case $version in
    *-dev) basename_=${basename}_$(date +%H%M);;
    *) basename_=$basename;;
  esac
  echo "=> _builds/${basename}/${basename_}.zip"
  zip -r9 _builds/${basename}/${basename_}.zip \
    * .gitattributes .gitignore .github \
    -x _\*/\* | sed 's|.*adding: ||' | grep -iv 'zip warning:'
  echo

  # prepare files to be included in $id installable tarball
  cp -R install install.sh License.md README.* module.prop bin/ \
    _builds/${basename}/${basename}/ 2>&1 \
    | grep -iv "can't preserve"

  # generate $id installable tarball
  cd _builds/${basename}
  echo "=> _builds/${basename}/${basename}.tgz"
  tar -cvf - ${basename} | gzip -9 > ${basename}.tgz
  rm -rf ${basename}/
  echo

})
exit 0
