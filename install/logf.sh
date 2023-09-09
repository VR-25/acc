logf() {

  if tt "${1:-x}" "-*e*"; then

    mkdir -p $dataDir/logs

    exec 2>> ${log:-/dev/null}
    mkdir -p $TMPDIR/.logf
    cd $TMPDIR/.logf
    set +e

    $execDir/power-supply-logger.sh
    { parse_switches 2>/dev/null || $TMPDIR/acca --parse; } > acc-p.txt

    ln -f ../ch-switches charging-switches.txt
    ln -f ../oem-custom oem-custom.txt 2>/dev/null
    ln -f ../ch-curr-ctrl-files charging-current-ctrl-files.txt
    ln -f ../ch-volt-ctrl-files charging-voltage-ctrl-files.txt

    for file in /cache/magisk.log /data/cache/magisk.log; do
      [ -f $file ] && ln -sf $file ./ && break
    done

    ln -sf $dataDir/logs/* /sdcard/Download/acc-t_*.log ./ 2>/dev/null
    grep -Ev '^#|^$' $config_ > ./config.txt
    set +x

    . $execDir/batt-info.sh
    (cd /sys/class/power_supply/
    batt_info > $TMPDIR/.logf/acc-i.txt)
    dumpsys battery > dumpsys-battery.txt
    ln -f ../*.txt ../*.log ./ 2>/dev/null

    tar -hc *.log *.txt | gzip -9 > $dataDir/logs/acc-logs-$device.tgz
    rm -rf $TMPDIR/.logf 2>/dev/null

    cp -f $dataDir/logs/acc-logs-$device.tgz /sdcard/Download/ 2>/dev/null \
      && echo /sdcard/Download/acc-logs-$device.tgz \
      || echo $dataDir/logs/acc-logs-$device.tgz

    [ -z "${PS1-}" ] || {
      ! install -m 666 $dataDir/logs/acc-logs-$device.tgz /data/local/tmp/acc-logs-$device.tgz \
        || am start -a android.intent.action.SEND \
                    -t application/x-gtar-compressed \
                    --eu android.intent.extra.STREAM \
                    file:///data/local/tmp/acc-logs-$device.tgz
    } &>/dev/null </dev/null

  else
    if tt "${1:-x}" "-*a*"; then
      shift
      edit $log "$@"
    else
      edit $TMPDIR/accd-*.log "$@"
    fi
  fi
}
