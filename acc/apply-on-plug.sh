apply_on_plug() {
  local entry="" file="" value="" default="" arg=${1:-value}
  for entry in "${applyOnPlug[@]-}" "${maxChargingCurrent[@]-}"; do
    set -- ${entry//::/ }
    file=${1-}
    value=${2-}
    default=${3:-${2-}}
    [ -f "$file" ] && chmod +w $file && eval "echo \$$arg" > $file || :
  done
}
