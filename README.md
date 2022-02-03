# Advanced Charging Controller (ACC)


---
- [DESCRIPTION](#description)
- [LICENSE](#license)
- [DISCLAIMER](#disclaimer)
- [WARNINGS](#warnings)
- [DONATIONS](#donations)
- [PREREQUISITES](#prerequisites)
- [QUICK START GUIDE](#quick-start-guide)
  - [Notes](#notes)
- [BUILDING AND/OR INSTALLING FROM SOURCE](#building-andor-installing-from-source)
  - [Dependencies (Build)](#dependencies-build)
  - [Build Tarballs and Flashable Zips](#build-tarballs-and-flashable-zips)
    - [Notes](#notes-1)
  - [Install from Local Source or GitHub](#install-from-local-source-or-github)
    - [Notes](#notes-2)
- [DEFAULT CONFIGURATION](#default-configuration)
- [SETUP/USAGE](#setupusage)
  - [Terminal Commands](#terminal-commands)
- [PLUGINS](#plugins)
- [NOTES/TIPS FOR FRONT-END DEVELOPERS](#notestips-for-front-end-developers)
  - [Basics](#basics)
  - [Installing/Upgrading ACC](#installingupgrading-acc)
  - [Uninstalling ACC](#uninstalling-acc)
  - [Initializing ACC](#initializing-acc)
  - [Managing ACC](#managing-acc)
  - [The Output of --info](#the-output-of---info)
  - [Profiles](#profiles)
  - [More](#more)
- [TROUBLESHOOTING](#troubleshooting)
  - [`acc -t` hangs and/or All Charging Switches Fail](#acc--t-hangs-andor-all-charging-switches-fail)
  - [Battery Capacity (% Level) Doesn't Seem Right](#battery-capacity--level-doesnt-seem-right)
  - [Charging Switch](#charging-switch)
  - [Custom Max Charging Voltage And Current Limits](#custom-max-charging-voltage-and-current-limits)
  - [Diagnostics/Logs](#diagnosticslogs)
  - [Finding Additional/Potential Charging Switches Quickly](#finding-additionalpotential-charging-switches-quickly)
  - [Install, Upgrade, Stop and Restart Processes Seem to Take Too Long](#install-upgrade-stop-and-restart-processes-seem-to-take-too-long)
  - [Restore Default Config](#restore-default-config)
  - [Samsung, Charging _Always_ Stops at 70% Capacity](#samsung-charging-always-stops-at-70-capacity)
  - [Slow Charging](#slow-charging)
  - [Unable to Charge](#unable-to-charge)
  - [Unexpected Reboots](#unexpected-reboots)
  - [WARP, VOOC and Other Fast Charging Tech](#warp-vooc-and-other-fast-charging-tech)
  - [Why Did accd Stop?](#why-did-accd-stop)
- [POWER SUPPLY LOGS (HELP NEEDED)](#power-supply-logs-help-needed)
- [LOCALIZATION](#localization)
- [TIPS](#tips)
  - [_Always_ Limit the Charging Current If Your Battery is Old and/or Tends to Discharge Too Fast](#always-limit-the-charging-current-if-your-battery-is-old-andor-tends-to-discharge-too-fast)
  - [Current and Voltage Based Charging Control](#current-and-voltage-based-charging-control)
  - [Generic](#generic)
  - [Google Pixel Devices](#google-pixel-devices)
  - [Idle Mode and Alternatives](#idle-mode-and-alternatives)
- [FREQUENTLY ASKED QUESTIONS (FAQ)](#frequently-asked-questions-faq)
- [LINKS](#links)


---
## DESCRIPTION

ACC is an Android software mainly intended for [extending battery service life](https://batteryuniversity.com/article/bu-808-how-to-prolong-lithium-based-batteries).
In a nutshell, this is achieved through limiting charging current, temperature, and voltage.
Any root solution is supported.
Regardless of whether the system is rooted with Magisk, the installation is always "systemless".


---
## LICENSE

Copyright 2017-2022, VR25

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

To prevent fraud, do NOT mirror any link associated with this project.
Do NOT share builds (tarballs/zips)! Share official links instead.


---
## WARNINGS

ACC manipulates Android low level ([kernel](https://duckduckgo.com/lite/?q=kernel+android)) parameters which control the charging circuitry.
The author assumes no responsibility under anything that might break due to the use/misuse of this software.
By choosing to use/misuse it, you agree to do so at your own risk!

Some devices, notably Xiaomi phones, have a buggy PMIC (Power Management Integrated Circuit) that can be triggered by acc.
The issue blocks charging.
Ensure your battery does not discharge too low.
Using acc's auto shutdown feature is highly recommended.

Refer to [this XDA post](https://forum.xda-developers.com/t/rom-official-arrowos-11-0-android-11-0-vayu-bhima.4267263/post-85119331) for additional details.

[lybxlpsv](https://github.com/lybxlpsv) suggests booting into bootloader and then back into system to reset the PMIC.


---
## DONATIONS

Please, support the project with donations ([links](#links) at the bottom).
As the project gets bigger and more popular, the need for coffee goes up as well.


---
## PREREQUISITES

- [Must read - how to prolong lithium ion batteries lifespan](https://batteryuniversity.com/article/bu-808-how-to-prolong-lithium-based-batteries)
- Android or Android based OS
- Any root solution (e.g., [Magisk](https://github.com/topjohnwu/Magisk))
- [Busybox\*](https://github.com/search?o=desc&q=busybox+android&s=updated&type=Repositories) (only if not rooted with Magisk)
- [curl](https://github.com/search?o=desc&q=curl+android&s=updated&type=Repositories) (for acc --upgrade, optional)
- Non-Magisk users can enable acc auto-start by running /data/adb/vr25/acc/service.sh, a copy of, or a link to it - with init.d or an app that emulates it.
- Terminal emulator
- Text editor (optional)

\* A busybox binary can simply be placed in /data/adb/vr25/bin/.
Permissions (0700) are set automatically, as needed.
Precedence: /data/adb/vr25/bin/busybox > Magisk's busybox > system's busybox

Other executables or static binaries can also be placed in /data/adb/vr25/bin/ (with proper permissions) instead of being installed system-wide.


---
## QUICK START GUIDE


0. All commands/actions require root.

1. Install/upgrade: flash\* the zip or use a front-end app.
There are two additional ways of upgrading: `acc --upgrade` (online) and `acc --flash` (zip flasher).
Rebooting after installation/removal is generally unnecessary.

2. [Optional] run `acc` (wizard). That's the only command you need to remember.

3. [Optional] run `acc pause_capacity resume_capacity` (default `75 70`) to set the battery levels at which charging should pause and resume, respectively.

4. If you come across any issues, refer to the [troubleshooting](#troubleshooting), [tips](#tips) and [FAQ](#frequently-asked-questions-faq) sections below.
Read as much as you can prior to reporting issues and/or asking questions.
Oftentimes, solutions/answers will be right before your eyes.


### Notes

Steps `2` and `3` are optional because there are default settings.
For details, refer to the [default configuration](#default-configuration) section below.
Users are encouraged to try step `2` - to familiarize themselves with the available options.

Settings can be overwhelming. Start with what you understand.
The default configuration has you covered.
Don't ever feel like you have to configure everything. You probably shouldn't anyway - unless you really know what you're doing.

Uninstall: run `acc --uninstall` or flash\* `/data/adb/vr25/acc-data/acc-uninstaller.zip`.

ACC runs in some recovery environments as well.
Unless the zip is flashed again, manual initialization is required.
The initialization command is `/data/adb/vr25/acc/service.sh`.


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


### Install from Local Source or GitHub

- `[export installDir=<parent install dir>] sh install.sh` installs acc from the extracted source.

- `sh install-online.sh [-c|--changelog] [-f|--force] [-k|--insecure] [-n|--non-interactive] [%parent install dir%] [commit]` downloads and installs acc from GitHub - e.g., `sh install-online.sh dev`.
The order of arguments doesn't matter.
For upgrades, if `%parent install dir%` is not supplied, the original/current is used.

- `sh install-tarball.sh [module id, default: acc] [parent install dir (e.g., /data/data/mattecarra.accapp/files)]` installs the tarball (acc*gz) from the script's location.
The archive must be in the same directory as this script - and obtained from GitHub: https://github.com/VR-25/acc/archive/$commit.tar.gz ($commit examples: master, dev, v2020.5.20-rc).


#### Notes

- `install-online.sh` is the `acc --upgrade` back-end.

- The default parent installation directories, in order of priority, are: `/data/data/mattecarra.accapp/files/` (ACC App, but only if Magisk is not installed), `/data/adb/modules/` (Magisk) and `/data/adb/` (other root solutions).

- No argument/option is strictly mandatory.
The exception is `--non-interactive` for front-end apps.

- The `--force` option to `install-online.sh` is meant for re-installation and downgrading.

- `sh install-online.sh --changelog --non-interactive` prints the version code (integer) and changelog URL (string) when an update is available.
In interactive mode, it also asks the user whether they want to download and install the update.

- You may also want to read [Terminal Commands](#terminal-commands) > `Exit Codes` below.


---
## DEFAULT CONFIGURATION
```
#DC#

configVerCode=202201010
capacity=(-1 60 70 75 false false)
temperature=(40 60 90 65)
cooldownRatio=()
cooldownCurrent=
cooldownCustom=()
resetBattStats=(false false)
chargingSwitch=()
applyOnBoot=()
applyOnPlug=()
maxChargingCurrent=()
maxChargingVoltage=()
language=en
runCmdOnPause=()
ampFactor=
voltFactor=
loopCmd=()
prioritizeBattIdleMode=false
currentWorkaround=false


# WARNINGS

# Do not edit this in Windows Notepad, ever!
# It replaces LF (Linux/Unix) with CRLF (Windows) line endings.

# As you may have guessed, what is null by default, can be null.
# "language=" is interpreted as "language=en".
# Nullifying values that should not be null causes unexpected behavior.
# However, doing so with "--set var=" restores the default value of "var".
# In other words, for regular users, "--set" is safer than modifying the config file directly.

# Do not feel like you must configure everything!
# Do not change what you don't understand.


# NOTES

# The daemon does not have to be restarted after making changes to this file - unless one of the changes is charging_switch.

# A change to current_workaround (cw) only takes effect after an acc [re]initialization (install, upgrade or "accd --init") or system reboot.

# If those 2 variables are updated with "acc --set" (not acca --set), accd is restarted automatically (--init is implied as needed).


# BASICS

# capacity=(shutdown_capacity cooldown_capacity resume_capacity pause_capacity capacity_sync capacity_mask)

# temperature=(cooldown_temp max_temp max_temp_pause shutdown_temp)

# cooldownRatio=(cooldown_charge cooldown_pause)

# cooldownCustom=cooldown_custom=(file raw_value charge_seconds pause_seconds)

# cooldownCurrent=cooldown_current=[milliamps]

# resetBattStats=(reset_batt_stats_on_pause reset_batt_stats_on_unplug)

# chargingSwitch=charging_switch=(ctrl_file1 on off ctrl_file2 on off --)

# chargingSwitch=charging_switch=(milliamps)

# chargingSwitch=charging_switch=(3700)

# applyOnBoot=apply_on_boot=(ctrl_file1::value[::default] ctrl_file2::value[::default] ... --exit)

# applyOnPlug=apply_on_plug=(ctrl_file1::value[::default] ctrl_file2::value[::default] ...)

# maxChargingCurrent=max_charging_current=([value] ctrl_file1::value::default ctrl_file2::value::default ...)

# maxChargingVoltage=max_charging_voltage=([value] ctrl_file1::value::default ctrl_file2::value::default ...) --exit)

# maxChargingCurrent=max_charging_current=([value] ctrl_file1::value::default1 ctrl_file2::value::default2 ...)

# maxChargingVoltage=max_charging_voltage=([value] ctrl_file1::value::default1 ctrl_file2::value::default2 ...) --exit)

# language=lang=language_code

# runCmdOnPause=run_cmd_on_pause=(. script)

# ampFactor=amp_factor=[multiplier]

# voltFactor=volt_factor=[multiplier]

# loopCmd=loop_cmd=(. script)

# prioritizeBattIdleMode=prioritize_batt_idle_mode=boolean

# currentWorkaround=current_workaround=boolean


# VARIABLE ALIASES/SHORTCUTS

# cc cooldown_capacity
# rc resume_capacity
# pc pause_capacity
# cs capacity_sync
# cm capacity_mask

# sc shutdown_capacity
# ct cooldown_temp
# cch cooldown_charge
# cp cooldown_pause

# mt max_temp
# mtp max_temp_pause

# st shutdown_temp

# ccu cooldown_custom
# cdc cooldown_current

# rbsp reset_batt_stats_on_pause
# rbsu reset_batt_stats_on_unplug

# s charging_switch

# ab apply_on_boot
# ap apply_on_plug

# mcc max_charging_current
# mcv max_charging_voltage

# l lang
# rcp run_cmd_on_pause

# af amp_factor
# vf volt_factor

# lc loop_cmd
# pbim prioritize_batt_idle_mode
# cw current_workaround


# COMMAND EXAMPLES

# acc 85 80
# acc -s pc=85 rc=80
# acc --set pause_capacity=85 resume_capacity=80

# acc -s "s=battery/charging_enabled 1 0"
# acc --set "charging_switch=/proc/mtk_battery_cmd/current_cmd 0::0 0::1 /proc/mtk_battery_cmd/en_power_path 1 0"
# NOTE: "::" is used as a whitespace placeholder in "/proc/mtk_battery_cmd/current_cmd 0::0 0::1" charging switch only.

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

# acc -s loop_cmd="echo 0 \\> battery/input_suspend"

# acc -s cooldown_current=500

# acc -s st=60


# FINE, BUT WHAT DOES EACH OF THESE VARIABLES ACTUALLY MEAN?

# configVerCode #
# This is checked during updates to determine whether config should be patched. Do NOT modify.

# shutdown_capacity (sc) #
# When the battery is discharging and its capacity/voltage_now_millivolts <= sc and phone has been running for 15 minutes or more, acc daemon turns the phone off to reduce the discharge rate and protect the battery from potential damage induced by voltage below the operating range.
# sc=-1 disables it.

# cooldown_capacity (cc) #
# Capacity/voltage_now_millivolts at which the cooldown cycle starts.
# Cooldown reduces battery stress induced by prolonged exposure to high temperature and high charging voltage.
# It does so through periodically pausing charging for a few seconds (more details below).

# resume_capacity (rc) #
# Capacity or voltage_now_millivolts at which charging should resume.

# pause_capacity (pc) #
# Capacity or voltage_now_millivolts at which charging should pause.

# capacity_sync (cs) #
# Some devices, notably from the Pixel lineup, have a capacity discrepancy issue between Android and the kernel.
# capacity_sync forces Android to report the actual battery capacity supplied by the kernel.
# The discrepancy is usually detected and corrected automatically by accd.
# This setting overrides the automatic behavior.
# Besides, it also prevents Android from getting capacity readings below 2%, since some systems shutdown before battery level actually drops to 0%.

# capacity_mask (cm) #
# Implies capacity_sync.
# This forces Android to report "capacity = capacity * (100 / pause_capacity)", effectively masking capacity limits (more like capacity_sync on steroids).
# It also prevents Android from getting capacity readings below 2%, since some systems shutdown before battery level actually drops to 0%.

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

# shutdown_temp (st) #
# Shutdown the system if battery temperature >= this value.

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

# cooldown_current (cdc) #
# Instead of pausing charging periodically during the cooldown phase, limit the max charging current (e.g., to 500 mA)

# reset_batt_stats_on_pause (rbsp) #
# Reset battery stats after pausing charging.

# reset_batt_stats_on_unplug (rbsu) #
# Reset battery stats if the charger has been unplugged for 10 seconds.

# charging_switch (s) #
# If unset, acc cycles through its database and sets the first working switch/group that disables charging.
# If the set switch/group doesn't work, acc unsets chargingSwitch and repeats the above.
# If all switches fail to disable charging, chargingSwitch is unset and acc/d exit with error code 7.
# This automated process can be disabled by appending " --" to "charging_switch=...".
# e.g., acc -s s="battery/charge_enabled 1 0 --"
# acc -ss always appends " --".
# charging_switch=milliamps (e.g., 0, 250 or 500) enables current-based charging control.
# If charging switch is set to 3700 (millivolts), acc stops charging by limiting voltage.
# For details, refer to the readme's tips section.
# Unlike the original variant, this kind of switch is never unset automatically.
# Thus, in this case, appending " --" to it leads to invalid syntax.
# A daemon restart is required after changing this (automated by "acc --set").

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

# lang (l) #
# acc language, managed with "acc --set --lang" (acc -s l).

# run_cmd_on_pause (rcp) #
# Run commands* after pausing charging.
# * Usually a script ("sh some_file" or ". some_file")

# amp_factor (af) #
# volt_factor (vf) #
# Unit multiplier for conversion (e.g., 1V = 1000000 Microvolts)
# ACC can automatically determine the units, but the mechanism is not 100% foolproof.
# e.g., if the input current is too low, the unit is miscalculated.
# This issue is rare, though.
# Leave these properties alone if everything is running fine.

# loop_cmd (lc) #
# This is meant for extending accd's functionality.
# It is periodically executed by is_charging() - which is called regularly, within the main accd loop.
# The boolean isCharging is available.
# Refer back to COMMAND EXAMPLES.

# prioritize_batt_idle_mode (pbim) #
# If enabled charging switches that support battery idle mode take precedence.
# It is only used when charging_switch is not set.
# This is disabled by default due to issues on Samsung (store_mode) and other devices.

# current_workaround (cw) #
# Only use current control files whose paths match "batt" (default: false).
# This is necessary only if the current limit affects both input and charging current values.
# Try this if low current values don't work.
# "accd --init" is required after changing this (automated by "acc --set").

#/DC#
```

---
## SETUP/USAGE


As the [default configuration](#default-configuration) (above) suggests, ACC is designed to run out of the box, with little to no customization/intervention.

The only command you have to remember is `acc`.
It's a wizard you'll either love or hate.

If you feel uncomfortable with the command line, skip this section and use a front-end app instead.

Alternatively, you can use a `text editor` to modify `/data/adb/vr25/acc-data/config.txt`.
The config file itself has configuration instructions.
Those are the same found in the [default configuration](#default-configuration) section, above.


### Terminal Commands
```
#TC#

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

  acc[d] -x [options] [args]   Sets log=/sdcard/acc[d]-${device}.log; useful for debugging unwanted reboots

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

  -l|--log -e|--export   Export all logs to /data/adb/vr25/acc-data/logs/acc-logs-$deviceName.tar.gz
    e.g., acc -l -e

  -le   Same as -l -e

  -p|--parse [<base file> <file to parse>]|[file to parse]   Helps find potential charging switches quickly, for any device
    e.g.,
      acc -p   Parse /logs/power_supply-\*.log and print potential charging switches not present in /ch-switches
      acc -p /sdcard/power_supply-harpia.log   Parse the given file and print potential charging switches that are not already in /ch-switches
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
      rm /data/adb/vr25/acc-data/config.txt (failsafe)

  -sr   Same as above

  -s|--set s|charging_switch   Enforce a specific charging switch
    e.g., acc -s s

  -ss    Same as above

  -s|--set s:|chargingSwitch:   List known charging switches
    e.g., acc -s s:

  -ss:   Same as above

  -s|--set v|--voltage [millivolts|-] [--exit]   Set/print/restore_default max charging voltage (range: 3700-4300 Millivolts)
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

#/TC#
```

---
## PLUGINS

Those are scripts that override functions and some global variables.
They should be placed in `/data/adb/vr25/acc-data/plugins/`.
Files are sorted and sourced.
Filenames shall not contain spaces.
Hidden files and those without the `.sh` extension are ignored.

There are also _volatile_ plugins (gone on reboot, useful for debugging): `/dev/.vr25/acc/plugins/`.
Those override the permanent.

A daemon restart is required to load new/modified plugins.


---
## NOTES/TIPS FOR FRONT-END DEVELOPERS


### Basics

ACC does not require Magisk.
Any root solution is fine.

Use `/dev/.vr25/acc/acca` instead of regular `acc`.
It's optimized for front-ends, guaranteed to be readily available after installation/upgrades and significantly faster than its `acc` counterpart.
`acca --set prop1=bla prop2="bla bla" ...` runs asynchronously (non-blocking mode) - meaning, multiple instances of it work in parallel.

It may be best to use long options over short equivalents - e.g., `--set charging_switch=` instead of `-s s=`.
This makes code more readable (less cryptic).

Include provided descriptions of ACC features/settings in your app(s).
Provide additional information (trusted) where appropriate.
Explain settings/concepts as clearly and with as few words as possible.

Take advantage of exit codes.
Refer back to `SETUP/USAGE > [Terminal Commands](#terminal-commands) > Exit Codes`.


### Installing/Upgrading ACC

This should be trivial.
The simplest way is flashing acc from Magisk manager.

Alternatively, `install.sh`, `install-online.sh` or `install-tarball.sh` can be used.
For details, refer back to [install from local source or GitHub](#install-from-local-source-or-github).


### Uninstalling ACC

Either run `/dev/.vr25/acc/uninstall` (no reboot required; **charger must be plugged**) or uninstall from Magisk manager and reboot.


### Initializing ACC

On boot_completed receiver and main activity, run:

`[ -f /dev/.vr25/acc/acca ] || /data/adb/vr25/acc/service.sh`

Explanation:

ACC's working environment must be initialized - i.e., by updating the stock charging config (for restoring without a reboot) and pre-processing data for greater efficiency.
This is done exactly once after boot.
If it were done only after installation/upgrade, one would have to reinstall/upgrade acc after every kernel update.
That's because kernel updates often change the default power supply drivers settings.

Since acc's core executables are dynamic ([expected to] change regularly), those are linked to `/dev/.vr25/acc/` to preserve the API.
The links must be recreated once after boot (/dev/ is volatile).

`accd` is a symbolic link to `service.sh`.
If service.sh is executed every time the `main activity` is launched, accd will be repeatedly restarted for no reason.

Notes

- This "manual" initialization is only _strictly_ required if Magisk is not installed - and only once per boot session. In other words, Magisk already runs service.sh shortly after boot.
- ACC's installer always initializes it.


### Managing ACC

As already stated, front-ends should use the executable `/dev/.vr25/acc/acca`.
Refer to the [default configuration](#default-configuration) and [terminal commands](#terminal-commands) sections above.

The default config reference has a section entitled variable aliases/shortcuts.
Use ONLY those with `/dev/.vr25/acc/acca --set`!

To clarify, `/dev/.vr25/acc/acca --set chargingSwitch=...` is not supported!
Use either `s` or `charging_switch`.
`chargingSwitch` and all the other "camelcase" style variables are for internal use only (i.e., private API).

Do not parse the config file directly.
Use `--set --print` and `--set --print-default`.
Refer back to [terminal commands](#terminal-commands) for details.


### The Output of --info

It comes from the kernel, not acc itself.
Some kernels provide more information than others.

Most of the lines are either unnecessary (e.g., type: everyone knows that already) or unreliable (e.g., health, speed).

Here's what one should focus on:

STATUS=Charging # Charging, Not charging (idle mode) or Discharging
CAPACITY=50 # Battery level, 0-100
TEMP=281 # Always in (ºC * 10)
CURRENT_NOW=0 # Charging current (Amps)
VOLTAGE_NOW=3.861 # Charging voltage (Volts)
POWER_NOW=0 # (CURRENT_NOW * VOLTAGE_NOW) (Watts)

Note that the power information refers to what is actually supplied to the battery, not what's coming from the adapter.
External power is always converted before it reaches the battery.


### Profiles

Those are simply different config files.
A config path can be supplied as first argument to `acca` and second to `accd` executables.

Examples:

_Copy the config:_

Current config: `/dev/.vr25/acc/acca --config cat > /path/to/new/file`

Default config: `/dev/.vr25/acc/acca /path/to/new/file --version` (`--version` can be replaced with any option + arguments, as seen below.)

_Edit the copy:_

`/dev/.vr25/acc/acca /path/to/new/file --set pause_capacity=75 resume_capacity=70` (if the file does not exist, it is created as a copy of the default config.)

_Use the copy:_

`/dev/.vr25/acc/accd --init /path/to/new/file` (the daemon is restarted with the new config.)

_Back to the main config:_

`/dev/.vr25/acc/accd --init`


### More

ACC daemon does not have to be restarted after making changes to the config.
It picks up new changes within seconds.

There are a few exceptions:

- `charging_switch` (`s`) requires a daemon restart (`/dev/.vr25/acc/accd`).
- `current_workaround` (`cw`) requires a full re-initialization (`/dev/.vr25/acc/accd --init`).

This information is in the [default configuration](#default-configuration) section as well.


---
## TROUBLESHOOTING


### `acc -t` hangs and/or All Charging Switches Fail

Create a file `/data/adb/vr25/acc-data/curr` (persistent) or `/dev/.vr25/acc/curr` (volatile) to disable enhanced battery status check.
In enhanced mode, if battery status is "charging" and the absolute value of current is <= 50 mA, the status is considered "not charging".
Although rare, this can cause charging control issues on some devices.
Hence, one may want to see if disabling it makes a difference.
However, before trying this, it's recommend to test a different power source.
Fast charging, in particular, is known for overriding/blocking custom charging control settings.


### Battery Capacity (% Level) Doesn't Seem Right

When Android's battery level differs from that of the kernel, ACC daemon automatically syncs it by stopping the battery service and feeding it the real value every few seconds.

Pixel devices are known for having battery level discrepancies for the longest time.

If your device shuts down before the battery is actually empty, capacity_sync or capacity_mask may help.
Refer to the [default configuration](#default-configuration) section above for details.


### Charging Switch

By default, ACC uses whichever [charging switch](https://github.com/VR-25/acc/blob/dev/acc/charging-switches.txt) works ("automatic" charging switch).
However, things don't always go well.

- Some switches are unreliable under certain conditions (e.g., while display is off).

- Others hold a [wakelock](https://duckduckgo.com/lite/?q=wakelock).
This causes fast battery drain when charging is paused and the device remains plugged.

- Charging keeps being re-enabled by the system, seconds after acc daemon disables it.
As a result, the battery eventually charges to 100% capacity, regardless of pause_capacity.

- High CPU load (drains battery) was also reported.

- In the worst case scenario, the battery status is reported as `discharging`, while it's actually `charging`.

In such situations, one has to enforce a switch that works as expected.
Here's how to do it:

1. Run `acc --test` (or `acc -t`) to see which switches work.
2. Run `acc --set charging_switch` (or `acc -ss`) to enforce a working switch.
3. Test the reliability of the set switch. If it doesn't work properly, try another.

Since not everyone is tech savvy, ACC daemon automatically applies settings for certain devices to minimize charging switch issues.
These are in `acc/oem-custom.sh`.


### Custom Max Charging Voltage And Current Limits

Unfortunately, not all kernels support these features.
While custom current limits are supported by most (at least to some degree), voltage tweaking support is _exceptionally_ rare.

That said, the existence of potential voltage/current control file doesn't necessarily mean these are writable* or the features, supported.

\* Root is not enough.
Kernel level permissions forbid write access to certain interfaces.

Sometimes, restoring the default current may not work without a system reboot.
A workaround is setting the default max current value or any arbitrary high number (e.g., 9000 mA).
Don't worry about frying things.
The phone will only draw the max it can take.

**WARNING**: limiting voltage causes battery state of charge (SoC) deviation on some devices.
The  battery management system self-calibrates constantly, though.
Thus, as soon as the default voltage limit is restored, it'll start "fixing" itself.

Limiting current, on the other hand, has been found to be universally safe.
Some devices do not support just any current value, though.
That's not to say out-of-range values cause issues.
These are simply ignored.

If low current values don't work, try setting `current_workaround=true` (takes effect after `accd --init`.
Refer to the [default configuration](#default-configuration) section for details.

One can override the default lists of max charging current/voltage control files by copying `acc/ctrl-files.sh` to `/data/adb/vr25/acc-data/plugins/` and modifying it accordingly.
Note that default limits must be restored prior to that to avoid the need for a system reboot.
Reminder: a daemon restart is required to load new/modified plugins.


### Diagnostics/Logs

Volatile logs (gone on reboot) are stored in `/dev/.vr25/acc/` (.log files only).
Persistent logs reside in `/data/adb/vr25/acc-data/logs/`.

`acc -le` exports all acc logs, plus Magisk's and extras to `/data/adb/acc-data/logs/acc-$device_codename.tar.gz`.
The logs do not contain any personal information and are never automatically sent to the developer.
Automatic exporting (local) happens under specific conditions (refer back to `SETUP/USAGE > Terminal Commands > Exit Codes`).


### Finding Additional/Potential Charging Switches Quickly

1. Generate a list of potential charging switches: `acc -p > /sdcard/acc-p.txt`.

2. Remove from the list, all lines that you're SURE don't resemble a charging switch.

3. Test all: `acc -t /sdcard/acc-p.txt`.

Note that some control files may trigger reboots or kernel panics.
ACC automatically blacklists these, so that the user can continue testing (step 2) after each reboot.


### Install, Upgrade, Stop and Restart Processes Seem to Take Too Long

The daemon stop process implies complete reversal of changes made to the charging management system.
Sometimes, **this requires the charger to be plugged**.
That's because some devices have kernel bugs and/or bad charging driver implementations.
That said, accd is always stopped _gracefully_ to ensure the restoration takes place.
One who knows what they're doing, can force-stop accd by running `pkill -9 -f accd`.


### Restore Default Config

This can potentially save a lot of time and grief.

`acc --set --reset`, `acc -sr` or `rm /data/adb/vr25/acc-data/config.txt` (failsafe)


### Samsung, Charging _Always_ Stops at 70% Capacity

This is a device-specific issue (by design?).
It's caused by the _store_mode_ charging control file.
Switch to _batt_slate_mode_ to prevent it.
Refer back to [charging switch](#charging-switch) above for details on that.


### Slow Charging

At least one of the following may be the cause:

- Charging current and/or voltage limits
- Cooldown cycle (non optimal charge/pause ratio, try 50/10 or 50/5)
- Troublesome charging switch (refer back to `TROUBLESHOOTING > Charging Switch`)
- Weak adapter and/or power cord


### Unable to Charge

Refer back to the [warnings](#warnings) section above.


### Unexpected Reboots

Wrong/troublesome charging control files may trigger unwanted reboots.
ACC blacklist these automatically (registered in `/data/adb/vr25/acc-data/logs/write.log`, with a leading hashtag).
Sometimes, there may be false positives in there - i.e., due to unexpected reboots caused by something else. Thus, if a control file that used to work, suddenly does not, see if it was blacklisted (`acc -t` also reveals blacklisted switches).
Send `write.log` to the developer once the reboots have stopped.


### WARP, VOOC and Other Fast Charging Tech

Charging switches may not work reliably with the original power adapter.
This has nothing to do with acc.
It's bad design by the OEMs themselves.
If you face issues, either try a different charging switch or a regular power brick (a.k.a., slow charger).
You may also want to try stopping charging by limiting current/voltage.


### Why Did accd Stop?

Run `acc -l tail` to find out.
This will print the last 10 lines of the daemon log file.

A relatively common exit code is `7` - meaning all charging switches failed to disable charging.
It happens due to kernel issues (refer to the previous subsection - [charging switch](#charging-switch)).
The daemon only stops due to this if acc is set to automatically determine the switches to use (default behavior).
Manually setting a working switch with `acc -ss` or `acc -s s="SWITCHES GO HERE --"` prevents this issue.


---
## POWER SUPPLY LOGS (HELP NEEDED)

Please run `acc -le` and upload `/data/adb/vr25/acc-data/logs/power_supply-*.log` to [my dropbox](https://www.dropbox.com/request/WYVDyCc0GkKQ8U5mLNlH) (no account/sign-up required).
This file contains invaluable power supply information, such as battery details and available charging control files.
A public database is being built for mutual benefit.
Your cooperation is greatly appreciated.

Privacy Notes

- Name: random/fake
- Email: random/fake

See current submissions [here](https://www.dropbox.com/sh/rolzxvqxtdkfvfa/AABceZM3BBUHUykBqOW-0DYIa?dl=0).


---
## LOCALIZATION


Currently Supported Languages and Translation Levels (full, good, fair, minimal)

- Chinese, simplified (zh-rCN): minimal
- Chinese, traditional (zh-rTW): minimal
- English (en): full
- German (de_DE): fair
- Indonesia (id): minimal
- Portuguese, Portugal (pt-PT): minimal


Translation Notes

1. Start with copies of [acc/strings.sh](https://github.com/VR-25/acc/blob/dev/acc/strings.sh) and, optionally, [README.md](https://github.com/VR-25/acc/blob/dev/README.md).

2. Modify the header of strings.sh to reflect the translation (e.g., # Español (es)).

3. Anyone is free and encouraged to open translation [pull requests](https://duckduckgo.com/lite/?q=pull+request).
Alternatively, a _compressed_ archive of translated `strings.sh` and `README.md` files can be sent to the developer via Telegram (link below).

4. Use `acc -sl` (--set --lang): language switching wizard or `acc -s l=<lang_string>` to set a language.


---
## TIPS


### _Always_ Limit the Charging Current If Your Battery is Old and/or Tends to Discharge Too Fast

This extends the battery's lifespan and may even _reduce_ its discharge rate.

750-1000mA is a good range for regular use.

500mA is a comfortable minimum - and also very compatible.

If your device does not support custom current limits, use a dedicated ("slow") power adapter.


### Current and Voltage Based Charging Control

Enabled by setting charging_switch=milliamps or charging_switch=3700 (millivolts) (e.g., `acc -s s=0`, `acc -s s=250`, `acc -s s=3700`, `acc -ss` (wizard)).

Essentially, this turns current/voltage control files into _[pseudo] charging switches_.

A common and positive side effect of this is _[pseudo] idle mode_ - i.e., the battery may work just as a power buffer.

Note: depending on the kernel - at `pause_capacity`, the charging status may either change ("discharging" or "not charging") or remain still ("charging" - not an issue).
If it changes intermittently, the current is too low; increment it until the issue goes away.


### Generic

Emulate _battery idle mode_ with a voltage limit: `acc -s pc=101 rc=0 mcv=3920`.
The first two arguments disable the regular charging pause/resume functionality.
The last sets a voltage limit that will dictate how much the battery should charge.
The battery enters a _[pseudo] idle mode_ when its voltage peaks.
Essentially, it works as a power buffer.

A similar effect can be achieved with settings such as `acc 60 59` (percentages) and `acc 3920` (millivolts).

Yet another way is limiting charging current to 0-250 mA or so (e.g., `acc -sc 0`).
`acc -sc -` restores the default limit.
Alternatively, one can experiment with `acc -s s=0` and/or `acc -s s=3700`, which uses current/voltage control files as charging switches.

Force fast charge: `appy_on_boot="/sys/kernel/fast_charge/force_fast_charge::1::0 usb/boost_current::1::0 charger/boost_current::1::0"`


### Google Pixel Devices

Force fast wireless charging with third party wireless chargers that are supposed to charge the battery faster: `apply_on_plug=wireless/voltage_max::9000000`.

This may not work on all Pixel devices.
There are no negative consequences when it doesn't.


### Idle Mode and Alternatives

1 - Charging switch that supports idle mode (the obvious winner).
Note that self discharge is a thing.
This is as if the battery were physically disconnected.
Extremely slow discharge rate is expected.

2 - `charging_switch=0`: if current fluctuates, also set `current_workaround=true` (only takes affect after a reboot).
If this method works, the behavior is exactly the same as `#1`.

3 - `charging_switch=3920`: only works on devices that actually support voltage control.
Unlike regular idle mode, this maintains 3920 mV (_the sweet spot_) indefinitely.
This is not good with higher voltages.
We're trying to minimize battery stress as much as possible.
Maintaining a voltage higher than 3920 for a long time is _not_ recommended.

4 - `acc 3920`: this is short for _acc 3920 3870_ (a 50 mV difference).
It tries to maintain 3920 mV without voltage control support.
Yes, it's definitely not a joke.
This works with regular charging switches and voltage readings.

5 - `acc 45 44`: this closely translates to 3920 mV under most circumstances.
Voltage and capacity (%) do not have a linear relationship.
Voltage varies with temperature, battery chemistry and age.


---
## FREQUENTLY ASKED QUESTIONS (FAQ)


> How do I report issues?

Open issues on GitHub or contact the developer on Facebook, Telegram (preferred) or XDA (links below).
Always provide as much information as possible.
Attach `/data/adb/vr25/acc-data/logs/acc-logs-*tar.gz` - generated by `acc -le` _right after_ the problem occurs.
Refer back to `TROUBLESHOOTING > Diagnostics/Logs` for additional details.


> Why won't you support my device? I've been waiting for ages!

Firstly, have some extra patience!
Secondly, several systems don't have intuitive charging control files; I have to dig deeper - and oftentimes, improvise; this takes time and effort.
Lastly, some systems don't support custom charging control at all;  in such cases, you have to keep trying different kernels and uploading the respective power supply logs.
Refer back to `POWER SUPPLY LOGS (HELP NEEDED)`.


> Why, when and how should I calibrate the battery manager?

With modern battery management systems, that's generally unnecessary.

However, if your battery is underperforming, you may want to try the procedure described at https://batteryuniversity.com/article/bu-603-how-to-calibrate-a-smart-battery .

ACC automatically optimizes system performance and battery utilization, by forcing `bg-dexopt-job` on daemon [re]start, if charging.


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

\* https://batteryuniversity.com/article/bu-808-how-to-prolong-lithium-based-batteries/


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

- [Daily Job Scheduler](https://github.com/VR-25/djs)
- [Donate - Airtm, username: ivandro863auzqg](https://app.airtm.com/send-or-request/send)
- [Donate - Liberapay](https://liberapay.com/vr25)
- [Donate - Patreon](https://patreon.com/vr25)
- [Donate - PayPal or Credit/Debit Card](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=iprj25@gmail.com&lc=US&item_name=VR25+is+creating+free+and+open+source+software.+Donate+to+suppport+their+work.&no_note=0&cn=&currency_code=USD&bn=PP-DonationsBF:btn_donateCC_LG.gif:NonHosted)
- [Facebook Page](https://fb.me/vr25xda)
- [Frontend - ACC App](https://github.com/MatteCarra/AccA/releases)
- [Frontend - ACC Settings](https://github.com/CrazyBoyFeng/AccSettings)
- [Must Read - How to Prolong Lithium Ion Batteries Lifespan](https://batteryuniversity.com/article/bu-808-how-to-prolong-lithium-based-batteries)
- [Telegram Channel](https://t.me/vr25_xda)
- [Telegram Group](https://t.me/acc_group)
- [Telegram Profile](https://t.me/vr25xda)
- [Upstream Repository](https://github.com/VR-25/acc)
- [XDA Thread](https://forum.xda-developers.com/apps/magisk/module-magic-charging-switch-cs-v2017-9-t3668427)
