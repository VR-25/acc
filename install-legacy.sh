#!/system/bin/sh
# ACC installer/upgrader for old Magisk versions and other root solutions

[[ ${1:-x} == /* ]] || exec echo -e "\n(i) Usage: sh $0 /absolute/path/to/acc-*.zip\n"

PATH=/sbin/.core/busybox:$PATH
which unzip >/dev/null || exit 1
rm -rf /data/media/0/acc 2>/dev/null
mkdir -p /data/media/0/acc/info
unzip $1 '*.md' -d /data/media/0/acc/info >/dev/null
chmod -R 0777 /data/media/0/acc

mount -o remount,rw /sbin
cd /sbin/.core/img 2>/dev/null || cd /data/adb || exit 1
rm -rf acc 2>/dev/null
unzip $1 'acc/*' module.prop -d . >/dev/null
mv module.prop acc/

if [ $PWD == /data/adb ]; then
  mv acc/service.sh acc/acc-init.sh
  echo -e "\n(i) Use init.d or an app to run /data/adb/acc/acc-init.sh on boot to initialize acc.\n"
else
  ln acc/service.sh acc/post-fs-data.sh
fi

sed -i s/\.magisk/\.core/ acc/acc.sh
sed -i s/\.magisk/\.core/ acc/accd.sh
chmod 0755 acc/*.sh

if [ -f acc/service.sh ]; then
  $PWD/acc/service.sh install
else
  $PWD/acc/acc-init.sh install
fi

exit 0
