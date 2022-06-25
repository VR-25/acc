# usage: . $0
id=acc
(pid=
set +euo sh 2>/dev/null || :
if ! flock -n 0; then
  read pid
  kill $pid > /dev/null 2>&1
  timeout 10 flock 0
  kill -KILL $pid >/dev/null 2>&1
  flock 0
fi) <>$TMPDIR/${id}.lock || :
