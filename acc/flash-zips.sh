#!/dev/.busybox/ash
# Universal shell-based-zip flasher
# Copyright 2020, VR25 (xda-developers)
# License: GPLv3+
#
# usage: $0 or $0 "file1 file2 ..."
# the installation log file is stored in the zip_file directory as file.zip.log


pick_zips() {
  clear
  echo
  cd "${1-/sdcard/Download/}"
  echo ": $PWD/"
  IFS=$'\n'
  select_ target $(ls -1Ap | grep -Ei '.*.zip$|/$') "<Custom path>" "<Back>" "<Exit>"
  unset IFS
  if [ -f "$target" ]; then
   zipFiles="$zipFiles ${target// /__}"
   echo
   print "${zipFiles// /'\n'> }" | sed 's/__/ /'
   echo
   print -n "Add more zips to the queue: a\nStart flashing: [enter]\nExit: CTRL-C\n> "
   read -n1 target
   [ "$target" = a ] && pick_zips .
  elif [ -d "$target" ]; then
    echo
    pick_zips "$target"
  elif [ "$target" = "<Back>" ]; then
   cd ..
   echo
   pick_zips .
  elif [ "$target" = "<Exit>" ]; then
    exit 0
  elif [ "$target" = "<Custom path>" ]; then
    echo -n "> "
    read target
    cd "${target:-.}"
    echo
    pick_zips .
  else
    echo
    pick_zips .
  fi
  [ -n "$zipFiles" ] || exit 0
}


trap 'e=$?; echo; exit $e' EXIT
. ${0%/*}/select.sh
. ${0%/*}/setup-busybox.sh


# parse file names
[ -n "$1" ] && {
  zipFiles="${1// /__}"
  shift
  while [ -n "$1" ]; do
    zipFiles="$zipFiles ${1// /__}"
    shift
  done
}


[ -z "$zipFiles" ] && {
  pick_zips
  unset target
}


case "$zipFiles" in
  *\ *) noClear=true;;
esac


for zipFile in $zipFiles; do

  # prepare tmpdir
  rm -rf /dev/.install-zip 2>/dev/null
  mkdir -p /dev/.install-zip

  # log
  exec 2>"${zipFile//__/ }.log"
  set -x

  # extract update-binary & flash zip
  unzip -o "${zipFile//__/ }" 'META-INF/*' -d /dev/.install-zip >&2 && {
    $noClear && echo || clear
    echo
    sh /dev/.install-zip/META-INF/*/*/*/update-binary dummy 1 "${zipFile//__/ }" # $3 = outfd
  }

  # on failure: next or abort
  e=$?
  [ $e -ne 0 ] && {
echo -n "
(!) ${zipFile//__/ }: *exit $e*
> ${zipFile//__/ }.log

Continue: [enter]
Exit: CTRL-C
> "
    read
  }

  # cleanup
  rm -rf /dev/.install-zip 2>/dev/null

done

exit $exitCode
