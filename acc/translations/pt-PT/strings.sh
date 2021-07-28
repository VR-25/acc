# Português, Portugal (pt-PT)

print_already_running() {
  echo "(i) accd já está em execução"
}

print_started() {
  echo "(i) accd foi iniciado"
}

print_stopped() {
  echo "(i) accd foi parado"
}

print_not_running() {
  echo "(i) accd não está em execução"
}

print_restarted() {
  echo "(i) accd foi reiniciado"
}

print_is_running() {
  echo "(i) accd $1 está em execução $2"
}

print_config_reset() {
  echo "(i) A configuração padrão foi restaurada"
}

print_known_switches() {
  echo "(i) Interruptores de carga suportados"
}

print_invalid_switch() {
  echo "(!) Interruptor de carga inválido, [${chargingSwitch[@]}]"
}

print_charging_disabled_until() {
  echo "(i) Recarga desativada até % <= $1"
}

print_charging_disabled_for() {
  echo "(i) Recarga desativada por $1"
}

print_charging_disabled() {
  echo "(i) Recarga desativada"
}

print_charging_enabled_until() {
  echo "(i) Recarga ativada até % >= $1"
}

print_charging_enabled_for() {
  echo "(i) Recarga ativada por $1"
}

print_charging_enabled() {
  echo "(i) Recarga ativada"
}

print_unplugged() {
  echo "(!) Conecte o carregador primeiro..."
}

print_switch_works() {
  echo "(i) [$@] funciona"
}

print_switch_fails() {
  echo "(!) [$@] não funciona"
}

print_not_found() {
  echo "(!) $1 não encontrado"
}

#print_help() {

print_exit() {
  echo "Sair"
}

print_choice_prompt() {
  echo "(?) Introduza um número e clique [enter]: "
}

print_auto() {
  echo "Automático"
}

print_default() {
 echo "Predefinição"
}

print_quit() {
  echo "(i) Pressione $1 para sair/guardar"
}

print_curr_restored() {
  echo "(i) Máxima corrente de recarga padrão restaurada"
}

print_volt_restored() {
  echo "(i) Máxima voltagem padrão de recarga restaurada"
}

print_read_curr() {
  echo "(i) Antes the prosseguir, o acc precisa obter os padrões máximos de corrente (I) de recarga"
  print_unplugged
  echo -n "- À espera..."
}

print_curr_set() {
  echo "(i) Máxima corrente (I) de recarga definida para $1 miliamperes"
}

print_volt_set() {
  echo "(i) Máxima voltagem de recarga definida para $1 milivolts"
}

print_curr_range() {
  echo "(!) Apenas [$1] (miliamperes)"
}

print_volt_range() {
  echo "(!) Apenas [$1] (milivolts)"
}
