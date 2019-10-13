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
  echo "(i) accd está em execução"
}

print_invalid_var() {
  echo "(!) Variavel inválida, [$var]"
}

print_config_reset() {
  echo "(i) A configuração padrão foi restaurada"
}

print_cs_reset() {
  echo "(i) Interruptor de carga definido como \"automático\""
}

print_supported_cs() {
  echo "(i) Interruptores de carga suportados"
}

print_cs_fails() {
  echo "(!) [$(get_value chargingSwitch)] não funciona"
}

print_invalid_cs() {
  echo "(!) Interruptor de carga inválido, [$(get_value chargingSwitch)]"
}

print_ch_disabled_until() {
  echo "(i) Recarga desativada até % <= $1"
}

print_ch_disabled_for() {
  echo "(i) Recarga desativada por $1"
}

print_ch_disabled() {
  echo "(i) Recarga desativada"
}

print_ch_enabled_until() {
  echo "(i) Recarga ativada até % >= $1"
}

print_ch_enabled_for() {
  echo "(i) Recarga ativada por $1"
}

print_ch_enabled() {
  echo "(i) Recarga ativada"
}


print_dvolt_restored() {
  echo "(i) Voltagem padrão ($(grep -o '^....' $file)mV) restaurada com sucesso"
}

print_dvolt_already_set() {
  echo "(i) A voltagem padrão já está definida"
}

print_invalid_input() {
  echo "(!) Entrada inválida, [$@]"
}

print_accepted_volt() {
  echo "- O intervalo permitido é 3500-4350 milivolts"
}

print_cvolt_set() {
  echo "(i) Voltagem limitada à $(grep -o '^....' $file)mV"
}

print_cvolt_unsupported() {
  echo "(!) [$(echo -n $file)] é o ficheiro errado ou o kernel não suporta alteração de voltagem"
}

print_no_such_file() {
  echo "(!) Ficheiro não encontrado, [$file]"
}

print_supported_cvolt_files() {
  echo "(i) Ficheiros controladores de voltagem suportados"
}

print_unplugged() {
  echo "(!) Conecte o carregador primeiro"
}

print_file_works() {
  echo "(i) [$file $on $off] funciona"
}

print_file_fails() {
  echo "(!) [$file $on $off] não funciona"
}

print_supported() {
  echo "(i) Este dispositivo é suportado"
}

print_unsupported() {
  echo "(!) Este dispositivo não é suportado"
}

print_no_modpath() {
  echo "(!) Diretório raíz não encontrado"
}

