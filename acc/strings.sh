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

print_known_switches() {
  echo "(i) Known charging switches"
}

print_invalid_switch() {
  echo "(!) Invalid charging switch, [${chargingSwitch[@]-}]"
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
  echo "(!) Charger must be plugged to continue..."
}

print_switch_works() {
  echo "(i) [$@] works"
}

print_switch_fails() {
  echo "(!) [$@] won't work"
}

print_no_ctrl_file() {
  echo "(!) No control file found"
}

print_not_found() {
  echo "(!) $1 not found"
}


print_help() {
  cat << EOF
Usage

  acc   Wizard

  accd   Start/restart accd

  accd.   Stop acc/daemon

  accd,   Print acc/daemon status (running or not)

  acc [pause_capacity/millivolts [resume_capacity/millivolts, default: pause_capacity/millivolts - 5%/50mV]]
    e.g.,
      acc 75 70
      acc 80 (resume_capacity defaults to 80% - 5)
      acc 3920 (same as acc 3920 3870, great idle mode alternative)

  acc [options] [args]   Refer to the list of options below

  acca [options] [args]   acc optimized for front-ends

  acc[d] -x [options] [args]   Sets log=/sdcard/acc[d]-\${device}.log; useful for debugging unwanted reboots

  A custom config path can be specified as first parameter (second if -x is used).
  If the file doesn't exist, the current config is cloned.
    e.g.,
      acc /data/acc-night-config.txt --set pause_capacity=45 resume_capacity=43
      acc /data/acc-night-config.txt --set --current 500
      accd /data/acc-night-config.txt


Options

  -b|--rollback   Undo upgrade

  -c|--config [editor] [editor_opts]   Edit config (default editor: nano/vim/vi)
    e.g.,
      acc -c (edit w/ nano/vim/vi)
      acc -c less
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

  -f|--force|--full [capacity]   Charge once to a given capacity (default: 100%), without restrictions
    e.g.,
      acc -f 95 (charge to 95%)
      acc -f (charge to 100%)
    Note: if the desired % is less than pause_capacity, use acc -e #%

  -F|--flash ["zip_file"]   Flash any zip files whose update-binary is a shell script
    e.g.,
      acc -F (lauches a zip flashing wizard)
      acc -F "file1" "file2" "fileN" ... (install multiple zips)
      acc -F "/sdcard/Download/Magisk-v20.0(20000).zip"

  -i|--info [case insensitive egrep regex (default: ".")]   Show battery info
    e.g.,
      acc -i
      acc -i volt
      acc -i 'volt\|curr'

  -l|--log [-a|--acc] [editor] [editor_opts]   Print/edit accd log (default) or acc log (-a|--acc)
    e.g.,
      acc -l (same as acc -l less)
      acc -l rm
      acc -l -a cat
      acc -l grep ': ' (show explicit errors only)

  -la   Same as -l -a

  -l|--log -e|--export   Export all logs to /data/adb/vr25/acc-data/logs/acc-logs-\$deviceName.tar.gz
    e.g., acc -l -e

  -le   Same as -l -e

  -p|--parse [<base file> <file to parse>]|[file to parse]   Helps find potential charging switches quickly, for any device
    e.g.,
      acc -p   Parse $dataDir/logs/power_supply-\*.log and print potential charging switches not present in $TMPDIR/ch-switches
      acc -p /sdcard/power_supply-harpia.log   Parse the given file and print potential charging switches that are not already in $TMPDIR/ch-switches
      acc -p /sdcard/charging-switches.txt /sdcard/power_supply-harpia.log   Parse /sdcard/power_supply-harpia.log and print potential charging switches absent from /sdcard/charging-switches.txt

  -r|--readme [editor] [editor_opts]   Print/edit README.md
    e.g.,
      acc -r (same as acc -r less)
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

  -s|--set c|--current [milliamps|-]   Set/print/restore_default max charging current (range: 0-9999$(print_mA))
    e.g.,
      acc -s c (print current limit)
      acc -s c 500 (set)
      acc -s c - (restore default)

  -sc [milliamps|-]   Same as above

  -s|--set l|--lang   Change language
    e.g., acc -s l

  -sl   Same as above

  -s|--set d|--print-default [egrep regex (default: ".")]   Print default config without blank lines
    e.g.,
      acc -s d (print entire defaul config)
      acc -s d cap (print only entries matching "cap")

  -sd [egrep regex (default: ".")]   Same as above

  -s|--set p|--print [egrep regex (default: ".")]   Print current config without blank lines (refer to previous examples)

  -sp [egrep regex (default: ".")]   Same as above

  -s|--set r|--reset   Restore default config
    e.g.,
      acc -s r
      rm /data/adb/vr25/acc-data/config.txt (failsafe)

  -sr   Same as above

  -s|--set s|charging_switch   Enforce a specific charging switch
    e.g., acc -s s

  -ss    Same as above

  -s|--set s:|chargingSwitch:   List known charging switches
    e.g., acc -s s:

  -ss:   Same as above

  -s|--set v|--voltage [millivolts|-] [--exit]   Set/print/restore_default max charging voltage (range: 3700-4300$(print_mV))
    e.g.,
      acc -s v (print)
      acc -s v 3920 (set)
      acc -s v - (restore default)
      acc -s v 3920 --exit (stop the daemon after applying settings)

  -sv [millivolts|-] [--exit]   Same as above

  -t|--test [ctrl_file1 on off [ctrl_file2 on off]]   Test custom charging switches
    e.g.,
      acc -t battery/charging_enabled 1 0
      acc -t /proc/mtk_battery_cmd/current_cmd 0::0 0::1 /proc/mtk_battery_cmd/en_power_path 1 0 ("::" is a placeholder for " " - MTK only)

  -t|--test [file]   Test charging switches from a file (default: /dev/.vr25/acc/ch-switches)
    Control files that trigger reboots or kernel panics are automatically backlisted
    e.g.,
      acc -t (test known switches)
      acc -t /sdcard/experimental_switches.txt (test custom/foreign switches)

  -T|--logtail   Monitor accd log (tail -F)
    e.g., acc -T

  -u|--upgrade [-c|--changelog] [-f|--force] [-k|--insecure] [-n|--non-interactive]   Online upgrade/downgrade (requires curl)
    e.g.,
      acc -u dev (upgrade to the latest dev version)
      acc -u (latest version from the current branch)
      acc -u master^1 -f (previous stable release)
      acc -u -f dev^2 (two dev versions below the latest dev)
      acc -u v2020.4.8-beta --force (force upgrade/downgrade to v2020.4.8-beta)
      acc -u -c -n (if update is available, prints version code (integer) and changelog link)
      acc -u -c (same as above, but with install prompt)

  -U|--uninstall   Completely remove acc and AccA
    e.g., acc -U

  -v|--version   Print acc version and version code
    e.g., acc -v

  -w#|--watch#   Monitor battery uevent
    e.g.,
      acc -w (update info every 3 seconds)
      acc -w0.5 (update info every half a second)
      acc -w0 (no extra delay)


Exit Codes

  0. True/success
  1. False or general failure
  2. Incorrect command syntax
  3. Missing busybox binary
  4. Not running as root
  5. Update available ("--upgrade")
  6. No update available ("--upgrade")
  7. Failed to disable charging
  8. Daemon already running ("--daemon start")
  9. Daemon not running ("--daemon" and "--daemon stop")
  10. "--test" failed
  11. Current (mA) out of 0-9999 range
  12. Initialization failed
  13. Failed to lock /dev/.vr25/acc/acc.lock
  14. ACC wont initialize because the Magisk module disable flag is set

  Logs are exported automatically ("--log --export") on exit codes 1, 2, 7 and 10.


Tips

  Commands can be chained for extended functionality.
    e.g., charge for 30 minutes, pause charging for 6 hours, charge to 85% and restart the daemon
    acc -e 30m && acc -d 6h && acc -e 85 && accd

  Sample profile
    acc -s pc=45 rc=43 mcc=500 mcv=3920
      This keeps battery capacity between 43-45%, limits charging current to 500 mA and voltage to 3920 millivolts.
      It's great for nighttime and "forever-plugged".

  Refer to acc -r (or --readme) for the full documentation (recommended)
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
  echo "(i) Press $1 to abort/quit"
  [ -z "${2-}" ] || echo "- Or $2 to save and quit"
}

