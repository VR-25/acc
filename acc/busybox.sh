# Set up busybox

if [[ $PATH != *busybox:* ]]; then
  if [ -d /sbin/.magisk/busybox ]; then
    PATH=/sbin/.magisk/busybox:$PATH
  elif [ -d /sbin/.core/busybox ]; then
    PATH=/sbin/.core/busybox:$PATH
  elif which busybox > /dev/null; then
    mkdir -p -m 700 /dev/.busybox
    busybox install -s /dev/.busybox
    PATH=/dev/.busybox:$PATH
  else
    echo "(!) Install busybox binary first"
    exit 3
  fi
fi
