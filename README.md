# Advanced Charging Controller (ACC)



---
## LEGAL

Copyright (c) 2017-2020, VR25 (patreon.com/vr25)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.



---
## DISCLAIMER

Always read/reread this reference prior to installing/upgrading this software.

While no cats have been harmed, the author assumes no responsibility for anything that might break due to the use/misuse of it.

To prevent fraud, do NOT mirror any link associated with this project; do NOT share builds (zips/tarballs)! Share official links instead.



---
## WARNING

ACC manipulates Android low level ([kernel](https://duckduckgo.com/?q=kernel+android)) parameters which control the charging circuitry.
The author assumes no responsibility under anything that might break due to the use/misuse of this software.
By choosing to use/misuse ACC, you agree to do so at your own risk!



---
## DESCRIPTION

ACC is an Android software mainly intended for [extending battery service life](https://batteryuniversity.com/learn/article/how_to_prolong_lithium_based_batteries).
In a nutshell, this is achieved through limiting charging current, temperature and voltage.
Any root solution is supported. A recent stable Magisk version is recommended.



---
## PREREQUISITES

- [Must read - how to prolong lithium ion batteries lifespan](https://batteryuniversity.com/index.php/learn/article/how_to_prolong_lithium_based_batteries/)
- Android or Android based OS
- Any root solution (e.g., [Magisk](https://github.com/topjohnwu/Magisk/))
- [Busybox*](https://github.com/search?o=desc&q=busybox+android&s=updated&type=Repositories/) (only if not rooted with Magisk)
- Terminal emulator (recommended: [Termux](https://f-droid.org/en/packages/com.termux/))
- [curl**](https://github.com/search?o=desc&q=curl+android&s=updated&type=Repositories/) (for acc --upgrade)
- Text editor (optional)

\* Instead of a regular install, the binary can simply be placed in /data/adb/.
That's a fallback path. ACC sets permissions (rwx------) as needed.
Precedence: Magisk busybox > system busybox > /data/adb/busybox

\*\* The Magisk module [Cross Compiled Binaries (ccbins)](https://github.com/Magisk-Modules-Repo/ccbins/) installs `curl`.



---
## QUICK START GUIDE

0. All commands/actions require root.
Avoid using `su -c`, `sudo`, `tsudo` or similar.
On Android, these are not as reliable as the plain old `su`.

1. Unless Magisk is not installed, always install/upgrade from Magisk Manager or ACC front-end (e.g. AccA).
Apps such as EX/Franco Kernel Managers are also good options.
There are yet two more ways of upgrading: `acc -u` (online) and `acc -F` (zip flasher).
Rebooting after installation/removal is unnecessary.

2.  [Optional] run `acc` (wizard). That's the only command you need to remember.

3. [Optional] run `acc pause_capacity resume_capacity` (default `75 70`) to set the battery levels at which charging should pause and resume, respectively.

4. If you come across any issues, refer to the `TROUBLESHOOTING`, `TIPS` and `FAQ` sections below.
Read as much as you can before contacting the developer or opening issues on GitHub.
Oftentimes, solutions will be right before your eyes.


### Notes

- ACC _cannot_ be installed/upgraded from recovery (e.g., TWRP).

- Steps `2` and `3` are optional because there are default settings.
For details, refer to the `DEFAULT CONFIGURATION` section below.
Users are encouraged to try step `2` - to familiarize themselves with the available options.

- Settings can be overwhelming. Start with what you understand.
The default configuration has you covered.
Don't ever feel like you have to configure everything. You probably shouldn't anyway - unless you really know what you're doing.

- Uninstall: depending on the installed variant (e.g., app back-end or Magisk module), you can use Magisk Manager (app), [Magisk Manager for Recovery Mode (utility)](https://github.com/VR-25/mm/) - or uninstall the front-end app (or clear its data) after stopping accd.
Two universal methods are: `acc --uninstall` and `/sdcard/acc-uninstaller.zip` (flashable uninstaller).



---
## BUILDING AND/OR INSTALLING FROM SOURCE


### Dependencies

- git, wget, or curl
- zip


### Build Tarballs and Flashable Zips

1. Download and extract the source code: `git clone https://github.com/VR-25/acc.git` or `wget  https://github.com/VR-25/acc/archive/master.tar.gz -O - | tar -xz` or `curl -L#  https://github.com/VR-25/acc/archive/master.tar.gz | tar -xz`

2. `cd acc*`

3. `sh build.sh` (or double-click `build.bat` on Windows 10, if you have Windows subsystem for Linux (with zip) installed)


#### Notes

- build.sh automatically sets/corrects `id=*` in `*.sh` and `update-binary` files.

- The output files are (in `_builds/acc-$versionCode/`): `acc-$versionCode.zip`, `acc-$versionCode.tar.gz`, and `install-tarball.sh`.

- To update the local source code, run `git pull --force` or re-download (with wget/curl) as described above.


### Install from Local Sources and GitHub

- `sh install-tarball.sh acc` installs the tarball (acc*gz) from the script's location.
The archive must be obtained from GitHub: https://github.com/VR-25/acc/archive/$reference.tar.gz ($reference examples: master, dev, 201908290).

- `sh install.sh` installs acc from the extracted source.

- `sh install-online.sh [-c|--changelog] [-f|--force] [-k|--insecure] [-n|--non-interactive] [%install dir%] [reference]` downloads and installs acc from GitHub. e.g., `sh install-online.sh dev`


#### Notes

- `install.sh` and `install-tarball.sh` take an optional _parent installation directory_ argument (e.g., sh install.sh /data - this will install acc in /data/acc/).

- `install-online.sh` is the `acc --upgrade` back-end.

- The order of arguments doesn't matter.

- The default parent installation directories, in order of priority, are: `/data/data/mattecarra.accapp/files/`, `/sbin/.magisk/modules/` and `/data/adb/`.

- No argument/option is strictly mandatory. The exception is `--non-interactive` for front-end apps.
Unofficially supported front-ends must specify the parent installation directory. Otherwise, the installer will follow the order above.

- Remember that unlike the other two installers, `install-online.sh` requires the _parent installation directory_ to be enclosed in `%` (e.g., sh install-online.sh %/data% --non-interactive).

- The `--force` option to install-online.sh is meant for re-installation and downgrading.

- `sh install-online.sh --changelog --non-interactive` prints the version code (integer) and changelog URL (string) when an update is available.
In interactive mode, it also asks the user whether they want to download and install the update.

- You may also want to read `NOTES/TIPS FOR FRONT-END DEVELOPERS > Exit Codes` below.



---
## DEFAULT CONFIGURATION
```
#DC#

configVerCode=202004040
capacity=(-1 60 70 75 +0 false)
temperature=(70 80 90)
cooldownCurrent=()
cooldownRatio=()
resetBattStats=(false false)
loopDelay=(10 15)
chargingSwitch=()
applyOnBoot=()
applyOnPlug=()
maxChargingCurrent=()
maxChargingVoltage=()
rebootOnPause=
switchDelay=1.5
language=en
wakeUnlock=()
prioritizeBattIdleMode=false
forceChargingStatusFullAt100=
runCmdOnPause=()
dynPowerSaving=0
vibrationPatterns=(5 0.1 5 0.1 4 0.1 6 0.1 3 0.1)


# WARNINGS

# As seen above, whatever is null can be null.
# Nullifying values that should not be null causes nasty errors.

# Do NOT feel like you must configure everything!
# If you don't know EXACTLY how to and why you want to do it, it's a very dumb idea.
# Help is always avaliable, from multiple sources - plus, you don't have to pay a penny for it.


# BASIC CONFIG EXPLANATION

# capacity=(shutdown_capacity cooldown_capacity resume_capacity pause_capacity capacity_offset capacity_sync)

# temperature=(cooldown_temp max_temp max_temp_pause)

# cooldownCurrent=cooldown_current=(file raw_current charge_seconds pause_seconds)

# cooldownRatio=(cooldown_charge cooldown_pause)

# resetBattStats=(reset_batt_stats_on_pause reset_batt_stats_on_unplug)

# loopDelay=(loop_delay_charging loop_delay_discharging)

# chargingSwitch=charging_switch=(ctrl_file1 on off ctrl_file2 on off)

# applyOnBoot=apply_on_boot=(ctrl_file1::value1::default1 ctrl_file2::value2::default2 ... --exit)

# applyOnPlug=apply_on_plug=(ctrl_file1::value1::default1 ctrl_file2::value2::default2 ...)

# maxChargingCurrent=max_charging_current=([value] ctrl_file1::value::default1 ctrl_file2::value::default2 ...)

# maxChargingVoltage=max_charging_voltage=([value] ctrl_file1::value::default1 ctrl_file2::value::default2 ...) --exit)

# rebootOnPause=reboot_on_pause=seconds

# switchDelay=switch_delay=seconds

# language=lang=language_code

# wakeUnlock=wake_unlock=(wakelock1 wakelock2 ...)

# prioritizeBattIdleMode=prioritize_batt_idle_mode=true/false

# forceChargingStatusFullAt100=force_charging_status_full_at_100=status_code

# runCmdOnPause=run_cmd_on_pause=(. script)

# dynPowerSaving=dyn_power_saving=seconds

# vibrationPatterns=vibration_patterns=(auto_shutdown_warning_vibrations interval calibration_vibrations interval enable_charging_vibrations interval error_vibrations interval disable_charging_vibrations interval)


# VARIABLE ALIASES/SORTCUTS

# sc shutdown_capacity
# cc cooldown_capacity
# rc resume_capacity
# pc pause_capacity
# co capacity_offset
# cs capacity_sync

# ct cooldown_temp
# mt max_temp
# mtp max_temp_pause

# ccu cooldown_current

# cch cooldown_charge
# cp cooldown_pause

# rbsp reset_batt_stats_on_pause
# rbsu reset_batt_stats_on_unplug

# ldc loop_delay_charging
# ldd loop_delay_discharging

# s charging_switch

# ab apply_on_boot
# ap apply_on_plug

# mcc max_charging_current
# mcv max_charging_voltage

# rp reboot_on_pause
# sd switch_delay
# l lang
# wu wake_unlock
# pbim prioritize_batt_idle_mode
# ff force_charging_status_full_at_100
# rcp run_cmd_on_pause
# dps dyn_power_saving
# vp vibration_patterns


# COMMAND EXAMPLES

# acc 85 80
# acc -s rc=80 pc=85
# acc --set resume_capacity=80 pause_capacity=85

# acc -s "s=battery/charging_enabled 1 0"
# acc --set "charging_switch=/proc/mtk_battery_cmd/current_cmd 0::0 0::1 /proc/mtk_battery_cmd/en_power_path 1 0" ("::" == " ")

# acc -s sd=5
# acc -s switch_delay=5

# acc -s -v 3920 (millivolts)
# acc -s -c 500 (milliamps)

# custom config path
# acc /data/acc-night-config.txt 45 43
# acc /data/acc-night-config.txt -s c 500
# accd /data/acc-night-config.txt

# acc -s "ccu=battery/current_now 1450000 100 20"
# acc -s "cooldown_current=battery/current_now 1450000 100 20"

# acc -s vp="5 0.1 4 0.1 6 0.1 3 0.1"
# acc -s vp="5 0.1 - - 6 0.1 - -" # disables vibration for charging enabled/disabled events.


# FINE, BUT WHAT DOES EACH OF THESE VARIABLES ACTUALLY MEAN?

# configVerCode #
# This is checked during updates to determine whether config should be patched. Do NOT modify.

# shutdown_capacity (sc) #
# When the battery is discharging and its capacity <= sc, acc daemon turns the phone off to reduce the discharge rate and protect the battery from potential damage induced by voltages below the operating range.
# On capacity <= shutdown_capacity + 5, accd enables Android battery saver, triggers 5 vibrations once - and again on each subsequent capacity drop.

# cooldown_capacity (cc) #
# Capacity at which the cooldown cycle starts.
# Cooldown reduces battery stress induced by prolonged exposure to high temperature and high charging voltage.
# It does so through periodically pausing charging for a few seconds (more details below).

# resume_capacity (rc) #
# Capacity at which charging should resume.

# pause_capacity (pc) #
# Capacity at which charging should pause.

# capacity_offset (co) #
# Change this only if your system reports incorrect battery capacity ("acc -i" (BMS) vs "dumpsys battery" (Android system)).
# Pixel devices are know for having this issue.

# capacity_sync (cs) #
# This is an alternative to capacity_offset.
# It tells accd whether the battery capacity reported by Android should be updated every few seconds to reflect the actual value from the battery management system.
# Most users would prefer this over capacity_offset.
# It's more powerful, but has a cosmetic nuisance: small delays (seconds) in charging status reports.
# Such inconvenience is not a bug, nor can it be eliminated at this point.
# accd manages this setting dynamically.

# cooldown_temp (ct) #
# Temperature (°C) at which the cooldown cycle starts.
# Cooldown reduces the battery degradation rate by lowering the device's temperature.
# Refer back to cooldown_capacity for more details.

# max_temp (mt) #
# mtp or max_temp_pause #
# These two work together and are NOT tied to the cooldown cycle.
# On max_temp (°C), charging is paused for max_temp_pause (seconds).
# Unlike the cooldown cycle, which aims at reducing BOTH high temperature and high voltage induced stress - this is ONLY meant specifically for reducing high temperature induced stress.
# Even though both are separate features, this complements the cooldown cycle when environmental temperatures are off the charts.

# cooldown_charge (cch) #
# cooldown_pause (cp) #
# These two dictate the cooldown cycle intervals (seconds).
# When not set, the cycle is disabled.
# Note that cooldown_capacity and cooldown_temp can be disabled individually by assigning them values that would never be reached under normal circumstances.

# cooldown_current (ccu) #
# Dedicated and independent cooldown settings for quick charging

# reset_batt_stats_on_pause (rbsp) #
# Reset battery stats after pausing charging.

# reset_batt_stats_on_unplug (rbsu) #
# Reset battery stats after unplugging the charger AND loop_delay_discharging (seconds) have passed.
# If the charger is replugged within loop_delay_discharging (seconds) after unplugging it, the operation is aborted.

# loop_delay_charging (ldc) #
# loop_delay_discharging (ldd) #
# These are delays (seconds) between loop iterations.
# The lower they are, the quicker acc responsiveness is - but at the cost of slightly extra CPU time.
# Don't touch these (particularly ldd), unless you know exactly what you're doing.
# accd manages both according to the state of capacity_sync.

# charging_switch (s) #
# If unset, acc cycles through its database and sets the first working switch/group that disables charging.
# If the set switch/group doesn't work, acc unsets chargingSwitch and repeats the above.
# If all switches fail to disable charging, chargingSwitch is unset, switchDelay is reverted to 1.5 and acc/d exit with error code 7.

# apply_on_boot (ab) #
# Settings to apply on boot or daemon start/restart.
# The --exit flag (refer back to applyOnBoot=...) tells the daemon to stop after applying settings.
# If the --exit flag is not included, default values are restored when the daemon stops.

# apply_on_plug (ap) #
# Settings to apply on plug
# This exists because some /sys files (e.g., current_max) are reset on charger re-plug.
# Default values are restored on unplug and when the daemon stops.

# max_charging_current (mcc) #
# apply_on_plug dedicated to current control
# This is managed with "acc --set --current ..." (acc -s c ...) commands.
# Refer back to the command examples.

# max_charging_voltage (mcv) #
# apply_on_boot dedicated to voltage control
# This is managed with "acc --set --voltage ..." (acc -s v ...) commands.

# reboot_on_pause (rp) #
# If this doesn't make sense to you, you probably don't need it.
# Essentially, this is a timeout (seconds) before rebooting - after pausing charging.
# This reboot is a workaround for a firmware issue that causes abnormally fast battery drain after charging is paused on certain devices.
# The issue has reportedly been fixed by the OEMs. This setting will eventually be removed.

# switch_delay (sd) #
# This is a delay (seconds) between charging status checks after toggling charging switches. It exists because some switches don't react immediately after being toggled.
# Most devices/switches work with a value of 1.
# Some may require a delay as high as 3. The optimal max is probably 3.5.
# If a charging switch seems to work intermittently, or fails completely, increasing this value may fix the issue.
# You absolutely should increase this value if "acc -t" reports total failure.
# Some MediaTek devices require a delay as high as 15!
# accd manages this setting dynamically.

# lang (l) #
# acc language, managed with "acc --set --lang" (acc -s l).

# wake_unlock (wu) #
# This is an attempt to release wakelocks acquired after disabling charging.
# It's totally experimental and may or may not work (expect side effects).

# prioritize_batt_idle_mode (pbim) #
# Several devices can draw power directly from the external power supply when charging is paused. Test yours with "acc -t".
# This setting dictates whether charging switches that support such feature should take precedence.

# force_charging_status_full_at_100 (ff) #
# Some Pixel devices were found to never report "full" status after the battery capacity reaches 100%.
# This setting forces Android to behave as intended.
# For Pixel devices, the status code of "full" is 5 (ff=5).
# The status code is found through trial and error, with the commands "dumpsys battery", "dumpsys battery set status #" and "dumpsys battery reset".

# run_cmd_on_pause (rcp) #
# Run commands* after pausing charging.
# * Usually a script ("sh some_file" or ". some_file")

# dyn_power_saving (dps) #
# This is the maximum number of seconds accd will dynamically sleep* for (while unplugged) to save resources.
# If dyn_power_saving == 0, the feature is disabled.
# * On top of loop_delay_discharging

# vibration_patterns (vp) #
# ACC and ACC service (accs) trigger vibrations on specific events (refer back to BASIC CONFIG EXPLANATION > vibrationPatterns).
# vp lets you customize vibration patterns per event type.
# To disable vibrations for an event, replace "<event>_vibrations interval" with "- -" (hyphen space hyphen, excluding quotes). Refer back to COMMAND EXAMPLES.

#/DC#
```


---
## SETUP/USAGE


As the default configuration (above) suggests, ACC is designed to run out of the box, with little to no customization/intervention.

The only command you need to remember is `acc`.
It's a wizard you'll either love or hate.

If you feel uncomfortable with the command line, skip this section and use the [ACC app](https://github.com/MatteCarra/AccA/releases/) to manage ACC.
That link will not always lead you to the latest version, though. https://t.me/acc_group/ will.

Alternatively, you can use a `text editor` to modify `/data/adb/acc-data/config.txt`.
Restart the [daemon](https://en.wikipedia.org/wiki/Daemon_(computing)) afterwards (`accd` command).
The config file itself has configuration instructions.


### Terminal Commands
```
#TC#

Usage

  acc   Wizard

  accd   Start/restart accd

  accd.   Stop acc/daemon

  accd,   Print acc/daemon status (running or not)

  acc [pause_capacity resume_capacity]   e.g., acc 75 70

  acc [options] [args]   Refer to the list of options below

  /sbin/acca [options] [args]   acc optimized for front-ends

  accs   acc foreground service, works exactly as accd, but attached to the terminal

  A custom config path can be specified as first parameter.
  If the file doesn't exist, the current config is cloned.
    e.g.,
      acc /data/acc-night-config.txt --set pause_capacity=45 resume_capacity=43
      acc /data/acc-night-config.txt --set --current 500
      accd /data/acc-night-config.txt


Options

  -c|--config [editor] [editor_opts]   Edit config (default editor: nano/vim/vi)
    e.g.,
      acc -c (edit w/ nano/vim/vi)
      acc -c less
      acc -c cat

  -C|--calibrate   Charge to true 100%
    e.g., acc -C

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

  -f|--force|--full [capacity]   Charge to a given capacity (default: 100) once, uninterrupted and without other restrictions
    e.g.,
      acc -f 95 (charge to 95%)
      acc -f (charge to 100%)
    Note: not to be confused with -C; -f 100 won't allow charging to true 100% capacity

  -F|--flash ["zip_file"]   Flash any zip files whose update-binary is a shell script
    e.g.,
      acc -F (lauches a zip flashing wizard)
      acc -F "file1" "file2" "fileN" ... (install multiple zips)
      acc -F "/sdcard/Download/Magisk-v20.0(20000).zip"

  -i|--info [case insentive egrep regex (default: ".")]   Show battery info
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

  -l|--log -e|--export   Export all logs to /sdcard/acc-logs-\$deviceName.tar.gz
    e.g., acc -l -e

  -le   Same as -l -e

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

  -s|--set c|--current [-]   Set/print/restore_default max charging current (range: 0-9999$(print_mA))
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

  -s|--set v|--voltage [-] [--exit]   Set/print/restore_default max charging voltage (range: 3700-4200$(print_mV))
    e.g.,
      acc -s v (print)
      acc -s v 3920 (set)
      acc -s v - (restore default)
      acc -s v 3920 --exit (stop the daemon after applying settings)

  -t|--test [ctrl_file1 on off [ctrl_file2 on off]]   Test custom charging switches
    e.g.,
      acc -t battery/charging_enabled 1 0
      acc -t /proc/mtk_battery_cmd/current_cmd 0::0 0::1 /proc/mtk_battery_cmd/en_power_path 1 0 ("::" == " ")

  -t|--test [file]   Test charging switches from a file (default: $TMPDIR/charging-switches)
    This will also report whether "battery idle" mode is supported
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
      acc -u 201905110 --force (version 2019.5.11)
      acc -u -c -n (if update is available, prints version code (integer) and changelog link)
      acc -u -c (same as above, but with install prompt)

  -U|--uninstall   Completelly remove acc and AccA
    e.g., acc -U

  -v|--version   Print acc version and version code
    e.g., acc -v

  -w#|--watch#   Monitor battery uevent
    e.g.,
      acc -w (update every 3 seconds, default)
      acc -w2.5 (update every 2.5 seconds)
      acc -w0 (no extra delay)


Exit Codes

  0. True/success
  1. False or general failure
  2. Incorrect command syntax
  3. Missing busybox binary
  4. Not running as root
  5. Update available ("--upgrade")
  6. No update available ("--upgrade")
  7. Couldn't disable charging
  8. Daemon already running ("--daemon start")
  9. Daemon not running ("--daemon" and "--daemon stop")
  10. "--test" failed

  Logs are exported automatically ("--log --export") on exit codes 1, 2, 7 and 10.


Tips

  Commands can be chained for extended functionality.
    e.g., acc -e 30m && acc -d 6h && acc -e 85 && accd (recharge for 30 minutes, halt charging for 6 hours, recharge to 85% capacity and restart the daemon)

  Programming charging before going to sleep...
    acc 45 43 && acc -s c 500 && sleep \$((60*60*7)) && acc 80 75 && acc -s c -
      - "Keep battery capacity bouncing between 43-45% and limit charging current to 500 mA for 7 hours. Restore regular charging settings afterwards."
      - For convenience, this can be written to a file and ran as "sh /path/to/file".
      - If the kernel supports custom max charging voltage, it's best to use that feature over the above chain, like so: "acc -s v 3920 && sleep \$((60*60*7)) && acc -s v -".

  Run acc -r (or --readme) to see the full documentation.

#/TC#
```


---
## NOTES/TIPS FOR FRONT-END DEVELOPERS


_Always_ use `/sbin/acca` over `acc`. This ensures acc language is always English - and offers greater efficiency (less overhead and verbose).

It's best to write full commands over short equivalents - e.g., `/sbin/acca --set charging_switch=` instead of `/sbin/acca -s s=`. This makes your code more readable (less cryptic). Don't be lazy!

Include provided descriptions for ACC features/settings in your app(s). Provide additional information (trusted) where appropriate.
Explain settings/concepts as clearly and with as few words as possible.

Take advantage of exit codes. Refer back to `SETUP/USAGE > Terminal Commands > Exit Codes`.


### Online ACC Install

```
1) Check whether ACC is installed (exit code 0)
/sbin/acca --version > /dev/null

2) Download the installer (https://raw.githubusercontent.com/VR-25/acc/master/install-online.sh)
- e.g.,
  curl -#LO URL
  wget -O install-online.sh URL

3) Run "sh install-online.sh" (installation progress is shown)
```

### Offline ACC Install

Refer back to the `BUILDING AND/OR INSTALLING FROM SOURCE` section.


### Officially Supported Front-ends

- ACC App, a.k.a., AccA (installDir=/data/data/mattecarra.accapp/files/acc/)



---
## TROUBLESHOOTING


### `acc -t --` Reports Total Failure

Refer back to `DEFAULT CONFIGURATION (switch_delay)`.


### Battery Capacity (% Level) Doesn't Seem Right

The "smart" battery may need calibration.
Refer to the `FAQ` section below for details.

If we're talking about a Pixel device, the issue goes beyond that.
Refer back to `DEFAULT CONFIGURATION > capacity_sync`.


### Bootloop, ACC Not Found

ACC disables itself after a bootloop event.
Refer to `Diagnostics/Logs` below for details.


### Charging Switch

By default, ACC uses whatever [charging switch](https://github.com/VR-25/acc/blob/dev/acc/charging-switches.txt) works.
However, things don't always go well.

- Some switches are unreliable under certain conditions (e.g., screen off).

- Others hold a [wakelock](https://duckduckgo.com/?q=wakelock) - causing faster battery drain.
Refer back to `DEFAULT CONFIGURATION (wake_unlock)`.

- High CPU load and inability to re-enable charging we're also be reported.

- In the worst case scenario, the battery status is reported as `discharging`, while it's actually `charging`.

In such situations, you have to find a switch that works as expected.
Here's how to do it:

1. Run `acc --test --` (or acc -t --) to see which switches work.
2. Run `acc --set charging_switch` (or acc -s s) to enforce a working switch.
3. Test the reliability of the set switch. If it doesn't work properly, try another.

ACC daemon applies dedicated settings for specific devices (e.g., MTK, Asus, 1+7pro) to prevent charging switch issues.
These are are in `acc/oem-custom.sh`.


### Custom Max Charging Voltage And Current Limits

Unfortunately, not all kernels support these features.
While custom current limits are supported by most (at least to some degree), voltage tweaking support is _exceptionally_ rare.

That said, the existence of potential voltage/current control file doesn't necessarily mean these are writable* or the features are supported.

\* Root is not enough.
Kernel level permissions forbid write access to certain interfaces.


### Diagnostics/Logs

ACC/service trigger vibrations on certain events (charging enabled/disabled, errors, auto-shutdown warnings and acc -C 100% reached).

Volatile logs are in `/sbin/.acc/`.
Persistent logs are found at `/data/adb/acc-data/logs/`.

`/data/adb/acc-data/logs/bootlooped` is created automatically after a bootloop event.
It prevents acc initialization.

`acc -le` exports all acc logs, plus Magisk's and extras to `/data/media/0/acc-$device_codename.tar.gz`.
The logs do not contain any personal information and are never automatically sent to the developer.
Automatic exporting happens under specific conditions (refer back to `NOTES/TIPS FOR FRONT-END DEVELOPERS > Exit Codes`).


### Restore Default Config

`acc --set --reset` or `acc -s r`


### Slow Charging

At least one of the following may be the cause:

- Charging current and/or voltage limits
- Cooldown cycle (non optimal charge/pause ratio, try 50/10 or 50/5)
- Troublesome charging switch (refer back to `TROUBLESHOOTING > Charging Switch`)
- Weak adapter and/or power cord



---
## POWER SUPPLY LOG (HELP NEEDED)

Please upload `/sbin/.acc/acc-power_supply-*.log` to [my dropbox](https://www.dropbox.com/request/WYVDyCc0GkKQ8U5mLNlH/).
This file contains invaluable power supply information, such as battery details and available charging control files.
A public database is being built for mutual benefit.
Your cooperation is greatly appreciated.

Privacy Notes

- Name: phone brand and/or model (e.g., 1+7pro, Moto Z Play)
- Email: random/fake

See current submissions [here](https://www.dropbox.com/sh/rolzxvqxtdkfvfa/AABceZM3BBUHUykBqOW-0DYIa?dl=0).



---
## LOCALIZATION


Currently Supported Languages and Translation Statuses

- English (en): complete
- Portuguese, Portugal (pt-PT): partial
- Simplified Chinese (zh-rCN) by [zjns](https://github.com/zjns/): partial


Translation Notes

1. Start with copies of [acc/strings.sh](https://github.com/VR-25/acc/blob/master/acc/strings.sh) and [README.md](https://github.com/VR-25/acc/blob/master/README.md).

2. Modify the header of strings.sh to reflect the translation (e.g., # Español (es)).

3. Anyone is free and encouraged to open translation [pull requests](https://duckduckgo.com/?q=pull+request).
Alternatively, a _compressed_ archive of translated `strings.sh` and `README.md` files can be sent to the developer via Telegram (link below).

4. Use `acc -s l` (--set --lang): language switching wizard



---
## TIPS


### Generic

Achieve _idle mode_ with voltage limit: `acc 101 100; acc -s v 3920`
The first command disables the regular - charging switch driven - pause/resume functionality.
The second sets a voltage limit that will dictate how much the battery should charge.
The battery enters the so called _idle mode_ when its voltage peaks.

Limit charging current to 500 milliamps: `acc -s c 500`
(`acc -s c -` restores the default limit).

Force fast charge: `appy_on_boot=/sys/kernel/fast_charge/force_fast_charge::1::0 usb/boost_current::1::0 charger/boost_current::1::0`


### Google Pixel Devices

Force fast wireless charging with third party wireless chargers that are supposed to charge the battery faster: `apply_on_plug=wireless/voltage_max:9000000`.



---
## FREQUENTLY ASKED QUESTIONS (FAQ)


> How do I report issues?

Open issues on GitHub or contact the developer on Facebook, Telegram (preferred) or XDA (links below).
Always provide as much information as possible.
Attach `/sdcard/acc-logs-*tar.gz` - generated by `acc -le` _right after_ the problem occurs.
Refer back to `TROUBLESHOOTING > Diagnostics/Logs` for additional details.


> Why won't you support my device? I've been waiting for ages!

Firstly, have some extra patience!
Secondly, several systems don't have intuitive charging control files; I have to dig deeper - and oftentimes, improvise; this takes extra time and effort.
Lastly, some systems don't support custom charging control at all;  in such cases, you have to keep trying different kernels and uploading the respective power supply logs.
Refer back to `POWER SUPPLY LOGS (HELP NEEDED)`.


> Why, when and how should I calibrate the battery?

With modern battery management systems, that's generally unnecessary.
If your battery is underperforming, refer to https://batteryuniversity.com/index.php/learn/article/battery_calibration .
The calibration command is `acc -C`.


> What if even after calibrating the battery, ACC and Android battery level reports still differ?

It's most likely an Android OS issue. Refer back to `DEFAULT CONFIGURATION` (capacity_offset and capacity_sync).


> I set voltage to 4080 mV and that corresponds to just about 75% charge.
But is it typically safer to let charging keep running, or to have the circuits turn on and shut off between defined percentage levels repeatedly?

It's not much about which method is safer.
It's specifically about electron stability: optimizing the pressure (voltage) and current flow.

As long as you don't set a voltage limit higher than 4200 mV and don't leave the phone plugged in for extended periods of time, you're good with that limitation alone.
Otherwise, the other option is actually more beneficial - since it mitigates high pressure (voltage) exposure/time to a greater extent.
If you use both, simultaneously - you get the best of both worlds.
On top of that, if you enable the cooldown cycle, it'll give you even more benefits.

Anyway, while the battery is happy in the 3700-4100 mV range, the optimal voltage for [the greatest] longevity is said\* to be ~3920 mV.

If you're leaving your phone plugged in for extended periods of time, that's the voltage limit you should aim for.

Ever wondered why lithium ion batteries aren't sold fully charged? They're usually ~40-60% charged. Why is that?
If you ever purchase a battery that is fully drained, almost fully drained or 70%+ charged, you know it's probably f.*d up already!

Summing up my thoughts...

Night/heavy-duty profile: keep capacity within 40-60% and/or voltage around ~3920 mV

Day/regular profile: max capacity: 75-80% and/or voltage no higher than 4100 mV

Travel profile: capacity up to 95% and/or voltage no higher than 4200 mV

\* https://batteryuniversity.com/index.php/learn/article/how_to_prolong_lithium_based_batteries/


> I don't really understand what the "-f|--force|--full [capacity]" is meant for.

Consider the following situation:

You're almost late for an important event.
You recall that I stole your power bank and sold it on Ebay.
You need your phone and a good battery backup.
The event will take the whole day and you won't have access to an external power supply in the middle of nowhere.
You need your battery charged fast and as much as possible.
However, you don't want to modify ACC config nor manually stop/restart the daemon.


> What's DJS?

It's a standalone program: Daily Job Scheduler.
As the name suggests, it's meant for scheduling "jobs" - in this context, acc profiles/settings.
Underneath, it runs commands/scripts at specified times - either once, daily and/or on boot.


> Do I have to install/upgrade both ACC and AccA?

To really get out of this dilemma, you have to understand what ACC and AccA essentially are.

ACC is a Android program that controls charging.
It can be installed as an app (e.g., AccA) module, Magisk module or standalone software. Its installer determines the installation path/variant. The user is given the power to override that.
A plain text file holds the program's configuration. It can be edited with any root text editor.
ACC has a command line interface (CLI) - which in essence is a set of Application Programing Interfaces (APIs). The main purpose of a CLI/API is making difficult tasks ordinary.

AccA is a graphical user interface (GUI) for the ACC command line. The main purpose of a GUI is making ordinary tasks simpler.
AccA ships with a version of ACC that is automatically installed when the app is first launched.

That said, it should be pretty obvious that ACC is like a fully autonomous car that also happens to have a steering wheel and other controls for a regular driver to hit a tree.
Think of AccA as a robotic driver that often prefers hitting people over trees.
Due to extenuating circumstances, that robot is not upgraded as frequently as the car.
Upgrading the car regularly, makes the driver happier - even though I doubt it has any emotion to speak of.


> Does acc work also when Android is off?

No.



---
## LINKS

- [Must read - how to prolong lithium ion batteries lifespan](http://batteryuniversity.com/learn/article/how_to_prolong_lithium_based_batteries/)
- [ACC app](https://github.com/MatteCarra/AccA/releases/)
- [Daily Job Scheduler](https://github.com/VR-25/djs/)
- [Facebook page](https://fb.me/vr25xda/)
- [Git repository](https://github.com/VR-25/acc/)
- [Liberapay](https://liberapay.com/VR25/)
- [Patreon](https://patreon.com/vr25/)
- [PayPal](https://paypal.me/vr25xda/)
- [Telegram channel](https://t.me/vr25_xda/)
- [Telegram group](https://t.me/acc_group/)
- [Telegram profile](https://t.me/vr25xda/)
- [XDA thread](https://forum.xda-developers.com/apps/magisk/module-magic-charging-switch-cs-v2017-9-t3668427/)



---
## LATEST CHANGES

**2020.4.4-dev (202004040)**
- acc -(e|d): do not do unnecessary work
- acc -f: fixed capacity limit bypass
- acc -F: general fixes and optimizations
- accs: acc foreground service, works exactly as accd, but remains attached to the terminal
- "acc -t --" is now "acc -t"
- ACC/service trigger vibrations on certain events (charging enabled/disabled, errors, auto-shutdown warnings and acc -C 100% reached); vibration patterns are customizable
- Auto-reset broken/invalid config
- Enhanced acc -C compatibility
- Fixed busybox setup issues on devices not rooted with Magisk
- Misc fixes
- Major optimizations
- Updated documentation

**2020.3.30-r1-dev (202003301)**
- Misc fixes
- Preserve as many config parameters as possible across (up|down)grades

**2020.3.30-dev (202003300)**
- `-C|--calibrate`: charge until battery_status == "Full"
- `acc -i`: fixed current_now conversion (Redmi 6 Pro and other msm8953 based devices)
- `acc -u, install-online.sh`: optional -k|--insecure flag
- accd manages capacity_sync loop_delay_charging, loop_delay_discharging and switch_delay parameters dynamically
- Charging switch tests take  significantly longer (switch_delay=18); this leads to more consistent results
- Enable Android battery saver on capacity <= shutdown_capacity + 5
- Enriched help text (acc -h|--help)
- Major optimizations
- More modular design
- Portability enhancements
- Vibrate 3 times when an error occurs
- Vibrate 5 times on capacity <= shutdown_capacity + 5, and again on each subsequent capacity drop
- Vibrate 5 times when `acc --calibrate` reaches 100%
- Updated documentation

**2020.3.14-dev (202003140)**
- `acc -s v`: fixed "voltage unit not shown"
- `cooldownCurrent=(file raw_current charge_seconds pause_seconds)`, cooldown_current (ccr): dedicated and independent cooldown settings for quick charging
- General optimizations
- Updated documentation

**2020.3.11-dev (202003110)**
- Fixed capacity_sync issues

**2020.3.10-dev (202003100)**
- ACC Wizard: auto-restart after upgrade
- Installer optimizations
- Universal zip flasher: default_PWD = /storage/emulated/0/Download/, support for filenames containing spaces, more intuitive

**2020.3.9-dev (202003090)**
- Block "ghost charging on steroids" (Xiaomi Redmi 3 - ido)
- General optimizations
- Workaround for "Magisk forgetting service.sh" issue

**2020.3.5-dev (202003050)**
- Added Galaxy S7 current control files
- General optimizations
- Milliamps current control support
- Wizard (`acc`) option `c` (check for update) is fully interactive (won't download updates without confirmation)

**2020.3.4-r1-dev (202003041)**
- /sbin/acca optimizations
- `acc` (wizard): every option is mapped to a single ASCII character (letter or number); pressing [enter] is no longer required for confirming most operations
- Default editor: nano/vim/vi
- Fixed oem-custom "mismatched /" error
- Fixed zip flasher
- Use `less` instead of `vim/vi` to open files in read-only mode (e.g., *.log, *.md)
- Updated help text

**2020.3.4-dev (202003040)**
- Hotfix: get_prop() in oem-custom.sh

**2020.3.3-dev (202003030)**
- `/sbin/acca`: fixed file path issues; ~90%+ faster than version 2020.2.29-r1-dev
- `acc -i`: fixed current/voltage conversion and power calculation issues
- `acc -i`: output current in Amps
- Include kernel details in power supply logs
- Major optimizations
- MediaTek specific fixes

**2020.2.29-r1-dev (202002291)**
- Fixed typos and reset_batt_stats_on_unplug

**2020.2.29-dev (202002290)**
- `/sbin/acca`: acc executable for front-ends (more efficient than /sbin/acc)
- `acc -F|--flash`: added support for batch zip flashing, custom path in interactive mode, and more
- `acc -w#|--watch#`: monitor battery uevent (# == update time in secs, can be zero or decimal, default 3)
- General optimizations
- Ghost charging issue management is fully automatic
- Initial work on cooldown cycle redesign (coolDownCapacity=(capacity charge/pause), coolDownCurrent=(current charge/pause), coolDownTemp=(temp charge/pause))
- Translation strings for `acc --upgrade`
- Updated help text (`acc --help`)
- Updated `README.md > NOTES/TIPS FOR FRONT-END DEVELOPERS`

**2020.2.28-dev (202002280)**
- acc -i: fixes for MTK and HTC One M9, print battery power in/out (Watts)
- Autodetect and block ghost charging (refer to "README.md > DEFAULT CONFIGURATION > ghost_charging" for details)
- Fixed config reset issues
- General optimizations

**2020.2.26-dev (202002260)**
- acc -i: htc_himauhl, read VOLTAGE_NOW from bms/uevent
- acc -i: print current_now, temp and voltage_now over MediaTek's odd property names
- Fixed `acc -d`
- General optimizations
- ghost_charging toggle (refer to "README.md > DEFAULT CONFIGURATION > ghost_charging" for details)
- Updated busybox configuration, documentation and framework-detais.txt

**2020.2.25-dev (202002250)**
- Added alternate `curl` setup instructions to README.md
- Default switch_delay: 3.5 seconds
- Fixed typos
- General optimizations
- Updated module framework

**2020.2.24-dev (202002240)**
- Enhanced general wizard ("acc" command)
- Stripped untranslated strings
- Updated zip flasher and module framework

**2020.2.23-r1-dev (202002231)**
- acc -F: call pick_zip() when there's no arg
- Fixed typos

**2020.2.23-dev (202002230)**
- Updated strings

**2020.2.22-r1-dev (202002221)**
- acc -D: show accd version and PID as well
- acc -F: optimizations
- acc -s s: fixed "print_known_cs: not found"
- acc -v: new output format - `version (version_code)`

**2020.2.22-dev (202002220)**
- Ability to set/nullify multiple properties with a single command (e.g., `acc -s prop1=value "prop2=value1 value2 ..." prop3=`)
- `acc --uninstall` (-U) and the flashable uninstaller remove AccA as well
- Better localization support
- capacity_sync and cooldown cycle improvements
- Changes made by `apply_on_boot()` and `apply_on_plug()` are reverted automatically when appropriate
- config.txt contains a comprehensive help text as well
- Dedicated current control conmands
- Custom configuration for specific devices (`acc/oem-custom.sh`)
- Enhanced commmand list and examples (`acc -h`)
- Extended device support (ASUS, MediaTek, Pixel 4/XL, Razer, 1+7 and more)
- General wizard (`acc` command)
- Greater charging control flexibility
- More modular design
- New config format and more flexible APIs
- Optimized busybox setup
- Prevent power events from waking the screen during the cooldown cycle
- `runCmdOnPause`
- Self-disable after a bootloop event
- Symlink `installDir` to `/data/adb/acc` and `/data/adb/modules/acc`
- The help text (acc -h), documentation (acc -r), logs (acc -l) and config (acc -c) open in vim/vi by default (scrollable)
- Universal zip flasher (`acc -F "zip_file"`)
- Updated documentation and framework
> Notes: incompatible with AccA versions lower than 1.0.21; config will be reset

**2019.10.13-r2-dev (201910132)**
- `forceStatusAt100`: ensure the battery service is ready before freezing/unfreezing the charging status

**2019.10.13-r1-dev (201910131)**
- `acc --upgrade`: use `curl` over `wget`
