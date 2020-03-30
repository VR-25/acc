#!/dev/.busybox/ash
(/sbin/.acc/acc/accd.sh $1 &) &
exit $?
