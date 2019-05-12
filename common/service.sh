#!/system/bin/sh
# acc/accd initializer

# prepare working directory
mkdir /sbin/_acc
ln -fs ${0%/*} /sbin/_acc/acc
ln -fs /sbin/_acc/acc/acc /sbin/acc
ln -fs /sbin/_acc/acc/accd-init /sbin/accd

# generate power supply log
${0%/*}/psl $(sed -n s/versionCode=//p ${0%/*}/module.prop)

# fix termux su PATH
termuxSu=/data/data/com.termux/files/usr/bin/su
if [ -f $termuxSu ] && grep -q '/su:' $termuxSu; then
  sed -i 's|/su:|:|' $termuxSu
  magisk --clone-attr ${termuxSu%su}apt $termuxSu
fi
unset termuxSu

# start accd
accd

exit 0
