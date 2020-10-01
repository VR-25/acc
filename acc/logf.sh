logf() {

  if [[ "${1:-x}" = -*e* ]]; then

    exec 2>> ${log:-/dev/null}
    cd $TMPDIR
    set +e

    $execDir/power-supply-logger.sh

    dmesg > dmesg.txt

    cp ch-switches charging-switches.txt
    cp oem-custom oem-custom.txt 2>/dev/null
    cp ch-curr-ctrl-files charging-current-ctrl-files.txt
    cp ch-volt-ctrl-files charging-voltage-ctrl-files.txt

    [ -d /data/app/mattecarra.accapp* ] \
      && logcat -de mattecarra.accapp > mattecarra.accapp.log

    for file in /cache/magisk.log /data/cache/magisk.log; do
      [ -f $file ] && cp $file ./ && break
    done

    data_dir=/sdcard/vr25/acc
    mkdir -p $data_dir

    cp $data_dir/logs/* ./ 2>/dev/null
    grep -Ev '^#|^$' $config_ > ./config.txt
    set +x

    . $execDir/batt-info.sh
    (cd /sys/class/power_supply/
    batt_info > $TMPDIR/acc-i.txt)
    dumpsys battery > dumpsys-battery.txt

    tar -c *.log *.txt \
      | bzip2 -9 > $data_dir/logs/acc-logs-$device.tar.bz2

    rm *.txt magisk.log in*.log power*.log m*accapp.log 2>/dev/null
    echo "(i) $data_dir/logs/acc-logs-$device.tar.bz2"

  else
    if [[ "${1:-x}" = -*a* ]]; then
      shift
      edit $log "$@"
    else
      edit $TMPDIR/accd-*.log "$@"
    fi
  fi
}
