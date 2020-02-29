#!/system/bin/sh
# Universal Shell-Based-Zip flasher
# Copyright (c) 2020, VR25 (xda-developers)
# License: GPLv3+
#
# usage: $0 or $0 "file1 file2 ..."
# the installation log file is stored in the zip_file directory


pick_zips() {
  clear
  echo
  cd ${1:-/storage}
  echo ": $PWD"
  echo
  select target in $(ls -Ap | grep -Ei '.*.zip$|/$') ... ^ X; do
    if [ -f "$target" ]; then
     zipFiles="$zipFiles $target"
     echo
     select target in + ">>>" X; do
      case $target in
        "+") pick_zips .;;
        X) exit 0;;
      esac
      break
     done
    elif [ -d "$target" ]; then
      echo
      pick_zips "$target"
    elif [ "$target" == ^ ]; then
     cd ..
     echo
     pick_zips .
    elif [ "$target" == X ]; then
      exit 0
    elif [ "$target" == ... ]; then
      echo -n "> "
      read target
      cd ${target:-.}
      echo
      pick_zips .
    else
      echo
      pick_zips .
    fi
    break
  done
  [ -n "$zipFiles" ] || exit 0
}


exxit() {
  local exitCode=$?
  echo
  exit $exitCode
}


trap exxit EXIT
zipFiles="$@"
. ${0%/*}/setup-busybox.sh

if [[ -z "$zipFiles" ]]; then
  PS3="
(?) *.zip: "
  pick_zips
  unset target
fi

[[ "$zipFiles" == *" "* ]] && noClear=true


# root check
if [ $(id -u) -ne 0 ]; then
  echo "(!) $0 must run as root (su)"
  exit 4
fi


for zipFile in $zipFiles; do

  # prepare tmpdir
  rm -rf /dev/.install-zip 2>/dev/null
  mkdir -p /dev/.install-zip

  # log
  exec 2>"${zipFile}.log"
  set -x

  # extract update-binary
  unzip -o "$zipFile" 'META-INF/*' -d /dev/.install-zip >&2 || exit $?

  # flash zip
  # $3 == outfd
  $noClear && echo || clear
  echo
  sh /dev/.install-zip/META-INF/*/*/*/update-binary dummy 1 "$zipFile"
  exitCode=$?

  # cleanup
  rm -rf /dev/.install-zip 2>/dev/null

  # on failure: next or abort
  if [ $exitCode -ne 0 ]; then
    echo
    echo "(!) $zipFile"
    echo "CTRL-C == X"
    echo "(i) [enter] == >>>"
    read
  fi

done

exit $exitCode
