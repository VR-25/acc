# English (en)

print_already_running() {
  echo "(i) accd is already running"
}

print_started() {
  echo "(i) accd started"
}

print_stopped() {
  echo "(i) accd stopped"
}

print_not_running() {
  echo "(i) accd is not running"
}

print_restarted() {
  echo "(i) accd restarted"
}

print_is_running() {
  echo "(i) accd $1 is running $2"
}

print_config_reset() {
  echo "(i) Config reset"
}

print_known_switch() {
  echo "(i) Known charging switches"
}

print_switch_fails() {
  echo "(!) [${chargingSwitch[@]}] won't work"
}

print_invalid_switch() {
  echo "(!) Invalid charging switch, [${chargingSwitch[@]}]"
}

print_charging_disabled_until() {
  echo "(i) Charging disabled until battery capacity <= $1"
}

print_charging_disabled_for() {
  echo "(i) Charging disabled for $1"
}

print_charging_disabled() {
  echo "(i) Charging disabled"
}

print_charging_enabled_until() {
  echo "(i) Charging enabled until battery capacity >= $1"
}

print_charging_enabled_for() {
  echo "(i) Charging enabled for $1"
}

print_charging_enabled() {
  echo "(i) Charging enabled"
}

print_unplugged() {
  echo "(!) Battery must be charging"
}

print_switch_works() {
  echo "(i) [$@] works"
}

print_switch_fails() {
  echo "(!) [$@] won't work"
}

print_supported() {
  echo "(i) Supported device"
}

print_unsupported() {
  echo "(!) Unsupported device"
}

print_not_found() {
  echo "(!) $1 not found"
}


