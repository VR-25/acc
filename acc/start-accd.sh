#!/dev/.busybox/ash
export noVibrations=true
(/sbin/.acc/acc/accd.sh "$@" &) &
exit $?
