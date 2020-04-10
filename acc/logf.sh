logf() {

  if [[ "${1:-x}" == -*e* ]]; then

    exec 2>> ${log:-/dev/null}
    set +eo pipefail
    cd $TMPDIR

    cp oem-custom oem-custom.txt
    cp ch-switches charging-switches.txt
    cp ch-curr-ctrl-files charging-current-ctrl-files.txt
    cp ch-volt-ctrl-files charging-voltage-ctrl-files.txt

    for file in /cache/magisk.log /data/cache/magisk.log; do
      [ -f $file ] && cp $file ./ && break
    done

    cp $config_ ${config_%/*}/logs/* ./
    set +x
    . $modPath/batt-info.sh
    batt_info > acc-i.txt
    dumpsys battery > dumpsys-battery.txt

    tar -c *.log *.txt \
      | gzip -9 > /data/media/0/acc-logs-$device.tar.gz

    chmod 777 /data/media/0/acc-logs-$device.tar.gz
    rm *.txt magisk.log in*.log power*.log

    $isAccd || echo "(i) /sdcard/acc-logs-$device.tar.gz"

  else
    if [[ "${1:-x}" == -*a* ]]; then
      shift
      edit $log "$@"
    else
      edit $TMPDIR/accd-*.log "$@"
    fi
  fi
}
