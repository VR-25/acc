# Advanced Charging Controller (ACC)



---
## LICENSE

Copyright 2017-2020, VR25 (patreon.com/vr25)

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

ACC manipulates Android low level ([kernel](https://duckduckgo.com/lite/?q=kernel+android)) parameters which control the charging circuitry.
The author assumes no responsibility under anything that might break due to the use/misuse of this software.
By choosing to use/misuse ACC, you agree to do so at your own risk!



---
## DESCRIPTION

ACC is an Android software mainly intended for [extending battery service life](https://batteryuniversity.com/learn/article/how_to_prolong_lithium_based_batteries).
In a nutshell, this is achieved through limiting charging current, temperature and voltage.
Any root solution is supported.



---
## PREREQUISITES

- [Must read - how to prolong lithium ion batteries lifespan](https://batteryuniversity.com/index.php/learn/article/how_to_prolong_lithium_based_batteries/)
- Android or Android based OS
- Any root solution (e.g., [Magisk](https://github.com/topjohnwu/Magisk/))
- Busybox\* (only if not rooted with Magisk)
- curl\*\* (for acc --upgrade, optional)
- Non-Magisk users can enable acc auto-start by running /data/adb/$id/service.sh, a copy of, or a link to it - with init.d or an app that emulates it
- Terminal emulator
- Text editor (optional)

\* Instead of a regular install, the [busybox binary](https://github.com/search?o=desc&q=busybox+android&s=updated&type=Repositories/) can simply be placed in /data/adb/bin/.
ACC sets 0700 permissions as needed.
Precedence: /data/adb/bin/busybox > Magisk's busybox > system's busybox

\*\* A [static curl binary](https://github.com/search?o=desc&q=curl+android&s=updated&type=Repositories/) (optional) can also be placed in `/data/adb/bin/` (with execute permission).
Alternatively, one may install the Magisk module [Cross Compiled Binaries (ccbins)](https://github.com/Magisk-Modules-Repo/ccbins/).



---
## QUICK START GUIDE


0. All commands/actions require root.

1. Install/upgrade: flash\* the zip or use ACC front-end app (e.g. AccA).
There are two additional ways of upgrading: `acc --upgrade` (online) and `acc --flash` (zip flasher).
Rebooting after installation/removal is generally unnecessary.

2. [Optional] run `acc` (wizard). That's the only command you need to remember.

3. [Optional] run `acc pause_capacity resume_capacity` (default `75 70`) to set the battery levels at which charging should pause and resume, respectively.

4. If you come across any issues, refer to the `TROUBLESHOOTING`, `TIPS` and `FAQ` sections below.
Read as much as you can prior to reporting issues and/or asking questions.
Oftentimes, solutions/answers will be right before your eyes.


### Notes

- Steps `2` and `3` are optional because there are default settings.
For details, refer to the `DEFAULT CONFIGURATION` section below.
Users are encouraged to try step `2` - to familiarize themselves with the available options.

- Settings can be overwhelming. Start with what you understand.
The default configuration has you covered.
Don't ever feel like you have to configure everything. You probably shouldn't anyway - unless you really know what you're doing.

- Uninstall: run `acc --uninstall` or flash\* `/sdcard/Download/acc/acc-uninstaller.zip`.

\* If you're going to flash from recovery, mount system first.
Otherwise, recovery will throw error 255.

ACC runs in recovery environments as well.
Unless the zip is flashed again, manual initialization is required.
The initialization command is `/data/adb/acc/service.sh`.



---
## BUILDING AND/OR INSTALLING FROM SOURCE


### Dependencies (Build)

- git, wget, or curl (pick one)
- zip


### Build Tarballs and Flashable Zips

1. Download and extract the source code: `git clone https://github.com/VR-25/acc.git`
or `wget  https://github.com/VR-25/acc/archive/master.tar.gz -O - | tar -xz`
or `curl -L#  https://github.com/VR-25/acc/archive/master.tar.gz | tar -xz`

2. `cd acc*`

3. `sh build.sh` (or double-click `build.bat` on Windows 10, if you have Windows subsystem for Linux (with zip) installed)


#### Notes

- build.sh automatically sets/corrects `id=*` in `*.sh` and `update-binary` files.
Refer to framework-details.txt for a full list of tasks carried out by it.
To skip generating archives, run the build script with a random argument (e.g. bash build.sh h).

- The output files are (in `_builds/acc-$versionCode/`): `acc-$versionCode.zip`, `acc-$versionCode.tar.gz`, and `install-tarball.sh`.

- To update the local source code, run `git pull --force` or re-download it (with wget/curl) as described above.


### Install from Local Sources or GitHub

- `sh install-tarball.sh acc` installs the tarball (acc*gz) from the script's location.
The archive must be obtained from GitHub: https://github.com/VR-25/acc/archive/$reference.tar.gz ($reference examples: master, dev, v2020.5.20-rc).

- `sh install.sh` installs acc from the extracted source.

- `sh install-online.sh [-c|--changelog] [-f|--force] [-k|--insecure] [-n|--non-interactive] [%install dir%] [reference]` downloads and installs acc from GitHub. e.g., `sh install-online.sh dev`


#### Notes

- `install.sh` and `install-tarball.sh` accept a custom _parent installation directory_ (e.g., `export installDir=/data; sh install.sh /data` - this will install acc in /data/acc/).

- In addition to the above, `install-online.sh` also recognizes a custom parent installation directory supplied as follows: `sh install-online.sh %path%` (e.g., `sh install-online.sh %/data%`).

- `install-online.sh` is the `acc --upgrade` back-end.

- The order of arguments doesn't matter.

- The default parent installation directories, in order of priority, are: `/data/data/mattecarra.accapp/files/` (ACC App, `/data/adb/modules/` (Magisk) and `/data/adb/` (other root solutions).

- No argument/option is strictly mandatory.
The exception is `--non-interactive` for front-end apps.
Unofficially supported front-ends must specify the parent installation directory.
Otherwise, the installer will follow the order above.

- The `--force` option to `install-online.sh` is meant for re-installation and downgrading.

- `sh install-online.sh --changelog --non-interactive` prints the version code (integer) and changelog URL (string) when an update is available.
In interactive mode, it also asks the user whether they want to download and install the update.

- You may also want to read `NOTES/TIPS FOR FRONT-END DEVELOPERS > Exit Codes` below.



---
## DEFAULT CONFIGURATION
```
#DC#

configVerCode=202007220
capacity=(-1 60 70 75 false)
temperature=(40 60 90)
cooldownRatio=()
cooldownCustom=()
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
prioritizeBattIdleMode=true
forceChargingStatusFullAt100=
runCmdOnPause=()
autoShutdownAlertCmd=(vibrate 5 0.1)
chargDisabledNotifCmd=(vibrate 3 0.1)
chargEnabledNotifCmd=(vibrate 4 0.1)
errorAlertCmd=(vibrate 6 0.1)
ampFactor=
voltFactor=
ctrlFileWrites=(3 0.3)
loopCmd=()


# WARNINGS

# As seen above, whatever is null can be null.
# Nullifying values that should not be null causes nasty errors.
# However, doing so with "--set var=" restores the default value of "var".
# In other words, for regular users, "--set" is safer than modifying the config file directly.

# Do NOT feel like you must configure everything!
# If you don't know EXACTLY how to and why you want to do it, it's a very dumb idea.
# Help is always available, from multiple sources - plus, you don't have to pay a penny for it.


# BASIC CONFIG EXPLANATION

# capacity=(shutdown_capacity cooldown_capacity resume_capacity pause_capacity capacity_freeze2)

# temperature=(cooldown_temp max_temp max_temp_pause)

# cooldownRatio=(cooldown_charge cooldown_pause)

# cooldownCustom=cooldown_custom=(file raw_value charge_seconds pause_seconds)

# resetBattStats=(reset_batt_stats_on_pause reset_batt_stats_on_unplug)

# loopDelay=(loop_delay_charging loop_delay_discharging)

# chargingSwitch=charging_switch=(ctrl_file1 on off ctrl_file2 on off --)

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

# autoShutdownAlertCmd=auto_shutdown_alert_cmd=(. script)

# chargDisabledNotifCmd=charg_disabled_notif_cmd=(. script)

# chargEnabledNotifCmd=charg_enabled_notif_cmd=(. script)

# errorAlertCmd=error_alert_cmd=(. script)

# ampFactor=amp_factor=[multiplier]

# voltFactor=volt_factor=[multiplier]

# ctrlFileWrites=ctrl_file_writes=(times interval)

# loopCmd=loop_cmd=(. script)


# VARIABLE ALIASES/SORTCUTS

# cc cooldown_capacity
# rc resume_capacity
# pc pause_capacity
# cft capacity_freeze2

# sc shutdown_capacity
# ct cooldown_temp
# cch cooldown_charge
# cp cooldown_pause

# mt max_temp
# mtp max_temp_pause

# ccu cooldown_custom

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

# asac auto_shutdown_alert_cmd
# cdnc charg_disabled_notif_cmd
# cenc charg_enabled_notif_cmd
# eac error_alert_cmd

# af amp_factor
# vf volt_factor

# cfw ctrl_file_writes
# lc loop_cmd


# COMMAND EXAMPLES

# acc 85 80
# acc -s pc=85 rc=80
# acc --set pause_capacity=85 resume_capacity=80

# acc -s "s=battery/charging_enabled 1 0"
# acc --set "charging_switch=/proc/mtk_battery_cmd/current_cmd 0::0 0::1 /proc/mtk_battery_cmd/en_power_path 1 0" ("::" = " ")

# acc -s sd=5
# acc -s switch_delay=5

# acc -s -v 3920 (millivolts)
# acc -s -c 500 (milliamps)

# custom config path
# acc /data/acc-night-config.txt 45 43
# acc /data/acc-night-config.txt -s c 500
# accd /data/acc-night-config.txt

# acc -s "ccu=battery/current_now 1450000 100 20"
# acc -s "cooldown_custom=battery/current_now 1450000 100 20"
# acc -s ccu="/sys/devices/virtual/thermal/thermal_zone1/temp 55 50 10"

# acc -s amp_factor=1000
# acc -s volt_factor=1000000

# acc -s mcc=500 mcv="3920 --exit"

# acc -s cfw="9 0.1"

# acc -s loop_cmd="echo 0 \\> battery/input_suspend"


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

# capacity_freeze2 (cft) #
# This prevents Android from getting capacity readings below 2%.
# It's useful on systems that shutdown before the battery is actually empty.

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
# Suggested values are cch=50 and cp=10.
# If charging gets a bit slower than desired, try cch=50 and cp=5.
# Note that cooldown_capacity and cooldown_temp can be disabled individually by assigning them values that would never be reached under normal circumstances.

# cooldown_custom (ccu) #
# When cooldown_capacity and/or cooldown_temp don't suit your needs, this comes to the rescue.
# It takes precedence over the regular cooldown settings.
# Refer back the command examples.

# reset_batt_stats_on_pause (rbsp) #
# Reset battery stats after pausing charging.

# reset_batt_stats_on_unplug (rbsu) #
# Reset battery stats after unplugging the charger AND loop_delay_discharging (seconds) have passed.
# If the charger is replugged within loop_delay_discharging (seconds) after unplugging it, the operation is aborted.

# loop_delay_charging (ldc) #
# loop_delay_discharging (ldd) #
# These are delays (seconds) between loop iterations.
# Lower values translate to quicker acc responsiveness - but at the cost of slightly extra CPU time.
# Don't touch these (particularly ldd), unless you know exactly what you're doing.

# charging_switch (s) #
# If unset, acc cycles through its database and sets the first working switch/group that disables charging.
# If the set switch/group doesn't work, acc unsets chargingSwitch and repeats the above.
# If all switches fail to disable charging, chargingSwitch is unset, switchDelay is reverted to 1.5 and acc/d exit with error code 7.
# This automated process can be disabled by appending "--" to "charging_switch=...".
# e.g., acc -s s="battery/charge_enabled 1 0 --"

# apply_on_boot (ab) #
# Settings to apply on boot or daemon start/restart.
# The --exit flag (refer back to applyOnBoot=...) tells the daemon to stop after applying settings.
# If the --exit flag is not included, default values are restored when the daemon stops.

# apply_on_plug (ap) #
# Settings to apply on plug
# This exists because some /sys files (e.g., current_max) are reset on charger re-plug.
# Default values are restored on unplug and when the daemon stops.

# max_charging_current (mcc) #
# max_charging_voltage (mcv) #
# Only the current/voltage value is to be supplied.
# Control files are automatically selected.
# Refer back to the command examples.

# reboot_on_pause (rp) #
# If this doesn't make sense to you, you probably don't need it.
# Essentially, this is a timeout (seconds) before rebooting - after pausing charging.
# This reboot is a workaround for a firmware issue that causes abnormally fast battery drain after charging is paused on certain devices.
# The issue has reportedly been fixed by the OEMs. This feature will eventually be removed.

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

# auto_shutdown_alert_cmd (asac) #
# charg_disabled_notif_cmd (cdnc) #
# charg_enabled_notif_cmd (cenc) #
# error_alert_cmd (eac) #
# As the names suggest, these properties dictate commands acc/d/s should run at each event.
# The default command is "vibrate <number of vibrations> <interval (seconds)>"
# Termux APIs can be used for notifications, TTS, toasts and more. For details, refer to https://wiki.termux.com/wiki/Termux:API .

# amp_factor (af) #
# volt_factor (vf) #
# Unit multiplier for conversion (e.g., 1V = 1000000 Microvolts)
# ACC can automatically determine the units, but the mechanism is not 100% foolproof.
# e.g., if the input current is too low, the unit is miscalculated.
# This issue is rare, though.
# Leave these properties alone if everything is running fine.

# ctrl_file_writes (cfw) #
# This determines how many times each ctrl file should be written to, as well as the interval (seconds) between these writes.
# That's an attempt to force changes that don't take effect immediately or at all.

# loop_cmd (lc) #
# This is meant for extending accd's functionality.
# It is periodically executed by is_charging() - which is called regularly, within the main accd loop.
# The boolean isCharging is available.
# Refer back to COMMAND EXAMPLES.

#/DC#
```

---
## SETUP/USAGE


As the default configuration (above) suggests, ACC is designed to run out of the box, with little to no customization/intervention.

The only command you have to remember is `acc`.
It's a wizard you'll either love or hate.

If you feel uncomfortable with the command line, skip this section and use the [ACC App](https://github.com/MatteCarra/AccA/releases/) to manage ACC.

Alternatively, you can use a `text editor` to modify `/data/adb/acc-data/config.txt`.
Restart the [daemon](https://en.wikipedia.org/wiki/Daemon_(computing)) afterwards, by running `accd`.
The config file itself has configuration instructions.
These instructions are the same found in the `DEFAULT CONFIG` section, above.


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

  acca [options] [args]   acc optimized for front-ends

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

  -l|--log -e|--export   Export all logs to /sdcard/Download/acc/acc-logs-$deviceName.tar.bz2
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

  -s|--set c|--current [milliamps|-]   Set/print/restore_default max charging current (range: 0-9999 Milliamps)
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
      rm /data/adb/acc-data/config.txt (failsafe)

  -sr   Same as above

  -s|--set s|charging_switch   Enforce a specific charging switch
    e.g., acc -s s

  -ss    Same as above

  -s|--set s:|chargingSwitch:   List known charging switches
    e.g., acc -s s:

  -ss:   Same as above

  -s|--set v|--voltage [millivolts|-] [--exit]   Set/print/restore_default max charging voltage (range: 3700-4200 Millivolts)
    e.g.,
      acc -s v (print)
      acc -s v 3920 (set)
      acc -s v - (restore default)
      acc -s v 3920 --exit (stop the daemon after applying settings)

  -sv [millivolts|-] [--exit]   Same as above

  -t|--test [switch_delay] [ctrl_file1 on off [ctrl_file2 on off]]   Test custom charging switches
    e.g.,
      acc -t battery/charging_enabled 1 0
      acc -t 15 /proc/mtk_battery_cmd/current_cmd 0::0 0::1 /proc/mtk_battery_cmd/en_power_path 1 0 ("::" is a placeholder for " "; the default switch_delay is 7)

  -t|--test [switch_delay] [file]   Test charging switches from a file (default: /ch-switches)
    This will also report whether "battery idle" mode is supported
    e.g.,
      acc -t (test known switches)
      acc -t 15 (test known switches, switch_delay=15; default sd is 7)
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

  -U|--uninstall   Completelly remove acc and AccA
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
  11. Current (mA) out of range
  12. Initialization failed
  13. Failed to lock /dev/.acc/acc.lock

  Logs are exported automatically ("--log --export") on exit codes 1, 2, 7 and 10.


Tips

  Commands can be chained for extended functionality.
    e.g., acc -e 30m && acc -d 6h && acc -e 85 && accd (recharge for 30 minutes, pause charging for 6 hours, recharge to 85% capacity and restart the daemon)

  Bedtime settings...
    acc -s /dev/.my-night-config.txt pc=45 rc=43 mcc=500 mcv=3920 && sleep $((60*60*7)) && accd
      - "For the next 7 hours, keep battery capacity between 43-45%, limit charging current to 500 mA and voltage to 3920 millivolts"
      - For convenience, this can be written to a file and ran as "sh /path/to/file".

  Refer to acc -r (or --readme) for the full documentation (recommended)

#/TC#
```

---
## NOTES/TIPS FOR FRONT-END DEVELOPERS


Rely on `acca` over `acc` commands.
These are optimized for front-ends (significantly faster than regular acc commands).

It's best to use long options over their short equivalents - e.g., `acca --set charging_switch=` instead of `acca -s s=`.
This makes the code more readable (less cryptic).
Don't be lazy!

Include provided descriptions for ACC features/settings in your app(s).
Provide additional information (trusted) where appropriate.
Explain settings/concepts as clearly and with as few words as possible.

Take advantage of exit codes.
Refer back to `SETUP/USAGE > Terminal Commands > Exit Codes`.


### Online ACC Install

```
1) Check whether ACC is installed (exit code 0)
acca --version

2) Download the installer (https://raw.githubusercontent.com/VR-25/acc/master/install-online.sh)
- e.g.,
  curl -#LO <URL>
  wget -O install-online.sh <URL>

3) Run "sh install-online.sh" (installation progress is shown)
```

### Offline ACC Install

Refer back to the `BUILDING AND/OR INSTALLING FROM SOURCE` section.


### Officially Supported Front-ends

- ACC App, a.k.a., AccA (installDir=/data/data/mattecarra.accapp/files/acc/)



---
## TROUBLESHOOTING


### `acc -t` Reports Total Failure

Refer back to `DEFAULT CONFIGURATION (switch_delay)`.


### Battery Capacity (% Level) Doesn't Seem Right

When Android's battery level differs from that of the kernel, ACC daemon automatically syncs it by stopping the battery service and feeding it the real value every few seconds.

Pixel devices are known for having battery level discrepancies for the longest time.

If your device shuts down before the battery is actually empty, capacity_freeze2 may help.
Refer to the `default configuration` section above for details.


### Battery Idle Mode On OnePlus 7/8 Variants (Possibly 5 and 6 Too)

Recent/custom kernels (e.g., Kirisakura) support battery idle mode.
However, at the time of this writing, the feature is not production quality.
ACC has custom code to cover the pitfalls, though.
`battery/op_disable_charge 0 1` must be enforced manually (`acc -ss` or `acc -s s="battery/op_disable_charge 0 1"`).


### Bootloop

While uncommon, it may happen.

It's assumed that you already know at least one of the following: temporary disable root (e.g., Magisk), disable Magisk modules or enable Magisk core-only mode.

Most of the time, though, it's just a matter of plugging the phone before turning it on.
Battery level must be below pause_capacity.
Once booted, one can run `acc --uninstall` (or `acc -U`) to remove ACC.

From recovery, you can mount system and flash `/sdcard/Download/acc/acc-uninstaller.zip` or run `mount /system; /data/adb/acc/uninstall.sh`.


### Charging Switch

By default, ACC uses whichever [charging switch](https://github.com/VR-25/acc/blob/dev/acc/charging-switches.txt) works.
However, things don't always go well.

- Some switches are unreliable under certain conditions (e.g., screen off).

- Others hold a [wakelock](https://duckduckgo.com/lite/?q=wakelock).
This causes fast battery drain when charging is paused and the device remains plugged.
Refer back to `DEFAULT CONFIGURATION (wake_unlock)`.

- High CPU load and inability to re-enable charging were also reported.

- In the worst case scenario, the battery status is reported as `discharging`, while it's actually `charging`.

In such situations, one has to enforce a switch that works as expected.
Here's how to do it:

1. Run `acc --test` (or `acc -t`) to see which switches work.
2. Run `acc --set charging_switch` (or `acc -ss`) to enforce a working switch.
3. Test the reliability of the set switch. If it doesn't work properly, try another.

Since not everyone is tech savvy, ACC daemon applies dedicated settings for specific devices (e.g., MTK, Asus, 1+7pro) to prevent charging switch issues.
These are are in `acc/oem-custom.sh`.


### Custom Max Charging Voltage And Current Limits

Unfortunately, not all kernels support these features.
While custom current limits are supported by most (at least to some degree), voltage tweaking support is _exceptionally_ rare.

That said, the existence of potential voltage/current control file doesn't necessarily mean these are writable* or the features, supported.

\* Root is not enough.
Kernel level permissions forbid write access to certain interfaces.


### Diagnostics/Logs

Volatile logs (gone on reboot) are stored in `/dev/.acc/`.
Persistent logs: `/data/adb/acc-data/logs/`.

`/dev/.acc-removed` is created by the uninstaller.
The storage location is volatile.

`acc -le` exports all acc logs, plus Magisk's and extras to `/sdcard/acc-$device_codename.tar.bz2`.
The logs do not contain any personal information and are never automatically sent to the developer.
Automatic exporting (local) happens under specific conditions (refer back to `SETUP/USAGE > Terminal Commands > Exit Codes`).


### Restore Default Config

This can save you a lot of time and grief.

`acc --set --reset`, `acc -sr` or `rm /data/adb/acc-data/config.txt` (failsafe)


### Slow Charging

At least one of the following may be the cause:

- Charging current and/or voltage limits
- Cooldown cycle (non optimal charge/pause ratio, try 50/10 or 50/5)
- Troublesome charging switch (refer back to `TROUBLESHOOTING > Charging Switch`)
- Weak adapter and/or power cord



---
## POWER SUPPLY LOG (HELP NEEDED)

Please run `acc -le` and upload `/data/adb/acc-data/logs/power_supply-*.log` to [my dropbox](https://www.dropbox.com/request/WYVDyCc0GkKQ8U5mLNlH/) (no account/sign-up required).
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
- Simplified Chinese (zh-rCN): partial


Translation Notes

1. Start with copies of [acc/strings.sh](https://github.com/VR-25/acc/blob/dev/acc/strings.sh) and [README.md](https://github.com/VR-25/acc/blob/dev/README.md).

2. Modify the header of strings.sh to reflect the translation (e.g., # Español (es)).

3. Anyone is free and encouraged to open translation [pull requests](https://duckduckgo.com/lite/?q=pull+request).
Alternatively, a _compressed_ archive of translated `strings.sh` and `README.md` files can be sent to the developer via Telegram (link below).

4. Use `acc -sl` (--set --lang): language switching wizard



---
## TIPS


### Generic

Emulate _battery idle mode_ with a voltage limit: `acc 101 -1; acc -s v 3920`.
The first command disables the regular - charging switch driven - pause/resume functionality.
The second sets a voltage limit that will dictate how much the battery should charge.
The battery enters a _pseudo idle mode_ when its voltage peaks.

Limiting the charging current to zero mA (`acc -sc 0`) may emulate idle mode as well.
`acc -sc -` restores the default limit.

Force fast charge: `appy_on_boot="/sys/kernel/fast_charge/force_fast_charge::1::0 usb/boost_current::1::0 charger/boost_current::1::0"`


### Google Pixel Devices

Force fast wireless charging with third party wireless chargers that are supposed to charge the battery faster: `apply_on_plug=wireless/voltage_max::9000000`.


### Using [Termux:API](https://wiki.termux.com/wiki/Termux:API) for Text-to-Speech


1) Install Termux, Termux:Boot and Termux:API APKs.
If you're not willing to pay for Termux add-ons, go for the F-Droid versions of these AND Termux itself.
Since package signatures mismatch, you can't install the add-ons from F-Droid if Termux was obtained from Play Store and vice versa.


2) Exclude Termux:Boot from battery optimization, then launch (to enable auto-start) and close it.


3) Paste and run the following on Termux, as a regular (non-root) user:
```
mkfifo ~/acc-fifo; mkdir -p ~/.termux/boot; pkg install termux-api; echo -e '#!/data/data/com.termux/files/usr/bin/sh\nwhile :; do\n  cat ~/acc-fifo\ndone | termux-tts-speak' > ~/.termux/boot/acc-tts.sh; chmod 0755 ~/.termux/boot/acc-tts.sh; sh ~/.termux/boot/acc-tts.sh &
```
Let that session run in the background.


4) ACC has the following:

auto_shutdown_alert_cmd (asac)
charg_disabled_notif_cmd (cdnc)
charg_enabled_notif_cmd (cenc)
error_alert_cmd (eac)

As the names suggest, these properties dictate commands acc/d should run on each event.
The default command is "vibrate <number of vibrations> <interval (seconds)>"

Let's assume you want the phone to say _Warning! Battery is low. System will shutdown soon._
To set that up, paste and run the following on a terminal, as root:

`echo -e "\nautoShutdownAlertCmd=('! pgrep -f acc-tts.sh || echo \"Warning! Battery is low. System will shutdown soon.\" > /data/data/com.termux/files/home/acc-fifo')" >> /data/adb/acc-data/config.txt`


That's it.
You only have to go through these steps once.



---
## FREQUENTLY ASKED QUESTIONS (FAQ)


> How do I report issues?

Open issues on GitHub or contact the developer on Facebook, Telegram (preferred) or XDA (links below).
Always provide as much information as possible.
Attach `/sdcard/Download/acc/acc-logs-*tar.bz2` - generated by `acc -le` _right after_ the problem occurs.
Refer back to `TROUBLESHOOTING > Diagnostics/Logs` for additional details.


> Why won't you support my device? I've been waiting for ages!

Firstly, have some extra patience!
Secondly, several systems don't have intuitive charging control files; I have to dig deeper - and oftentimes, improvise; this takes time and effort.
Lastly, some systems don't support custom charging control at all;  in such cases, you have to keep trying different kernels and uploading the respective power supply logs.
Refer back to `POWER SUPPLY LOGS (HELP NEEDED)`.


> Why, when and how should I calibrate the battery?

With modern battery management systems, that's generally unnecessary.

However, if your battery is underperforming, you may want to try the procedure described at https://batteryuniversity.com/index.php/learn/article/battery_calibration .


> I set voltage to 4080 mV and that corresponds to just about 75% charge.
But is it typically safer to let charging keep running, or to have the circuits turn on and shut off between defined percentage levels repeatedly?

It's not much about which method is safer.
It's specifically about electron stability: optimizing the pressure (voltage) and current flow.

As long as you don't set a voltage limit higher than 4200 mV and don't leave the phone plugged in for extended periods of time, you're good with that limitation alone.
Otherwise, the other option is actually more beneficial - since it mitigates high pressure (voltage) exposure/time to a greater extent.
If you use both, simultaneously - you get the best of both worlds.
On top of that, if you enable the cooldown cycle, it'll give you even more benefits.

Anyway, while the battery is happy in the 3700-4100 mV range, the optimal voltage for [the greatest] longevity is said\* to be ~3920 mV.

If you're leaving your phone plugged in for extended periods of time, that's the voltage limit to aim for.

Ever wondered why lithium ion batteries aren't sold fully charged? They're usually ~40-60% charged. Why is that?
Keeping a battery fully drained, almost fully drained or 70%+ charged for a long times, leads to significant (permanent) capacity loss

Putting it all together in practice...

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
Due to extenuating circumstances, that robot may not be upgraded as frequently as the car.
Upgrading the car regularly makes the driver happier - even though I doubt it has any emotion to speak of.
The back-end can be upgraded by flashing the latest ACC zip.
However, unless you have a good reason to do so, don't fix what's not broken.


> Does acc work also when Android is off?

No, but this possibility is being explored.
Currently, it does work in recovery mode, though.


> I have this wakelock as soon as charging is disabled. How do I deal with it?

The best solution is enforcing a charging switch that doesn't trigger a wakelock.
Refer back to `TROUBLESHOOTING > Charging Switch`.
A common workaround is having `resume_capacity = pause_capacity - 1`. e.g., resume_capacity=74, pause_capacity=75.



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

**v2020.7.26 (202007260)**
- General cleanup and optimizations
- Moved acc files in /sdcard/ to /sdcard/Download/acc/.
- Removed acc-init.sh in favor of service.sh.

**v2020.7.25 (202007250)**
- Updated documentation
- Workaround for network issues

**v2020.7.24 (202007240)**
- Compress logs with bzip2 -9.
- Fixed "chargingSwitch[*]: parameter not set".
- Updated framework-details.txt.
- Workaround for /data/adb/service.d/ not found
