# read charging current control files (part 2)
#   once and while charging only
#   otherwise, most values would be zero (wrong)

(set +e

if [ ! -f $TMPDIR/.ch-curr-read ] \
  || ! grep -q / $TMPDIR/ch-curr-ctrl-files 2>/dev/null
then

  . $execDir/ctrl-files.sh
  plugins=/data/adb/vr25/acc-data/plugins
  [ -f $plugins/ctrl-files.sh ] && . $plugins/ctrl-files.sh

  ls -1 $(list_curr_ctrl_files_dynamic) 2>/dev/null | \
    while read file; do
      chmod 0644 $file || continue
      defaultValue=$(cat $file)
      [ $defaultValue -eq 0 ] && continue
      if [ ${defaultValue#-} -lt 10000 ]; then
        # milliamps
        echo ${file}::v::$defaultValue \
          >> $TMPDIR/ch-curr-ctrl-files
      else
        # microamps
        echo ${file}::v000::$defaultValue \
          >> $TMPDIR/ch-curr-ctrl-files
      fi
    done

  sort -u $TMPDIR/ch-curr-ctrl-files > $TMPDIR/ch-curr-ctrl-files_

  # exclude non-batt control files
  $currentWorkaround \
    && grep -i batt $TMPDIR/ch-curr-ctrl-files_ > $TMPDIR/ch-curr-ctrl-files \
    || mv -f $TMPDIR/ch-curr-ctrl-files_ $TMPDIR/ch-curr-ctrl-files
fi

touch $TMPDIR/.ch-curr-read) || :
