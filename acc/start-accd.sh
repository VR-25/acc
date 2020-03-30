#!/dev/.busybox/ash
(/sbin/.acc/acc/accd.sh "$@" &) &
exit $?
