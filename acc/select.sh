# "Select" For Shells That Lack It
# Copyright 2019-2020, VR25
# License: GPLv3+
#
# usage
#  . $0
#  select_ <var> <list>
#
# ${PS3:-#?} is used.


select_() {

  local item
  local list
  local n
  local _var_="$1"

  shift
  [ $# -gt 9 ] || n="-n 1"

  for item in "$@"; do
    list="$(printf "$list\n$item")"
  done

  list="$(echo "$list" | grep -v '^$' | nl -s ") " -w 1)"
  printf "$list\n\n${PS3:-#? }"
  read $n item
  list="$(echo "$list" | sed -n "s|^${item}. ||p")"
  list="$_var_=\"$list\""
  eval "$list"
}