print_help() {
  cat << EOF
Advanced Charging Controller
Copyright (c) 2017-2019, VR25 (xda-developers.com)
Licença: GPLv3+
Código de versão: $(sed -n 's/versionCode=//p' $modPath/module.prop)

Uso: acc <-x|--xtrace> <opções> <argumentos>

-c|--config <editor [opções]>   Editar config com <editor [opções]> (predefinição: vim|vi)
  Exemplo: acc -c

-d|--disable <#%, #s, #m ou #h (opcional)>   Desativar recarga (com ou sem <condição>)
  Exemplos:
    acc -d 70% (do not recharge until capacity drops to 70%)
    acc -d 1h (do not recharge until 1 hour has passed)

-D|--daemon   Show current acc daemon (accd) state
  Exemplo: acc -D (alias: "accd,")

-D|--daemon <start|stop|restart>   Manage accd state
  Exemplos:
    acc -D restart
    accd -D stop (alias: "accd.")

-e|--enable <#%, #s, #m or #h (optional)>   Enable charging or enable charging with <condition>
  Exemplo: acc -e 30m (recharge for 30 minutes)

-f|--force|--full <capacity>   Charge to a given capacity (fallback: 100) once and uninterrupted
  Exemplo: acc -f 95

-i|--info   Show power supply info
  Exemplo: acc -i

-I|--lang   Show available, as well as the default and currently set languages
  e.g., acc -I

-l|--log <-a|--acc> <editor [opts]>   Open accd log (default) or acc log (-a) w/ <editor [opts]> (default: nano|vim|vi)
  e.g., acc -l grep ': ' (show explicit errors only)

-l|--log -e|--export   Export all logs to /sdcard/acc-logs-<device>.tar.bz2
  e.g., acc -l -e

-L|--logwatch   Monitor accd log in realtime
  Exemplo: acc -L

-P|--performance   Monitor de performance do accd (htop)
  e.g., acc -P

-r|--readme   Open <README.md> w/ <editor [opts]> (default: vim|vi)
  Exemplo: acc -r

-R|--resetbs   Reset battery stats
  Exemplo: acc -R

-s|--set   Show current config
  Exemplo: acc -s

-s|--set <r|reset>   Restaurar configuração padrão
  Exemplo acc -s r

-s|--set <var> <value>   Set config parameters (alternative: -s|--set <regexp> <value> (interactive))
  e.g.,
    acc -s capacity 5,60,80-85 (5: shutdown, 60: cool down, 80: resume, 85: pause)
    acc -s cool 55/15

-s|--set <resume-stop preset>   Can be 4041|endurance+, 5960|endurance, 7580|default, 8090|lite 9095|travel
  Exemplos:
    acc -s endurance+ (a.k.a, "the li-ion sweet spot"; best for GPS navigation and other long operations)
    acc -s travel (for when you need extra juice)
    acc -s 7580 (restore default capacity settings (5,60,75-80))

-s|--set <s|chargingSwitch>   Set a different charging switch from the database
  Exemplo: acc -s s

-s|--set <s:|chargingSwitch:>   List supported charging switches
  Exemplo: acc -s s:

-s|--set <s-|chargingSwitch->   Unset charging switch
  Exemplo: acc -s s-

-t|--test   Test currently set charging ctrl file
  Exit codes: 0 (works), 1 (doesn't work) or 2 (battery must be charging)
  e.g., acc -t

-t|--test <file on off>   Test custom charging ctrl file
  Exit codes: 0 (works), 1 (doesn't work) or 2 (battery must be charging)
  e.g., acc -t battery/charging_enabled 1 0

-t|--test -- <file (fallback: $modPath/switches.txt)>   Test charging switches from a file
  This will also report whether "battery idle" mode is supported
  Exit codes: 0 (works), 1 (doesn't work) or 2 (battery must be charging)
  e.g., acc -t -- /sdcard/experimental_switches.txt

-u|--upgrade [-c|--changelog] [-f|--force] [-n|--non-interactive] [reference]   Upgrade/downgrade
  e.g.,
    acc -u dev (upgrade to the latest dev version)
    acc -u (latest stable release)
    acc -u master^1 -f (previous stable release)
    acc -u -f dev^2 (two dev versions below the latest dev)
    acc -u 201905110 --force (version 2019.5.11)

-U|--uninstall

-v|--voltage   Show current charging voltage
  e.g., acc -v

-v|--voltage :   List available/default charging voltage ctrl files
  e.g., acc -v :

-v|--voltage -   Restore default charging voltage limit
  e.g., acc -v -

-v|--voltage <millivolts>   Set charging voltage limit (default/set ctrl file)
  e.g., acc -v 4100

-v|--voltage <file:millivolts>   Set charging voltage limit (custom ctrl file)
  e.g., acc -v battery/voltage_max:4100

-V|--version   Show acc version code
  e.g., acc -V

-x|--xtrace   Run in debug mode (verbose enabled)
  e.g., acc -x -t --

Tips

  Commands can be chained for extended functionality.
    e.g., acc -e 30m && acc -d 6h && acc -e 85 && accd (recharge for 30 minutes, halt charging for 6 hours, recharge to 85% capacity and restart daemon)

  Pause and resume capacities can also be set with acc <pause%> <resume%>.
    e.g., acc 85 80

  That last command can be used for programming charging before bed. In this case, the daemon must be running.
    e.g., acc 45 44 && acc --set applyOnPlug usb/current_max:500000 && sleep $((60*60*7)) && acc 80 75 && acc --set applyOnPlug usb/current_max:2000000
    - "Keep battery capacity at ~45% and limit charging current to 500mA for 7 hours. Restore regular charging settings afterwards."
    - For convenience, this can be written to a file and ran as "sh <file>".
    - If your device supports custom charging voltage, it's better to use it instead: "acc -v 3920 && sleep $((60*60*7)) && acc -v -".

Execute "acc --readme" para ler a documentação completa.
EOF
}

print_exit() {
  echo Sair
}

print_choice_prompt() {
  echo "(?) Introduza um número e clique [Enter]: "
}

print_auto() {
  echo Automático
}

print_default() {
 echo Predefinição
}

print_quit() {
  echo "(i) Pressione q para sair"
}

print_set_lang() {
    echo -e "\n(i) Execute \"acc -s lang STRING\" p/ mudar o idioma (exemplo: \"acc -s lang fr\")"
}

print_var_prompt() {
  echo "- Qual das variáveis? "
}
