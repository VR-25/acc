logf() {

  if [[ "${1:-x}" = -*e* ]]; then

    exec 2>> ${log:-/dev/null}
    cd $TMPDIR
    set +e

    $execDir/power-supply-logger.sh

    cp ch-switches charging-switches.txt
    cp oem-custom oem-custom.txt 2>/dev/null
    cp ch-curr-ctrl-files charging-current-ctrl-files.txt
    cp ch-volt-ctrl-files charging-voltage-ctrl-files.txt
    [ -d /data/app/mattecarra.accapp* ] && logcat -de mattecarra.accapp > mattecarra.accapp.log

    for file in /cache/magisk.log /data/cache/magisk.log; do
      [ -f $file ] && cp $file ./ && break
    done

    cp ${config_%/*}/logs/* ./
    grep -Ev '#|^$' $config_ > ./config.txt
    set +x

    . $execDir/batt-info.sh
    (cd /sys/class/power_supply/
    batt_info > $TMPDIR/acc-i.txt)
    dumpsys battery > dumpsys-battery.txt

    tar -c *.log *.txt \
      | gzip -9 > /data/media/0/acc-logs-$device.tar.gz

    chmod 0666 /data/media/0/acc-logs-$device.tar.gz
    rm *.txt magisk.log in*.log power*.log m*accapp.log 2>/dev/null
    echo "(i) /sdcard/acc-logs-$device.tar.gz"

  else
    if [[ "${1:-x}" = -*a* ]]; then
      shift
      edit $log "$@"
    else
      edit $TMPDIR/accd-*.log "$@"
    fi
  fi
}
