# Advanced Charging Controller (ACC)



---
## LEGAL

Copyright (c) 2017-2019, VR25 (xda-developers.com)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.



---
## DISCLAIMER

Always read/reread this reference prior to installing/upgrading this software.

While no cats have been harmed, the author assumes no responsibility for anything that might break due to the use/misuse of it.

To prevent fraud, do NOT mirror any link associated with this project; do NOT share builds (zips)! Share official links instead.



---
## WARNING

ACC manipulates Android low level ([kernel](https://duckduckgo.com/?q=kernel+android)) parameters which control the charging circuitry.
The author assumes no responsibility under anything that might break due to the use/misuse of this software.
By choosing to use/misuse ACC, you agree to do so at your own risk!



---
## DESCRIPTION

ACC is primarily intended for [extending battery service life](https://batteryuniversity.com/learn/article/how_to_prolong_lithium_based_batteries). On the flip side, the name says it all.



---
## PREREQUISITES

- Android or Android based OS
- Any root solution (e.g., Magisk)
- Busybox (only if not rooted with Magisk)
- curl (for `acc --upgrade`, your ROM may already have it; if not, there's the Magisk module `curl for Android` by Zackptg5)
- Terminal emulator (e.g., Termux)
- Text editor (optional)



---
## QUICK START GUIDE


1. Unless Magisk is not installed, always install/upgrade from Magisk Manager or dedicated ACC front-end. Apps such as EX Kernel Manager and FK Kernel Manager are also good options.
2. [Optional] run `su -c acc STOP_LEVEL RESUME_LEVEL` (default `80 70`) or use a front-end app to change settings.
3. If you encounter any trouble, scroll down to the `TROUBLESHOOTING`, `TIPS` and `FAQ` sections.


### Notes

- `2` is optional because there are default settings. For details, refer to the `DEFAULT CONFIGURATION` section below.

- Settings can be overwhelming. Start with what you understand and leave everything else default - until you have squeezed enough knowledge from this document.

- Uninstall: depending o the installed variant, you can run `su -c acc --uninstall` or flash `/sdcard/acc-uninstaller.zip` (both are universal), use Magisk Manager (app) or [Magisk Manager for Recovery Mode (utility)](https://github.com/VR-25/mm/), or clear the front-end app data. The flashable uninstaller works everywhere - Magisk Manager, kernel managers, TWRP, etc..



---
## BUILDING AND/OR INSTALLING FROM SOURCE


### Dependencies

- git, wget, or curl
- zip


### Build Tarballs and Flashable Zips

1. Download the source code: `git clone https://github.com/VR-25/acc.git` or `wget  https://github.com/VR-25/acc/archive/$reference.tar.gz -O - | tar -xz` or `curl -L#  https://github.com/VR-25/acc/archive/$reference.tar.gz | tar -xz`
2. `cd acc*`
3. `sh build.sh` (or double-click `build.bat` on Windows 10, if you have Windows subsystem for Linux installed)


#### Notes

- build.sh automatically sets/corrects `id=*` in `*.sh` and `update-binary` files.

- The output files are (in `_builds/acc-$versionCode/`): `acc-$versionCode.zip`, `acc-$versionCode.tar.gz`, and `install-tarball.sh`.

- To update the local repo, run `git pull --force`.


### Install from Local Sources and GitHub

- `sh install-tarball.sh acc` installs the tarball (acc*gz) sitting next to it. The archive must be obtained from GitHub: https://github.com/VR-25/acc/archive/$reference.tar.gz ($reference examples: master, dev, 201908290).

- `sh install-current.sh` installs acc from the script's location.

- `sh install-latest.sh [-c|--changelog] [-f|--force] [-n|--non-interactive] [%install dir%] [reference]` downloads and installs acc from GitHub. e.g., `sh install-latest.sh dev`


#### Notes

- `install-current.sh` and `install-tarball.sh` take an optional parent installation path argument (e.g., sh install-current.sh /data - this will install acc to /data/acc/).

- `install-latest.sh` is a back-end to `acc --upgrade`.

- The order of arguments doesn't matter.

- The default parent installation paths, in order of priority, are: /data/data/mattecarra.accapp/files/, /sbin/.magisk/modules/, /sbin/.core/img/ and /data/adb/.

- No argument/option is mandatory. The exception is `--non-interactive` for front-ends. Additionally, unofficially supported front-ends must specify the parent installation path.

- Recall that unlike the other two installers, `install-latest.sh` requires the installation path to be enclosed in `%` (e.g., sh install-latest.sh %/data% --non-interactive).

- The `--force` option (install-latest.sh) is meant for reinstallation and downgrading.

- `sh install-latest.sh --changelog --non-interactive` prints the version code (integer) and changelog URL (string) when an update is available. In interactive mode, it also asks the user whether they want to download and install the update.

- You may want to take a look at `NOTES/TIPS FOR FRONT-END DEVELOPERS > Exit Codes` below, too.



---
## SETUP


### Any Root Solution

Install/upgrade: unless Magisk is not installed, always install/upgrade from Magisk Manager or dedicated ACC front-end; apps such as EX Kernel Manager and FK Kernel Manager are also good options.

Uninstall: depending o the installed variant, you can run `su -c acc --uninstall` or flash `/sdcard/acc-uninstaller.zip` (both are universal), use Magisk Manager (app) or [Magisk Manager for Recovery Mode (utility)](https://github.com/VR-25/mm/), or clear the front-end app data. The flashable uninstaller works everywhere - Magisk Manager, kernel managers, TWRP, etc..


### Notes

ACC supports live upgrades - meaning, rebooting after installing/upgrading is unnecessary.

The daemon is automatically started right after installation.

For non-Magisk install, [busybox](https://duckduckgo.com/?q=busybox+android) binary is required. Additionally, `$installDir/acc/acc-init.sh` must be executed on `boot_completed` to initialize acc; without this, acc commands won't work.



---
## DEFAULT CONFIGURATION
```
# This is used to determine whether config should be patched. Do NOT modify!
versionCode=XXXXXXXXX

# shutdown,coolDown,resume-pause
capacity=0,60,75-80

# Change this only if your system reports incorrect battery capacity ("acc -i" (BMS) vs "dumpsys battery" (system)). Pixel devices are know for having this issue.
capacityOffset=+0

# This is an alternative to capacityOffset. It tells acc whether the battery capacity reported by Android should be updated every few seconds to reflect the actual value from the battery management system.
capacitySync=false

# <coolDown-pauseCharging_waitSeconds> - <waitSeconds> allow battery temperature to drop below <pauseCharging>. Temperature values are interpreted in Celsius degrees. To disable temperature control entirely, set absurdly high temperature values (e.g., the defaults, as shown below).
temperature=70-80_90

# Charging ON/OFF ratio in seconds (e.g., coolDownRatio=50/10) - reduces battery stress induced by prolonged high temperature and high charging voltage by periodically pausing charging. If charging is too slow, turn this off (null value) or change the ratio. When set to null, <coolDown capacity> and <coolDown temperature> values are nullified.
# Generally, you don't need this if you're limiting the maximum charging voltage.
coolDownRatio=

# Reset battery stats after <pauseCapacity> is reached. If enabled, this may temporarily worsen capacity report discrepancies between Android and the BMS on Pixel devices.
resetBsOnPause=false

# Reset battery stats every time charger is unplugged, as opposed to only when <pauseCapacity> is reached.
resetBsOnUnplug=false

# Seconds (plugged,unplugged) between loop iterations - this is essentially a sensitivity "slider". Do not touch it unless you know exactly what you're doing! For Plugged seconds, a value lower than 5 may cause unexpected behavior (e.g., increased battery drain). A number above 30 may lead to significant delays in charging control; on the other hand, it will dramatically boost acc's energy efficiency.
loopDelay=10,15

# Custom charging switch parameters (<path> <onValue> <offValue>), e.g., chargingSwitch=/sys/class/power_supply/battery/charging_enabled 1 0, pro tip: </sys/class/power_supply/> can be omitted (e.g., chargingSwitch=battery/charging_enabled 1 0).
chargingSwitch=

# Settings to apply on boot - e.g., applyOnBoot=usb/device/razer_charge_limit_enable:1 usb/device/razer_charge_limit_max:80 usb/device/razer_charge_limit_dropdown:70 /sys/kernel/fast_charge/force_fast_charge:1 --exit
# --exit stops accd.
applyOnBoot=

# Settings to apply every time an external power supply is connected - e.g., applyOnPlug=wireless/voltage_max:9000000 usb/current_max:2000000
# Tip: applyOnPlug=wireless/voltage_max:9000000 forces fast wireless charging on Pixel devices.
applyOnPlug=

# Charging voltage limit (file:millivolts, e.g., maxChargingVoltage=?attery/voltage_max:4200)
# Voltage range (millivolts): 3920-4349
maxChargingVoltage=

# Reboot after <pauseCapacity> is reached and <seconds> (e.g., rebootOnPause=60) have passed (disabled if null). If this doesn't make sense to you, you probably don't need it.
rebootOnPause=

# Minimum charging on/off toggling interval (seconds)
chargingOnOffDelay=1

# English (en) and Portuguese (pt) are the main languages supported. Refer to the "## LOCALIZATION" section below for all available languages and translation information. Running "acc-en" instead of "acc" overrides this setting.
language=en

# Wakelocks to unlock after pausing charging (e.g., wakeUnlock=chg_wake_lock qcom_step_chg)
# Use only if you known what you're doing. Blocking certain wakelocks may cause unexpected behavior.
# If this doesn't work, you have to enforce a charging switch that doesn't hold wakelocks. Refer to "## TROUBLESHOOTING" > "### Charging Switch" below for details.
wakeUnlock=

# Prioritize charging switches that support battery idle mode.
prioritizeBattIdleMode=false

# Workaround for end-of-charge issues on Android 10 (e.g., force fully charged status at 100% capacity, value 5 for Pixel devices)
forceStatusAt100=
```


---
## USAGE


ACC is designed to run out of the box, without user intervention. You can simply install it and forget. However, as it's been observed, most people will want to tweak settings - and obviously everyone will want to know whether the thing is actually working.

If you feel uncomfortable with the command line, skip this section and use the [ACC app](https://github.com/MatteCarra/AccA/releases/) to manage ACC.

Alternatively, you can use a `text editor` to modify `/data/adb/acc-data/config.txt`. Changes to this file take effect almost instantly, and without a [daemon](https://en.wikipedia.org/wiki/Daemon_(computing)) restart.


### Terminal Commands
```
acc <-x|--xtrace> <option(s)> <arg(s)>

-c|--config <editor [opts]>   Edit config w/ <editor [opts]> (default: nano|vim|vi)
  e.g.,
    acc -c
    acc -c cat
    acc -c grep temperature
    acc -c sed -n 's/^capacity=//p'

-d|--disable <#%, #s, #m or #h (optional)>   Disable charging (with or without <condition>)
  e.g.,
    acc -d 70% (do not recharge until capacity drops to 70%)
    acc -d 1h (do not recharge until 1 hour has passed)

-D|--daemon   Show current acc daemon (accd) state
  e.g., acc -D (alias: "accd,")

-D|--daemon <start|stop|restart>   Manage accd state
  e.g.,
    acc -D restart
    accd -D stop (alias: "accd.")

-e|--enable <#%, #s, #m or #h (optional)>   Enable charging or enable charging with <condition>
  e.g., acc -e 30m (recharge for 30 minutes)

-f|--force|--full <capacity>   Charge to a given capacity (fallback: 100) once and uninterrupted
  e.g., acc -f 95

-i|--info   Show power supply info
  e.g., acc -i

-I|--lang   Show available, as well as the default and currently set languages
  e.g., acc -I

-l|--log <-a|--acc> <editor [opts]>   Open accd log (default) or acc log (-a) w/ <editor [opts]> (default: nano|vim|vi)
  e.g., acc -l grep ': ' (show explicit errors only)

-l|--log -e|--export   Export all logs to /sdcard/acc-logs-<device>.tar.bz2
  e.g., acc -l -e

-L|--logwatch   Monitor accd log in realtime
  e.g., acc -L

-P|--performance   accd performance monitor (htop)
  e.g., acc -P

-r|--readme   Open <README.md> w/ <editor [opts]> (default: vim|vi)
  e.g., acc -r

-R|--resetbs   Reset battery stats
  e.g., acc -R

-s|--set   Show current config
  e.g., acc -s

-s|--set <r|reset>   Restore default config
  e.g., acc -s r

-s|--set <var> <value>   Set config parameters (alternative: -s|--set <regexp> <value> (interactive))
  e.g.,
    acc -s capacity 5,60,80-85 (5: shutdown, 60: cool down, 80: resume, 85: pause)
    acc -s cool 55/15

-s|--set <resume-stop preset>   Can be 4041|endurance+, 5960|endurance, 7080|default, 8090|lite 9095|travel
  e.g.,
    acc -s endurance+ (a.k.a, "the li-ion sweet spot"; best for GPS navigation and other long operations)
    acc -s travel (for when you need extra juice)
    acc -s 7080 (restore default capacity settings (5,60,70-80))

-s|--set <s|chargingSwitch>   Set a different charging switch from the database
  e.g., acc -s s

-s|--set <s:|chargingSwitch:>   List available charging switches
  e.g., acc -s s:

-s|--set <s-|chargingSwitch->   Unset charging switch
  e.g., acc -s s-

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

-u|--upgrade -c|--changelog] [-f|--force] [-n|--non-interactive] [reference]   Upgrade/downgrade
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
    e.g., acc 45 44 && acc --set applyOnPlug usb/current_max:500000 && sleep $((60*60*7)) && acc 80 70 && acc --set applyOnPlug usb/current_max:2000000
    - "Keep battery capacity at ~45% and limit charging current to 500mA for 7 hours. Restore regular charging settings afterwards."
    - For convenience, this can be written to a file and ran as "sh <file>".
    - If your device supports custom charging voltage, it's better to use it instead: "acc -v 3920 && sleep $((60*60*7)) && acc -v -".

Run acc --readme to see the full documentation.
```


---
## NOTES/TIPS FOR FRONT-END DEVELOPERS


Note: it's best to use `acc-en` over `acc` if your app doesn't rely on exit codes alone. This ensures acc language is always English.

It's best to use full commands over short equivalents - e.g., `acc --set chargingSwitch` instead of `acc -s s`. This makes your code more readable (less cryptic).

Include provided config descriptions for ACC settings in your app(s). Provide additional information (trusted) where appropriate.


### Online ACC Install

```
1) Check whether ACC is installed (exit code 0)
which acc > /dev/null

2) Download the installer (https://raw.githubusercontent.com/VR-25/acc/master/install-latest.sh)
- e.g., curl -#LO URL or wget -O install-latest.sh URL

3) Run "sh install-latest.sh" (installation progress is shown)
```

### Offline ACC Install

Refer to the `BUILDING AND/OR INSTALLING FROM SOURCE` section above.


### Officially Supported Front-ends

- ACC App (installDir=/data/data/mattecarra.accapp/files/acc/)


### Exit Codes

0. True or success
1. False or general failure
2. Incorrect command usage, or battery must be charging (acc --test)
3. Missing busybox binary
4. Not running as root
5. Update available
6. No update available
7. Installation path not found
8. Daemon already running (acc --daemon start) or not running (acc --daemon stop)



---
## TROUBLESHOOTING


### Battery Capacity (% Level) is Misreported

The "smart" battery must be calibrated. Refer to the `FAQ` section below for details.


### Charging Switch

By default, ACC uses whatever [charging switch](https://github.com/VR-25/acc/blob/master/acc/switches.txt) works.

If `prioritizeBattIdleMode` is set to `true`, charging switches that support battery idle mode take precedence - allowing the device to draw power directly from the external power supply when charging is paused.

However, things don't always go well.

- Some switches are unreliable under certain conditions (e.g., screen off).
- Others hold a [wakelock](https://duckduckgo.com/?q=wakelock) - causing faster battery drain.
- High CPU load and inability to re-enable charging may also be experienced.

In such situations, you have to find and enforce a switch that works as expected. Here's how to do it:

1. Run `acc -test --` (or acc -t --) to see which switches work.
2. Run `acc --set chargingSwitch` (or acc -s s) to enforce a working switch.
3. Test the reliability of the set switch. If it doesn't work properly, try another one.


### Charging Voltage And Current Limits

Unfortunately, not all kernels support these features.
Those that do are rare.
Most OEMs don't care about that.

The existence of potential voltage/current control file doesn't necessarily mean these features are supported.


### Restore Default Config

`acc --set reset` (or `acc -s r`)


### Slow Charging

Check whether charging current in being limited by `applyOnPlug` or `applyOnBoot`.

Set `coolDownCapacity` to `101`, nullify coolDownRatio (`acc --set coolDownRatio`), or change its value. By default, `coolDownRatio` is unset/null.


### Diagnostics/Logs

Logs are stored at `/sbin/.acc/`. You can export all to `/sdcard/acc-logs-$device.tar.bz2` with `acc --log --export`.
In addition to acc logs, the archive includes `charging-ctrl-files.txt`, `charging-voltage-ctrl-files.txt`, `config.txt`, `magisk.log`, and everything from `/data/adb/acc-data/logs/`.

Installation and initialization logs are located at `/data/adb/acc-data/logs/`.

The existence of `/dev/acc-modpath-not-found` indicates a fatal ACC initialization error.



---
## POWER SUPPLY LOG


Please upload `/sbin/.acc/acc-power_supply-*.log` to [this dropbox](https://www.dropbox.com/request/WYVDyCc0GkKQ8U5mLNlH/).
This file contains invaluable power supply information, such as battery details and available charging control files.
A public database is being built for mutual benefit.
Your cooperation is greatly appreciated.


Privacy Notes

- When asked for a name, give your `XDA username` or any random name.
- For the email, you can type something like `noway@areyoucrazy.com`.

Example
- Name: `user .`
- Email: `myEmail@isCool.com`


See current submissions [here](https://www.dropbox.com/sh/rolzxvqxtdkfvfa/AABceZM3BBUHUykBqOW-0DYIa?dl=0).



---
## LOCALIZATION

Currently Supported Languages and Translation Statuses
- English (en): complete
- Portuguese, Portugal (pt-PT): partial
- Simplified Chinese (zh-rCN) by zjns @GitHub: mostly complete

Translation Notes
- Translators should start with copies of [acc/strings.sh](https://github.com/VR-25/acc/blob/master/acc/strings.sh) and [README.md](https://github.com/VR-25/acc/blob/master/README.md) - and append the appropriate language code suffix to the base names - e.g., `strings_it`, `README_it`.
- Anyone is free and encouraged to open translation [pull requests](https://duckduckgo.com/?q=pull+request).
- Alternatively, `strings_*.sh` and `README_*.md` files can be sent to the developer.



---
## TIPS


### Generic

Control the max USB input current: `applyOnPlug=usb/current_max:MICRO_AMPS` (e.g., 1000000, that's 1A)

Force fast charge: `applyOnBoot=/sys/kernel/fast_charge/force_fast_charge:1`

Use voltage control file as charging switch file (beta, battery idle mode support): `chagingSwitch=FILE DEFAULT_VOLTAGE STOP_VOLTAGE` (e.g., `chagingSwitch=battery/voltage_max 4380000 3500000`)


### Google Pixel Family

Force fast wireless charging with third party wireless chargers that are supposed to charge the battery faster: `applyOnPlug=wireless/voltage_max:9000000`.

Workaround for end-of-charge issues on Android 10: `forceStatusAt100=5`.


### Razer Phone

Alternate charging control configuration:

`applyOnBoot=razer_charge_limit_enable:1 usb/device/razer_charge_limit_max:80 usb/device/razer_charge_limit_dropdown:70 --exit`


### Samsung

The following files could be used for controlling charging current and voltage (with `applyOnBoot` or `applyOnPlug`):
```
battery/batt_tune_fast_charge_current

battery/batt_tune_input_charge_current

battery/batt_tune_float_voltage
```


---
## FREQUENTLY ASKED QUESTIONS (FAQ)


> How do I report issues?

Open issues on GitHub or contact the developer on Telegram/XDA (linked below). Always provide as much information as possible, and attach `/sdcard/acc-logs-*tar.bz2`. This file is generated automatically. When this doesn't happen, run `acc --log --export` _shortly after_ the problem occurs.


> What's "battery idle" mode?

That's a device's ability to draw power directly from an external power supply when charging is disabled or the battery is pulled out. The Motorola Moto G4 Play and many other smartphones can do that. Run `acc -t --` to test yours.


> What's "cool down" capacity for?

It's meant for reducing stress induced by prolonged high charging voltage (e.g., 4.20 Volts). It's a fair alternative to the charging voltage limit feature.


> Why won't you support my device? I've been waiting for ages!

First, never lose hope! Second, several systems don't have intuitive charging control files; I have to dig deeper and improvise; this takes extra time and effort. Lastly, some systems don't support custom charging control at all;  in such cases, you have to keep trying different kernels and uploading the respective [power supply logs](https://github.com/VR-25/acc#power-supply-log).


> Why, when and how should I calibrate the battery?

Refer to https://batteryuniversity.com/index.php/learn/article/battery_calibration


> How do I get rid of the annoying screen constantly lighting up issue?

This is a device-specific issue. Use the app [SnooZZy Charger](http://snoozy.mudar.ca/) to prevent it.


> What if even after calibrating the battery, ACC and Android battery level reports still differ?

It's a software (Android/kernel) issue. Use the `capacityOffset` feature.



---
## LINKS

- [ACC app](https://github.com/MatteCarra/AccA/releases/)
- [Battery University](http://batteryuniversity.com/learn/article/how_to_prolong_lithium_based_batteries/)
- [Daily Job Scheduler](https://github.com/VR-25/djs/)
- [Donate](https://paypal.me/vr25xda/)
- [Facebook page](https://facebook.com/VR25-at-xda-developers-258150974794782/)
- [Git repository](https://github.com/VR-25/acc/)
- [Telegram channel](https://t.me/vr25_xda/)
- [Telegram group](https://t.me/acc_group/)
- [Telegram profile](https://t.me/vr25xda/)
- [XDA thread](https://forum.xda-developers.com/apps/magisk/module-magic-charging-switch-cs-v2017-9-t3668427/)



---
## LATEST CHANGES

**2019.10.13-r2-dev (201910132)**
- `forceStatusAt100`: ensure the battery service is ready before freezing/unfreezing the charging status

**2019.10.13-r1-dev (201910131)**
- `acc --upgrade`: use `curl` over `wget`

**2019.10.13-dev (201910130)**
- `acc-en` executable for front-ends (to ensure acc language is always English)
- `acc -I|--lang`: Show available, as well as the default and currently set languages
- `acc -P|--performance`: accd performance monitor (htop)
- `acc --upgrade`: always use current `installDir`
- Attribute back-end files ownership to front-end app
- Automatically copy installation log to <front-end app data>/files/logs/
- Back-end can be upgraded from Magisk Manager, EX/FK Kernel Manager, and similar apps (alternative to `acc --upgrade`)
- `bundle.sh` - bundler for front-end app
- Default loopDelay: 10,15 (plugged,unplugged)
- Default resume capacity: 75
- Dynamic power saving and voltage control enhancements
- Enhanced power supply logger (psl.sh)
- Fixed busybox and `loopDelay` handling issues
- Fixed `coolDownRatio` delays
- Flashable uninstaller: `/sdcard/acc-uninstaller.zip`
- `forceStatusAt100=status#`: force android to report a specific battery status (e.g., fully charged, value 5 for Pixel devices) at 100% capacity
- Major optimizations
- Prioritize `nano -l` for text editing
- Renamed `chargingVoltageLimit` variable to `maxChargingVoltage`
- Richer installation and initialization logs (/data/adb/acc-data/logs/)
- Simplified Chinese translation (zh-rCN) by zjns @GitHub
- Updated `build.sh` and documentation
- Updated Telegram group link (`t.me/acc_group/`)
- Use `umask 077` everywhere
- Workaround for front-end autostart blockage (Magisk service.d script)
> Note: this version resets config to default to fix common issues and add new settings.

**2019.7.21-r1 (201907211)**
- `acc -f`: fixed "daemon not restarted" issue
- `acc -x`: fixed "file not found" error
- Enhanced busybox detection and handling
- Fixed `install-latest.sh` inconsistencies
- Fixed voltage limit typo: 3920-4349, 3500-4350
- Start `accd` immediately after installation (no more ~30 seconds delay)

**2019.7.18 (201907180)**
- `acc -d`: use `prioritizeBattIdleMode` variable
- Fixed: `acc -l -a`
- `wakeUnlock` enhancements
- Updated documentation
> Note: this is NOT compatible with AccA 1.0.11-. A new version of the app will be up soon.
