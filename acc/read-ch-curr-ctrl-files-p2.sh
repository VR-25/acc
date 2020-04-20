# read charging current control files (part 2)
# once and while charging only
# otherwise, most values would be zero (wrong)

(
  set +euo pipefail 2>/dev/null
  grep -q ::v $TMPDIR/ch-curr-ctrl-files || {
    ls -1 */current_max */input_current_max 2>/dev/null | \
      while read file; do
        chmod u+r $file || continue
        defaultValue=$(cat $file)
        if [ $defaultValue -lt 10000 -a $defaultValue -ne 0 ]; then
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
    mv -f $TMPDIR/ch-curr-ctrl-files_ $TMPDIR/ch-curr-ctrl-files
  }
) || :
readChCurr=false
