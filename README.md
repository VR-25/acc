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

To prevent fraud, do NOT mirror any link associated with this project; do NOT share builds (zips or tarballs)! Share official links instead.



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
If you're reading this from Magisk Manager > Downloads, tap here to open the documentation.
Once there, if you're lazy, jump to the quick start section.



---
## PREREQUISITES

- Android or Android based OS
- Any root solution (e.g., [Magisk](https://github.com/topjohnwu/Magisk/))
- [Busybox*](https://github.com/search?o=desc&q=busybox+android&s=updated&type=Repositories/) (only if not rooted with Magisk)
- Terminal emulator (recommended: [Termux](https://f-droid.org/en/packages/com.termux/))
- [curl**](https://github.com/search?o=desc&q=curl+android&s=updated&type=Repositories/) (for acc --upgrade)
- Text editor (optional)

\* Instead of a regular install, the binary can simply be placed in /data/adb/.
That's a fallback path. ACC sets permissions (rwx------) as needed.
Precedence: Magisk busybox > system busybox > /data/adb/busybox

\*\* Termux has it. Paste and run the following to set it up for `acc --upgrade`:

`pkg install tsu && echo -e "\nalias acc=/sbin/acc" >> ~/.bashrc && . ~/.bashrc`

Then, whenever you need `acc --upgrade`, run it as follows:
```
$ tsu
# acc -u
```


---
## QUICK START GUIDE


1. Unless Magisk is not installed, always install/upgrade from Magisk Manager or ACC front-end (e.g. AccA).
Apps such as EX/Franco Kernel Managers are also good options.
There are yet two more ways of upgrading: `acc -u` (online) and `acc -F` (zip flasher).
Rebooting after installation/removal is unnecessary.

2. [Optional] run `su -c acc pause_capacity resume_capacity` (default `75 70`) or use a front-end app to change settings.

3. If you come across an issue, refer to the `TROUBLESHOOTING`, `TIPS` and `FAQ` sections below.
Read as much as you can, before asking the developer or opening an issue on GitHub.
Oftentimes, solutions will be right before your eyes.


### Notes

- ACC cannot be installed/upgraded from recovery (e.g., TWRP).

- Step `2` is optional, because there are default settings.
For details, refer to the `DEFAULT CONFIGURATION` section below.

- Settings can be overwhelming. Start with what you understand.
The default configuration has you covered.
Don't ever feel like you have to configure everything. You probably shouldn't anyway - unless you really know what you're doing.

- Uninstall: depending on the installed variant (e.g., app back-end or Magisk module), you can use Magisk Manager (app), [Magisk Manager for Recovery Mode (utility)](https://github.com/VR-25/mm/), or clear the front-end app's data.
Two universal methods are: `su -c acc --uninstall` and `/sdcard/acc-uninstaller.zip` (flashable uninstaller).



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

- To update the local source code, run `git pull --force` or redownload (with wget/curl) as described above.


### Install from Local Sources and GitHub

- `sh install-tarball.sh acc` installs the tarball (acc*gz) from the script's location.
The archive must be obtained from GitHub: https://github.com/VR-25/acc/archive/$reference.tar.gz ($reference examples: master, dev, 201908290).

- `sh install-current.sh` installs acc from the extracted source.

- `sh install-latest.sh [-c|--changelog] [-f|--force] [-n|--non-interactive] [%install dir%] [reference]` downloads and installs acc from GitHub. e.g., `sh install-latest.sh dev`


#### Notes

- `install-current.sh` and `install-tarball.sh` take an optional _parent installation directory_ argument (e.g., sh install-current.sh /data - this will install acc in /data/acc/).

- `install-latest.sh` is the `acc --upgrade` back-end.

- The order of arguments doesn't matter.

- The default parent installation directories, in order of priority, are: `/data/data/mattecarra.accapp/files/`, `/sbin/.magisk/modules/` and `/data/adb/`.

- No argument/option is strictly mandatory. The exception is `--non-interactive` for front-end apps.
Unofficially supported front-ends must specify the parent installation directory. Otherwise, the installer will follow the order above.

- Remember that unlike the other two installers, `install-latest.sh` requires the _parent installation directory_ to be enclosed in `%` (e.g., sh install-latest.sh %/data% --non-interactive).

- The `--force` option to install-latest.sh is meant for reinstallation and downgrading.

- `sh install-latest.sh --changelog --non-interactive` prints the version code (integer) and changelog URL (string) when an update is available.
In interactive mode, it also asks the user whether they want to download and install the update.

- You may also want to read `NOTES/TIPS FOR FRONT-END DEVELOPERS > Exit Codes` below.



---
## SETUP


### Any Root Solution

Install/upgrade: unless Magisk is not installed, always install/upgrade from Magisk Manager or ACC front-end (e.g. AccA).
Apps such as EX/Franco Kernel Managers are also good options.
There are yet two more ways of upgrading: `acc -u` (online) and `acc -F` (zip flasher).

Uninstall: depending on the installed variant (e.g., app back-end or Magisk module), you can use Magisk Manager (app), [Magisk Manager for Recovery Mode (utility)](https://github.com/VR-25/mm/), or clear the front-end app's data.
Two universal methods are: `su -c acc --uninstall` and `/sdcard/acc-uninstaller.zip` (flashable uninstaller).


### Notes

- ACC cannot be installed/upgraded from recovery (e.g., TWRP).

Rebooting after installing, upgrading or uninstalling is unnecessary.

The daemon is automatically started right after installation.

For non-Magisk install, busybox binary is required. Refer back to the `PREREQUISITES` section for details.
Additionally, `$installDir/acc/acc-init.sh` must be executed on boot to initialize acc.



---
## DEFAULT CONFIGURATION
```
#DC#

configVerCode=202003030
capacity=(-1 60 70 75 +0 false)
temperature=(70 80 90)
coolDownRatio=()
coolDownCapacity=()
coolDownCurrent=()
coolDownTemp=()
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


# BASIC EXPLANATION

# capacity=(shutdown_capacity cooldown_capacity resume_capacity pause_capacity capacity_offset capacity_sync)

# temperature=(cooldown_temp max_temp max_temp_pause)

# coolDownRatio=(cooldown_charge cooldown_pause)

# resetBattStats=(reset_batt_stats_on_pause reset_batt_stats_on_unplug)

# loopDelay=(loop_delay_charging loop_delay_discharging)

# chargingSwitch=charging_switch=(file1 on off file2 on off)

# applyOnBoot=apply_on_boot=(file1::value1::default1 file2::value2::default2 fileN::valueN::defaultN --exit)

# applyOnPlug=apply_on_plug=(file1::value1::default1 file2::value2::default2 fileN::valueN::defaultN)

# maxChargingCurrent=max_charging_current=(file1::value1::default1 file2::value2::default2 fileN::valueN::defaultN)

# maxChargingVoltage=max_charging_voltage=(file1::value1::default1 file2::value2::default2 fileN::valueN::defaultN --exit)

# rebootOnPause=reboot_on_pause

# switchDelay=switch_delay

# language=lang

# wakeUnlock=wake_unlock=(wakelock1 wakelock2 wakelockN)

# prioritizeBattIdleMode=prioritize_batt_idle_mode

# forceChargingStatusFullAt100=force_charging_status_full_at_100

# runCmdOnPause=run_cmd_on_pause=(sh|. script)

# dynPowerSaving=dyn_power_saving


# VARIABLE ALIASES (SORTCUTS)

# sc shutdown_capacity
# cc cooldown_capacity
# rc resume_capacity
# pc pause_capacity
# co capacity_offset
# cs capacity_sync

# ct cooldown_temp
# mt max_temp
# mtp max_temp_pause

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
# fs force_charging_status_full_at_100
# rcp run_cmd_on_pause
# dps dyn_power_saving


# COMMAND EXAMPLES

# acc 85 80
# acc -s rc=80 pc=85
# acc -s capacity[2]=80 capacity[3]=85
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


# FINE, BUT WHAT DOES EACH OF THESE VARIABLES ACTUALLY MEAN?

# configVerCode #
# This is checked during updates - to determine whether config should be patched. Do NOT modify.

# shutdown_capacity (sc) #
# When the battery is discharging and its capacity <= sc, acc daemon turns the phone off to reduce the discharge rate and protect the battery from pottential damage induced by voltages below the operating range.

# cooldown_capacity (cc) #
# Capacity at which the cooldown cycle starts.
# Cooldown reduces battery stress induced by prolonged exposure to high temperature and high charging voltage.
# It does so through periodically pausing charging for a few seconds (more details below).

# resume_capacity (rc) #
# Capacity at which charging should resume.

# pause_capacity (pc) #
# Capacity at which charging should pause.

# capacity_offset (co) #
# Change this only if your system reports incorrect battery capacity ("acc -i" (BMS) vs "dumpsys battery" (system)).
# Pixel devices are know for having this issue.

# capacity_sync (cs) #
# This is an alternative to capacity_offset.
# It tells acc whether the battery capacity reported by Android should be updated every few seconds to reflect the actual value from the battery management system.
# Most users would prefer this over capacity_offset.
# It's more powerful, but has a cosmetic nuisance: delays in charging status reports.
# Such inconvenience is not a bug, nor can it be eliminated at this point.

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

# reset_batt_stats_on_pause (rbsp) #
# Reset battery stats after pausing charging.

# reset_batt_stats_on_unplug (rbsu) #
# Reset battery stats after unplugging the charger and loop_delay_discharging (seconds) have passed.
# If the charger is plugged within the first loop_delay_discharging (seconds) interval, the operation is aborted.

# loop_delay_charging (ldc) #
# loop_delay_discharging (ldd) #
# These are delays (seconds) between loop iterations.
# The lower they are, the faster acc responsiveness is - but possibly at the cost of more CPU time.
# Don't touch these (particularly ldd), unless you know exactly what you're doing.

# charging_switch (s) #
# If unset, acc cycles through its database and uses whatever works.

# apply_on_boot (ab) #
# Settings to apply on boot or daemon start/restart.
# The --exit flag (refer back to applyOnBoot=...) tells the daemon to stop after applying settings.
# When the --exit flag is not set, default values are restored when the daemon stops.

# apply_on_plug (ap) #
# Settings to apply on plug.
# This exists because some /sys files (e.g., current_max) are reset on charger re-plug.
# Default values are restored on unplug and when the daemon stops.

# max_charging_current (mcc) #
# apply_on_plug dedicated to current control
# This is managed with "acc --set --current" commands.
# Refer back to the command examples.

# max_charging_voltage (mcv) #
# apply_on_boot dedicated to voltage control
# This is managed with "acc --set --voltage" commands.

# reboot_on_pause (rp) #
# If this doesn't make sense to you, you probably don't need it.
# Essentially, this is a timeout (seconds) before rebooting (after pausing charging).
# This reboot is a workaround for a firmware issue that causes abnormally fast battery drain after charging is paused on certain devices.
# The issue has reportedly been fixed by the OEM. So, this could just as well not be here.

# switch_delay (sd) #
# Delay (seconds) between charging status checks after toggling charging switches
# Most devices/switches work with a value of 1.
# Some devices may require a delay as high as 3. The optimal max is probably 3.5.
# If a charging switch seems to work intermittently, or fails completely, increasing this value may fix the issue.
# You absolutely should increase this value if "acc -t --" reports total failure.

# lang (l) #
# acc language, managed with "acc --set --lang".

# wake_unlock (wu) #
# This is an attempt to release wakelocks acquired after disabling charging.
# It may or may not work - and may even cause unexpected side effects. More testing is needed.

# prioritize_batt_idle_mode (pbim) #
# Several devices can draw power directly from the external power supply when charging is paused.
# Test yours with "acc -t --".
# This setting dictates whether charging switches that support such feature should take precedence.

# force_charging_status_full_at_100 (fs) #
# Some Pixel devices were found to never report "full" status after the battery capacity reaches 100%.
# This setting forces Android to behave as intended.
# For Pixel devices, the status code of "full" is 5 (fs=5).
# The status code is found through trial and error, with the commands "dumpsys battery", "dumpsys battery set status #" and "dumpsys battery reset".

# run_cmd_on_pause (rcp)
# Run commands* after pausing charging.
# * Usually a script ("sh some_file" or ". some_file")

# dyn_power_saving (dps) #
# This is the maximum number of seconds accd will dynamically sleep for (while unplugged) to save resources.

#/DC#
```


---
## USAGE


As the default configuration (above) suggests, ACC is designed to run out of the box, with little to no customization/intervention.

Especial cases (e.g., troublesome Pixel devices) require some light tweaking (e.g., capacitySync=true).

The only commands you actually have to remember are `acc` and `acc --help` (or -h).
The first is a wizard you'll either love or hate. The latter is self-explanatory.

If you feel uncomfortable with the command line, skip this section and use the [ACC app](https://github.com/MatteCarra/AccA/releases/) to manage ACC.

Alternatively, you can use a `text editor` to modify `/data/adb/acc-data/config.txt`. Changes to this file take effect within seconds - and the [daemon](https://en.wikipedia.org/wiki/Daemon_(computing)) doesn't need to restart.
The config file itself has configuration instructions for humans as well.


### Terminal Commands
```
#TC#

Usage

  acc (wizard)
  acc [options] [args]
  acc [pause_capacity] [resume_capacity] (e.g., acc 75 70)
  /sbin/acca [options] [args] (acc optimized for front-ends)

  A custom config path can be specified as first parameter. If the file doesn't exist, the current config is cloned.
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

  -f|--force|--full [capacity]   Charge to a given capacity (default: 100) once and uninterrupted
    e.g.,
      acc -f 95 (charge to 95%)
      acc -f (charge to 100%)

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

  -p|--performance   Monitor accd resources usage (htop)
    e.g., acc -p

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


### Online ACC Install

```
1) Check whether ACC is installed (exit code 0)
which acc > /dev/null

2) Download the installer (https://raw.githubusercontent.com/VR-25/acc/master/install-latest.sh)
- e.g., curl -#LO URL or wget -O install-latest.sh URL

3) Run "sh install-latest.sh" (installation progress is shown)
```

### Offline ACC Install

Refer back to the `BUILDING AND/OR INSTALLING FROM SOURCE` section.


### Officially Supported Front-ends

- ACC App, a.k.a., AccA (installDir=/data/data/mattecarra.accapp/files/acc/)


### Exit Codes

0. True or success
1. False or general failure
2. [Contextual] incorrect command usage or external power supply not detected
3. Missing busybox binary
4. Not running as root
5. Update available
6. No update available
7. Daemon couldn't disable charging
8. [Contextual] Daemon already running (--daemon start) or not running (--daemon stop)
9. [Contextual] Current/Voltage unit could not be determined

Logs are exported automatically (`--log --export`) on exit codes `1`, `2` and `7`.



---
## TROUBLESHOOTING


### `acc -t --` Reports Total Failure

Refer back to `DEFAULT CONFIGURATION (switch_delay)`.


### Battery Capacity (% Level) is Misreported

The "smart" battery must be calibrated. Refer to the `FAQ` section below for details.

If we're talking about a Pixel device, the issue is bigger than that. Refer back to `DEFAULT CONFIG (capacity_offset and capacity_sync)`


### Bootloop, ACC Not Found

ACC disables itself after a bootloop event.
Refer to `Diagnostics/Logs` below for details.


### Charging Switch

By default, ACC uses whatever [charging switch](https://github.com/VR-25/acc/blob/master/acc/charging-switches.txt) works.

If `prioritizeBattIdleMode` is set to `true`, charging switches that support _battery idle mode_ (check the `FAQ` below) take precedence - allowing the device to draw power directly from the external power supply when charging is paused.

However, things don't always go well.

- Some switches are unreliable under certain conditions (e.g., screen off).

- Others hold a [wakelock](https://duckduckgo.com/?q=wakelock) - causing faster battery drain.
Refer back to `DEFAULT CONFIG (wake_unlock)`.

- High CPU load and inability to re-enable charging may also be experienced.

- In the worst case scenario, the battery status is reported as discharging, while it's actually charging.

In such situations, you have to find and enforce a switch that works as expected. Here's how to do it:

1. Run `acc -test --` (or acc -t --) to see which switches work.
2. Run `acc --set charging_switch` (or acc -s s) to enforce a working switch.
3. Test the reliability of the set switch. If it doesn't work properly, try another one.
4. If everything fails, test again, but with a higher `switch_delay` (refer back to `DEFAULT CONFIG`).

ACC daemon applies dedicated settings for specific devices (e.g., MTK, Asus, 1+7pro) to prevent charging switch issues.
These settings are in `acc/oem-custom.sh`.

Note: switches that fail to disable charging are automatically blacklisted.


### Custom Max Charging Voltage And Current Limits

Unfortunately, not all kernels support these features.
While custom current is supported by most (at least to some degree), voltage tweaking support is _exceptionally_ rare.

That said, the existence of potential voltage/current control file doesn't necessarily mean these are writable* or the features are supported.

\* Root is not enough. Kernel level permissions forbid write access to certain interfaces.


### Diagnostics/Logs

Volatile logs are in `/sbin/.acc/`.
Persistent logs are found at `/data/adb/acc-data/logs/`.

`/data/adb/acc-data/logs/.bootlooped` is created automatically after a bootloop event - and it prevents acc initialization.

`acc -le` exports all acc logs, plus Magisk's and extras to `/data/media/0/acc-$device_name.tar.gz`. Automatic exporting happens under certain conditions.
Refer back to `NOTES/TIPS FOR FRONT-END DEVELOPERS > Exit Codes`.


### Restore Default Config

`acc --set --reset` (or `acc -s r`) or `rm /data/adb/acc-data/config.txt`


### Slow Charging

At least one of the following may be the cause:

- Charging current and/or voltage limits
- Cooldown cycle
- Weak adapter and/or power cord

Refer back to `DEFAULT CONFIG` for details.



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
- Simplified Chinese (zh-rCN) by GitHub.com/zjns: partial


Translation Notes

1. Start with copies of [acc/strings.sh](https://github.com/VR-25/acc/blob/master/acc/strings.sh) and [README.md](https://github.com/VR-25/acc/blob/master/README.md).

2. Modify the header of strings.sh to reflect the translation (e.g., # Español (es)).

3. Anyone is free and encouraged to open translation [pull requests](https://duckduckgo.com/?q=pull+request).
Alternatively, a compressed archive of translated `strings.sh` and `README.md` files can be sent to the developer via Telegram (links below).

4. Use `acc -s l` (--set --lang) wizard to switch languages.



---
## TIPS


### Generic

Limit charging current to 500 milliamps: `acc -s c 500`
(`acc -s c -` restores default)

Force fast charge: `appy_on_boot=/sys/kernel/fast_charge/force_fast_charge::1::0 usb/boost_current::1::0 charger/boost_current::1::0`

Use voltage control file as charging switch file (beta, battery idle mode support): `chaging_switch=FILE DEFAULT_VOLTAGE LOW_VOLTAGE` (e.g., `chaging_switch=battery/voltage_max 4380000 3500000`)


### Google Pixel Devices

Force fast wireless charging with third party wireless chargers that are supposed to charge the battery faster: `apply_on_plug=wireless/voltage_max:9000000`.



---
## FREQUENTLY ASKED QUESTIONS (FAQ)


> How do I report issues?

Open issues on GitHub or contact the developer on Facebook, Telegram (preferred) or XDA (links below).
Always provide as much information as possible - and attach `/sdcard/acc-logs-*tar.gz`.
The archive is generated automatically under certain conditions.
If the file doesn't exist, run `acc -le` (to generate it) _right after_ the problem occurs.


> Why won't you support my device? I've been waiting for ages!

Firstly, never lose hope!
Secondly, several systems don't have intuitive charging control files; I have to dig deeper - and oftentimes, improvise; this takes extra time and effort.
Lastly, some systems don't support custom charging control at all;  in such cases, you have to keep trying different kernels and uploading the respective power supply logs.
Refer back to `POWER SUPPLY LOGS (HELP NEEDED)`.


> Why, when and how should I calibrate the battery?

Refer to https://batteryuniversity.com/index.php/learn/article/battery_calibration


> What if even after calibrating the battery, ACC and Android battery level reports still differ?

It's a software (Android/kernel) issue. Use the `capacity_offset` or `capacity_sync` features.



---
## LINKS

- [ACC app](https://github.com/MatteCarra/AccA/releases/)
- [Battery University](http://batteryuniversity.com/learn/article/how_to_prolong_lithium_based_batteries/)
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
