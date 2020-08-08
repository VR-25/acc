#!/system/bin/sh
# Zip Flasher
# Copyright 2020, VR25
# License: GPLv3+
#
# usage:
#  $0 (file picker)
#  $0 [file...]
#
# Logs are save to <file>.log


# spaces to "___" and vice-versa

_s() {
  echo "$1" | sed "s|___| |g"
}

s_() {
  echo "$1" | sed "s| |___|g"
}


pick_zips() {
  clear
  echo
  cd "${1-/sdcard/Download/}"
  echo ": $PWD/"
  IFS=$'\n'
  select_ target $(ls -1Ap | grep -Ei '.*.zip$|/$') "<Custom path>" "<Back>" "<Exit>"
  unset IFS
  if [ -f "$target" ]; then
   zipFiles="$zipFiles $(s_ "$target")"
   echo
   echo "$zipFiles" | sed 's| |\n> |' | sed 's|___| |g'
   echo
   printf "Add more zips to the queue: a\nStart flashing: [enter]\nExit: CTRL-C\n> "
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
    printf "> "
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
  zipFiles="$(s_ "$1")"
  shift
  while [ -n "$1" ]; do
    zipFiles="$zipFiles $(s_ "$1")"
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

  zipFile="$(_s "$zipFile")"

  # prepare tmpdir
  rm -rf /dev/.install-zip 2>/dev/null
  mkdir -p /dev/.install-zip

  # log
  exec 2>"$zipFile.log"
  set -x

  # extract update-binary & flash zip
  unzip -o "$zipFile" 'META-INF/*' -d /dev/.install-zip >&2 && {
    $noClear && echo || clear
    echo
    /system/bin/sh /dev/.install-zip/META-INF/*/*/*/update-binary dummy 1 "$zipFile" # $3 = outfd
  }

  # on failure: next or abort
  e=$?
  [ $e -ne 0 ] && {
printf "
(!) $zipFile: *exit $e*
> $zipFile.log

Continue: [enter]
Exit: CTRL-C
> "
    read
  }

  # cleanup
  rm -rf /dev/.install-zip 2>/dev/null

done

exit $exitCode
