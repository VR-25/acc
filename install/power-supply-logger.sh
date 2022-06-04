#!/system/bin/sh
# Advanced Charging Controller Power Supply Logger
# Copyright 2019-2021, VR25
# License: GPLv3+


gather_ps_data() {
  local target=
  local target2=
  for target in $(ls -1 $1 | grep -Ev '^[0-9]|^block$|^dev$|^fs$|^ram$'); do
    if [ -f $1/$target ]; then
      echo $1/$target | grep -Ev 'logg|(/|_|-)log|at_pmrst' | grep -Eq 'batt|charg|power_supply' && {
        grep -q $1/$target $logsDir/ps-blacklist.log 2>/dev/null || {
          echo $1/$target >> $logsDir/ps-blacklist.log
          cat -v $1/$target 2>/dev/null | grep '\^\@' > /dev/null 2>&1 || {
            echo $1/$target
            sed 's#^#  #' $1/$target
            echo
          }
          sed -i "\|$1/$target|d" $logsDir/ps-blacklist.log
        }
      }
    elif [ -d $1/$target ]; then
      for target2 in $(find $1/$target \( \( -type f -o -type d \) \
        -a \( -ipath '*batt*' -o -ipath '*charg*' -o -ipath '*power_supply*' \) \) \
        -print 2>/dev/null | grep -Ev 'logg|(/|_|-)log|at_pmrst')
      do
        [ -f $target2 ] && {
          grep -q $target2 $logsDir/ps-blacklist.log 2>/dev/null || {
            echo $target2 >> $logsDir/ps-blacklist.log
            cat -v $target2 2>/dev/null | grep '\^\@' > /dev/null 2>&1 || {
              echo $target2
              sed 's#^#  #' $target2
              echo
            }
            sed -i "\|$target2|d" $logsDir/ps-blacklist.log
          }
        }
      done
    fi
  done
}


export TMPDIR=/dev/.vr25/acc
execDir=/data/adb/vr25/acc
logsDir=/data/adb/vr25/acc-data/logs

print_wait 2>/dev/null || echo "This may take a while..."


# log
exec 2> $logsDir/power-supply-logger.sh.log
set -x


. $execDir/setup-busybox.sh

{
  date
  echo accVerCode=$(sed -n s/versionCode=//p $execDir/module.prop)
  echo
  echo
  cat /proc/version 2>/dev/null || uname -a
  echo
  echo
  getprop | grep -E 'batt|charg|power_supply|product|version'
  echo
  echo
  gather_ps_data /sys
  echo
  gather_ps_data /proc
} > $logsDir/power_supply-$(getprop ro.product.device | grep .. || getprop ro.build.product).log

exit 0
