#!/system/bin/sh
# For better compatibility and live upgrade support

# generate power supply log
(${0%/*}/psl $(sed -n s/versionCode=//p ${0%/*}/module.prop) &) &

# prepare working directory
mkdir -p /dev/acc
ln -fs ${0%/*} /dev/acc/modPath

exit 0
