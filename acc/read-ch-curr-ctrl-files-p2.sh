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

  ls -1 $(list_curr_ctrl_files_dynamic | grep -Ev '^#|^$') 2>/dev/null | \
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

  # add curr and volt ctrl files to charging switches list
  sed -e 's/::.*::/ /g' -e 's/$/ 0/' $TMPDIR/ch-curr-ctrl-files_ > $TMPDIR/.ctrl
  sed -Ee 's/::.*::/ /g' -e 's/([0-9])$/\1 voltage_now/' $TMPDIR/ch-volt-ctrl-files >> $TMPDIR/.ctrl
  grep / $TMPDIR/.ctrl >> $TMPDIR/ch-switches
  rm $TMPDIR/.ctrl

  # exclude troublesome ctrl files
  sed -i '\|bq[0-9].*/current_max|d' $TMPDIR/ch-switches

  # exclude non-batt control files
  $currentWorkaround \
    && grep -i batt $TMPDIR/ch-curr-ctrl-files_ > $TMPDIR/ch-curr-ctrl-files \
    || cat $TMPDIR/ch-curr-ctrl-files_ > $TMPDIR/ch-curr-ctrl-files
fi

rm $TMPDIR/ch-curr-ctrl-files_
touch $TMPDIR/.ch-curr-read) || :
