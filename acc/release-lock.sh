# usage: . $0
id=acc
(pid=
set +euo sh 2>/dev/null || :
flock -n 0 || {
  read pid
  kill $pid
  timeout 20 flock 0 || kill -KILL $pid
}) <>$TMPDIR/${id}.lock || :
