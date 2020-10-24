# usage: . $0
id=acc
set +o sh 2>/dev/null || :
exec 4<>$TMPDIR/${id}.lock || exit 13
flock -n 0 <&4 || exit 13
echo $$ >&4
