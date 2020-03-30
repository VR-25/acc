logf() {
  if [[ "${1:-x}" == -*e* ]]; then
    set +eo pipefail 2>/dev/null
    cd $TMPDIR
    cp oem-custom oem-custom.txt 2>/dev/null
    cp charging-switches charging-switches.txt
    cp ch-curr-ctrl-files charging-current-ctrl-files.txt
    cp ch-volt-ctrl-files charging-voltage-ctrl-files.txt
    for file in /cache/magisk.log /data/cache/magisk.log; do
      [ -f $file ] && cp $file ./ && break
    done
    cp $config ${config%/*}/logs/* ./
    dumpsys battery > dumpsys-battery.txt
    acpi -V > acpi-V.txt
    tar -c *.log *.txt 2>/dev/null \
      | gzip -9 > /data/media/0/acc-logs-$device.tar.gz
    chmod 777 /data/media/0/acc-logs-$device.tar.gz
    rm *.txt magisk.log in*.log power*.log 2>/dev/null
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
