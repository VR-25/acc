apply_on_boot() {

  local entry="" file="" value="" default="" arg=${1:-value} exitCmd=false force=false

  [ ${2:-x} != force ] || force=true
 
  [[ "${applyOnBoot[@]:-x}${maxChargingVoltage[@]-}" != *--exit* ]] || exitCmd=true

  for entry in "${applyOnBoot[@]-}" "${maxChargingVoltage[@]-}"; do
    [ "$entry" != --exit ] || continue
    set -- ${entry//::/ }
    file=${1-}
    value=${2-}
    { $exitCmd && ! $force; } && default=${2-} || default=${3:-${2-}}
    [ -f "$file" ] && chmod +w $file && eval "echo \$$arg" > $file || :
  done

  $exitCmd && [ $arg == value ] && exit 0 || :
}
