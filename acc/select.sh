# select for shells that lack it
# usage
#  . $0
#  select_ [var] [list]

select_() {
  local item="" list="" var=$1
  shift
  for item in "$@"; do
    list="$list
$item"
  done
  list="$(echo "$list" | grep -v '^$' | nl -s ") " -w 1)"
  echo -n "
$list

${PS3:-#? }"
  read item
  echo
  list="$(echo "$list" | sed -n "s|^${item}. ||p")"
  list="$var=\"$list\""
  eval "$list"
}
