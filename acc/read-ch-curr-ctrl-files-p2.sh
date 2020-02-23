# read charging current control files (part 2)
# once and while charging only
# otherwise, most values would be zero (wrong)

(set +euo pipefail 2>/dev/null
if ! grep -q ::v $TMPDIR/ch-curr-ctrl-files; then
  ls -1 */current_max */constant_charge_current_max \
    */input_current_max */restrict*_cur* \
    /sys/class/qcom-battery/restrict*_cur* 2>/dev/null | \
      while read file; do
        chmod +r $file || continue
        if grep -Eq '^[0-9]{6}' $file; then
          echo ${file}::$(sed -n 's/^....../vvvvvv/p' $file)::$(cat $file) \
            >> /sbin/.acc/ch-curr-ctrl-files
        fi
     done
fi) || :
readChCurr=false
