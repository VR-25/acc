#!/system/bin/sh
id=acc
(pid=
set +o sh 2>/dev/null || :
flock -n 0 || {
  read pid
  kill $pid
  timeout 6 flock 0 || kill -KILL $pid
}) <>$TMPDIR/${id}.lock
