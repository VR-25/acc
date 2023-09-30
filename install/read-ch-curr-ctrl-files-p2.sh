# read charging current control files (part 2)
#   once and while charging only
#   otherwise, most values would be zero (wrong)

(set +e

currCtrl=$TMPDIR/ch-curr-ctrl-files

if [ ! -f $TMPDIR/.ch-curr-read ] \
  || ! grep -q / ${currCtrl} 2>/dev/null
then

  . $execDir/ctrl-files.sh
  plugins=/data/adb/vr25/acc-data/plugins
  [ -f $plugins/ctrl-files.sh ] && . $plugins/ctrl-files.sh

  ls -1 $(ls_curr_ctrl_files | grep -Ev '^#|^$') 2>/dev/null | \
    while read file; do
      chmod a+r $file || continue
      defaultValue="$(cat $file 2>/dev/null)" || continue
      case "$defaultValue" in
        ""|-*|*" "*|[01]|*[a-zA-Z]*) continue;;
        [1-9]*)
          if [ "$defaultValue" -lt 10000 ]; then
            # milliamps
            echo ${file}::v::$defaultValue >> ${currCtrl}_
          else
            # microamps
            echo ${file}::v000::$defaultValue >> ${currCtrl}_
          fi;;
      esac
    done

  # exclude troublesome ctrl files
  sort -u ${currCtrl}_ \
    | grep -Eiv 'parallel|::-|bq[0-9].*/current_max' > $TMPDIR/.ctrl

  # exclude non-batt control files
  $currentWorkaround \
    && grep -i batt $TMPDIR/.ctrl > ${currCtrl} \
    || cat $TMPDIR/.ctrl > ${currCtrl}

  # add curr and volt ctrl files to charging switches list
  sed -e 's/::.*::/ /' -e 's/$/ 0/' $TMPDIR/.ctrl >> $TMPDIR/ch-switches
  sed -E 's/(.*)(::v.*::)(.*)/\1 \3 \2/; s/::v/10/; s/:://' $TMPDIR/.ctrl >> $TMPDIR/ch-switches
  sed -Ee 's/::.*::/ /' -e 's/([0-9])$/\1 3600mV/' $TMPDIR/ch-volt-ctrl-files >> $TMPDIR/ch-switches

  cat $TMPDIR/ch-switches > $TMPDIR/.ctrl
  grep / $TMPDIR/.ctrl | sort -u > $TMPDIR/ch-switches
fi

rm ${currCtrl}_ $TMPDIR/.ctrl 2>/dev/null
touch $TMPDIR/.ch-curr-read) || :