print_help() {
  cat << EOF
Advanced Charging Controller $accVer ($accVerCode)
(c) 2017-2020, VR25 (patreon.com/vr25)
GPLv3+

Usage

  acc [options] [args]
  .acc-en [options] [args] (for front-ends)
  acc [pause_capacity] [resume_capacity] (e.g., acc 75 70)

Options

  -c|--config [editor] [editor_opts]   Edit config (default editor: vim/vi)
    e.g.,
      acc -c (edit w/ vim/vi)
      acc -c nano -l$
      acc -c cat

  -d|--disable [#%, #s, #m or #h (optional)]   Disable charging
    e.g.,
      acc -d 70% (do not recharge until capacity <= 70%)
      acc -d 1h (do not recharge until 1 hour has passed)

  -D|--daemon   Print daemon status, (and if running) version and PID
    e.g., acc -D (alias: "accd,")

  -D|--daemon [start|stop|restart]   Manage daemon
    e.g.,
      acc -D start (alias: accd)
      acc -D restart (alias: accd)
      accd -D stop (alias: "accd.")

  -e|--enable [#%, #s, #m or #h (optional)]   Enable charging
    e.g.,
      acc -e 75% (recharge to 75%)
      acc -e 30m (recharge for 30 minutes)

  -f|--force|--full [capacity]   Charge to a given capacity (default: 100) once and uninterrupted
    e.g.,
      acc -f 95 (charge to 95%)
      acc -f (charge to 100%)

  -F|--flash ["zip_file"]   Flash any zip file whose update-binary is a shell script
    e.g.,
      acc -F (lauches a zip picking wizard)
      acc -F "/sdcard/Download/Magisk-v20.0(20000).zip"

  -i|--info [case insentive egrep regex (default: ".")]   Show battery info
    e.g.,
      acc -i
      acc -i volt
      acc -i 'volt\|curr'

  -l|--log [-a|--acc] [editor] [editor_opts]>   Print/edit accd log (default) or acc log (-a|--acc) (default editor: vim/vi
    e.g.,
      acc -l
      acc -l -a cat
      acc -l grep ': ' (show explicit errors only)

  -la   Same as -l -a

  -l|--log -e|--export   Export all logs to /sdcard/acc-logs-\$deviceName.tar.gz
    e.g., acc -l -e

  -le   Same as -l -e

  -p|--performance   Monitor accd resources usage (htop)
    e.g., acc -p

  -r|--readme   Display README.md (default editor: vim/vi)
    e.g.,
      acc -r
      acc -r cat

  -R|--resetbs   Reset battery stats
    e.g., acc -R

  -s|--set   Print current config
    e.g., acc -s

  -s|--set prop1=value "prop2=value1 value2"   Set [multiple] properties
    e.g.,
      acc -s charging_switch=
      acc -s pause_capacity=60 resume_capacity=55 (shortcuts: acc -s pc=60 rc=55, acc 60 55)
      acc -s "charging_switch=battery/charging_enabled 1 0" resume_capacity=55 pause_capacity=60
    Note: all properties have short aliases for faster typing; run "acc -c cat" to see these

  -s|--set c|--current [-]   Set/print/restore_default max charging current ($(print_mA))
    e.g.,
      acc -s c (print)
      acc -s c 500 (set)
      acc -s c - (restore default)

  -s|--set l|--lang   Change language
    e.g., acc -s l

  -s|--set d|--print-default [egrep regex (default: ".")]   Print default config without blank lines
    e.g.,
      acc -s d (print entire defaul config)
      acc -s d cap (print only entries matching "cap")

  -s|--set p|--print [egrep regex (default: ".")]   Print current config without blank lines (refer to previous examples)

  -s|--set r|--reset   Restore default config
    e.g., acc -s r

  -s|--set s|charging_switch   Enforce a specific charging switch
    e.g., acc -s s

  -s|--set s:|chargingSwitch:   List known charging switches
    e.g., acc -s s:

  -s|--set v|--voltage [-] [--exit]   Set/print/restore_default max charging voltage ($(print_mV))
    e.g.,
      acc -s v (print)
      acc -s v 3920 (set)
      acc -s v - (restore default)
      acc -s v 3920 --exit (stop the daemon after applying settings)

  -t|--test   Test charging control (on/off)
    e.g., acc -t

  -t|--test [file on off file2 on off]   Test custom charging switches
    e.g.,
      acc -t battery/charging_enabled 1 0
      acc -t /proc/mtk_battery_cmd/current_cmd 0::0 0::1 /proc/mtk_battery_cmd/en_power_path 1 0 ("::" == " ")

  -t|--test -- [file]   Test charging switches from a file (default: $TMPDIR/charging-switches)
    This will also report whether "battery idle" mode is supported
    e.g.,
      acc -t -- (test known switches)
      acc -t -- /sdcard/experimental_switches.txt (test custom/foreign switches)

  -T|--logtail   Monitor accd log (tail -F)
    e.g., acc -T

  -u|--upgrade [-c|--changelog] [-f|--force] [-n|--non-interactive]   Upgrade/downgrade
    e.g.,
      acc -u dev (upgrade to the latest dev version)
      acc -u (latest stable release)
      acc -u master^1 -f (previous stable release)
      acc -u -f dev^2 (two dev versions below the latest dev)
      acc -u 201905110 --force (version 2019.5.11)

  -U|--uninstall   Completelly remove acc and AccA
    e.g., acc -U

  -v|--version   Print acc version and version code
    e.g., acc -v

Tips

  Commands can be chained for extended functionality.
    e.g., acc -e 30m && acc -d 6h && acc -e 85 && accd (recharge for 30 minutes, halt charging for 6 hours, recharge to 85% capacity and restart the daemon)

  Programming charging before going to sleep...
    acc 45 43 && acc -s c 500 && sleep \$((60*60*7)) && acc 80 75 && acc -s c -
      - "Keep battery capacity bouncing between 43-45% and limit charging current to 500 mA for 7 hours. Restore regular charging settings afterwards."
      - For convenience, this can be written to a file and ran as "sh /path/to/file".
      - If the kernel supports custom max charging voltage, it's best to use that feature over the above chain, like so: "acc -s v 3920 && sleep \$((60*60*7)) && acc -s v -".

Run acc -r (or --readme) to see the full documentation.
EOF
}


print_exit() {
  echo "Exit"
}

print_choice_prompt() {
  echo "(?) Choice, [enter]: "
}

print_auto() {
  echo "Automatic"
}

print_default() {
 echo "Default"
}

print_quit() {
  echo "(i) Press $1 to quit"
}

print_curr_restored() {
  echo "(i) Default max charging current restored"
}

print_volt_restored() {
  echo "(i) Default max charging voltage restored"
}

print_read_curr() {
  echo "(i) Need to read default max charging current value(s) first"
  print_unplugged
  echo -n "- Waiting... (press CTRL-C to abort)"
}

print_curr_set() {
  echo "(i) Max charging current set to $1 $(print_mA)"
}

print_volt_set() {
  echo "(i) Max charging voltage set to $1 $(print_mV)"
}

print_curr_range() {
  echo "(!) [$1] ($(print_mA)) only"
}

print_volt_range() {
  echo "(!) [$1] ($(print_mV)) only"
}

print_wip() {
  echo "(i) Work in progress"
  echo "- Run acc -h or -r for help"
}

print_press_enter() {
  echo -n "(i) Press [enter] to continue..."
}

print_lang() {
  echo "Language"
}

print_doc() {
  echo "Documentation"
}

print_cmds() {
  echo "All commands"
}

print_re_start_daemon() {
  echo "Start/restart daemon"
}

print_stop_daemon() {
  echo "Stop daemon"
}

print_export_logs() {
  echo "Export logs"
}

print_1shot() {
  echo "Charge once to a given level (default: 100%), without other restrictions"
}

print_charge_once() {
  echo "Charge once to #%"
}

print_mA() {
  echo "milliamps"
}

print_mV() {
  echo "millivolts"
}

print_uninstall() {
  echo "Uninstall"
}

print_edit() {
  echo "Edit $1"
}

print_flash_zip() {
  echo "Fash zip"
}

print_reset_bs() {
  echo "Reset battery stats"
}

print_test_cs() {
  echo "Test charging switches"
}

print_update() {
  echo "Check for update"
}
