logf() {

  if tt "${1:-x}" "-*e*"; then

    mkdir -p $dataDir/logs

    exec 2>> ${log:-/dev/null}
    cd $TMPDIR
    set +e

    $execDir/power-supply-logger.sh
    { parse_switches 2>/dev/null || ./acca --parse; } > acc-p.txt

    cp ch-switches charging-switches.txt
    cp oem-custom oem-custom.txt 2>/dev/null
    cp ch-curr-ctrl-files charging-current-ctrl-files.txt
    cp ch-volt-ctrl-files charging-voltage-ctrl-files.txt

    for file in /cache/magisk.log /data/cache/magisk.log; do
      [ -f $file ] && cp $file ./ && break
    done

    cp $dataDir/logs/* /sdcard/Download/acc-t_*.log ./ 2>/dev/null
    grep -Ev '^#|^$' $config_ > ./config.txt
    set +x

    . $execDir/batt-info.sh
    (cd /sys/class/power_supply/
    batt_info > $TMPDIR/acc-i.txt)
    dumpsys battery > dumpsys-battery.txt

    tar -c *.log *.txt | gzip -9 > $dataDir/logs/acc-logs-$device.tgz
    rm *.txt magisk.log in*.log power*.log 2>/dev/null
    echo "$dataDir/logs/acc-logs-$device.tgz"

  else
    if tt "${1:-x}" "-*a*"; then
      shift
      edit $log "$@"
    else
      edit $TMPDIR/accd-*.log "$@"
    fi
  fi
}