print_curr_restored() {
  echo "(i) Default max charging current restored"
}

print_volt_restored() {
  echo "(i) Default max charging voltage restored"
}

print_read_curr() {
  echo "(i) Need to read default max charging current value(s) first"
}

print_curr_set() {
  echo "(i) Max charging current set to $1$(print_mA)"
}

print_volt_set() {
  echo "(i) Max charging voltage set to $1$(print_mV)"
}

print_wip() {
  echo "(!) Invalid option"
  echo "- Run acc -h or -r for help"
}

print_press_key() {
  printf "(i) Press any key to continue..."
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
  echo "Charge once to a given capacity (default: 100%), without restrictions"
}

print_charge_once() {
  echo "Charge once to #%"
}

print_mA() {
  echo " Milliamps"
}

print_mV() {
  echo " Millivolts"
}

print_uninstall() {
  echo "Uninstall"
}

print_edit() {
  echo "Edit $1"
}

print_flash_zips() {
  echo "Flash zips"
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

print_W() {
  echo " Watts"
}

print_V() {
  echo " Volts"
}

print_available() {
  echo "(i) $@ is available"
}

print_install_prompt() {
  printf "- Should I download and install it ([enter]: yes, CTRL-C: no)? "
}

print_no_update() {
  echo "(i) No update available"
}

print_A() {
  echo " Amps"
}

print_only() {
  echo "only"
}

print_wait() {
  echo "(i) This may take a minute or so..."
}

print_as_warning() {
  echo "WARNING: I'll shutdown the system at ${1}% battery if you don't plug the charger!"
}

print_i() {
  echo "Battery info"
}

print_undo() {
  echo "Undo upgrade"
}

print_blacklisted() {
  echo "(i) [$@] is blacklisted; won't be tested"
}
