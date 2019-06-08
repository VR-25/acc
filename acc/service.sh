#!/system/bin/sh
# acc/accd initializer

# prepare working directory
([ -d /sbin/.acc ] && [ ${1:-x} != install ] && exit 0
mkdir /sbin/.acc
[ -h /sbin/.acc/acc ] && rm /sbin/.acc/acc \
  || rm -rf /sbin/.acc/acc 2>/dev/null
[ $MAGISK_VER_CODE:-18200} -gt 18100 ] \
  && ln -s ${0%/*} /sbin/.acc/acc \
  || cp -a ${0%/*} /sbin/.acc/acc
ln -fs /sbin/.acc/acc/acc.sh /sbin/acc
ln -fs /sbin/.acc/acc/accd-init.sh /sbin/accd

# generate power supply log
${0%/*}/psl.sh $(sed -n s/versionCode=//p ${0%/*}/module.prop)

# fix termux's PATH
termuxSu=/data/data/com.termux/files/usr/bin/su
if [ -f $termuxSu ] && grep -q 'PATH=.*/sbin/su' $termuxSu; then
  sed '\|PATH=|s|/sbin/su|/sbin|' $termuxSu > $termuxSu.tmp
  cat $termuxSu.tmp > $termuxSu
  rm $termuxSu.tmp
fi
unset termuxSu

# start accd
/sbin/accd &) &

exit 0
