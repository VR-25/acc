# Advanced Charging Controller (ACC)



---
## LEGAL

Copyright (C) 2017-2019, VR25 @ xda-developers

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

ACC manipulates Android low level (kernel) parameters which control the charging circuitry.
While nothing went wrong with my devices so far, I assume no responsibility under anything that might break due to the use/misuse of this software.
By choosing to use/misuse ACC, you agree to do so at your own risk!



---
## DESCRIPTION

ACC is primarily intended for extending battery service life. On the flip side, the name says it all.



---
## PREREQUISITES

- Magisk 17-19
- [Optional] terminal emulator (running as root) or text editor.



---
## BUILDING FROM SOURCE


Dependencies

- curl (optional)
- git
- zip


Steps

1. `git clone <repo>`
2. `cd acc`
3. `sh build.sh` (or double-click `build.bat` on Windows, if you have Windows subsystem for Linux installed)


Notes

- The output file is acc/_builds/acc-$versionCode.zip.

- By default, `build.sh` auto-updates the [update-binary](https://raw.githubusercontent.com/topjohnwu/Magisk/master/scripts/module_installer.sh). To skip this, run it as `sh build.sh f`.

- To update the local repo, run `git pull -f <repo>`.



---
## SETUP


Install

- Flash live (e.g., from Magisk Manager) or from custom recovery (e.g., TWRP).

- ACC suports live upgrades. This means you don't need to reboot after installing/upgrading to be able to use it.

- The daemon is stopped before installation and restarted afterwards. It is started automatically even after the first install. Again, rebooting is unnecessary to get things running.


Uninstall

- Use Magisk Manager (app) or Magisk Manager for Recovery Mode (utility).



## DEFAULT CONFIGURATION

```
# This is used to determine whether config should be patched. Do NOT modify!
versionCode=XXXXXXXXX

# shutdown,coolDown,resume-pause
capacity=0,60,70-80

# Change this only if your system reports incorrect battery capacity ("acc -i" (BMS) vs "dumpsys battery" (system)).
capacityOffset=+0

# This is an alternative to capacityOffset. It tells acc whether the battery capacity reported by Android should be updated every few seconds to reflect the actual value from the battery management system.
capacitySync=false

# <coolDown-pauseCharging_waitSeconds> - <waitSeconds> allow battery temperature to drop below <pauseCharging>. Temperature values are interpreted in Celsius degrees. To disable temperature control entirely, set absurdly high temperature values (e.g., temperature=90-95_90).
temperature=40-45_90

# Charge/pause ratio in seconds (e.g., coolDownRatio=50/10) - reduces battery stress induced by prolonged high temperature and high charging voltage by periodically pausing charging. If charging is too slow, turn this off (null value) or change the ratio. When set to null, <coolDown capacity> and <coolDown temperature> values are nullified.
# Generally, you don't need this if you're limiting the maximum charging voltage.
coolDownRatio=

# Reset battery stats after <pauseCapacity> is reached.
resetBsOnPause=true

# Reset battery stats every time charger is unplugged, as opposed to only when <pauseCapacity> is reached.
resetBsOnUnplug=false

# Seconds between loop iterations - this is essentially a sensitivity "slider". Do not touch it unless you know exactly what you're doing!
loopDelay=10

# Custom charging switch parameters (<path> <onValue> <offValue>), e.g., chargingSwitch=/sys/class/power_supply/battery/charging_enabled 1 0, pro tip: </sys/class/power_supply/> can be omitted (e.g., chargingSwitch=battery/charging_enabled 1 0).
chargingSwitch=

# Settings to apply on boot - e.g., applyOnBoot=usb/device/razer_charge_limit_enable:1 usb/device/razer_charge_limit_max:80 usb/device/razer_charge_limit_dropdown:70 /sys/kernel/fast_charge/force_fast_charge:1 --exit
# --exit stops accd.
applyOnBoot=

# Settings applied every time an external power supply is connected - e.g., applyOnPlug=wireless/voltage_max:9000000 usb/current_max:2000000
# Tip: applyOnPlug=wireless/voltage_max:9000000 forces fast wireless charging.
applyOnPlug=

# Charging voltage limit (file:millivolts, e.g., chargingVoltageLimit=?attery/voltage_max:4200)
# Voltage range (millivolts): 3920-4349
chargingVoltageLimit=

# Reboot after <pauseCapacity> is reached and <seconds> (e.g., rebootOnPause=60) have passed (disabled if null). If this doesn't make sense to you, you probably don't need it.
rebootOnPause=
```



---
## USAGE


ACC is designed to run out of the box, without user intervention. You can simply install it and forget. However, as I've been observing, most people will want to tweak settings - and obviously everyone will want to know whether the thing is actually working.

If you're not comfortable with the command line, skip this section and use the `ACC app` (links section) to manage ACC.
Alternatively, you can use a `text editor` to modify `/sdcard/acc/config.txt`. Changes to this file take effect almost instantly, and without a daemon restart.


### Terminal Commands

```
acc <option(s)> <arg(s)>

-c|--config <editor [opts]>   Edit config w/ <editor [opts]> (default: vim|vi)
  e.g., acc -c

-d|--disable <#%, #s, #m or #h (optional)>   Disable charging or disable charging with <condition>
  e.g., acc -d 70% (do not recharge until capacity drops to 70%), acc -d 1h (do not recharge until 1 hour has passed)

-D|--daemon   Show current acc daemon (accd) state
  e.g., acc -D

-D|--daemon <start|stop|restart>   Manage accd state
  e.g., acc -D restart

-e|--enable <#%, #s, #m or #h (optional)>   Enable charging or enable charging with <condition>
  e.g., acc -e 30m (recharge for 30 minutes)

-f|--force|--full <capacity>   Charge to a given capacity (fallback: 100) once and uninterrupted
  e.g., acc -f 95

-i|--info   Show power supply info
  e.g., acc -i

-l|--log -e|--export   Export all logs to /sdcard/acc-logs-<device>.tar.bz2
  e.g., acc -l -e

-l|--log <editor [opts]>   Open <acc-daemon-deviceName.log> w/ <editor [opts]> (default: vim|vi)
  e.g., acc -l grep ': ' (show explicit errors only)

-L|--logwatch   Monitor log
  e.g., acc -L

-r|--readme   Open <README.md> w/ <editor [opts]> (default: vim|vi)
  e.g., acc -r

-R|--resetbs   Reset battery stats
  e.g., acc -R

-s|--set   Show current config
  e.g., acc -s

-s|--set <var> <value>   Set config parameters
  e.g., acc -s capacity 5,60,80-85 (5: shutdown (default), 60: cool down (default), 80: resume, 85: pause)

-s|--set <resume-stop preset>   Can be 4041|endurance+, 5960|endurance, 7080|default, 8090|lite 9095|travel
  e.g., acc -s endurance+ (a.k.a, "the li-ion sweet spot"; best for GPS navigation and other long operations), acc -s travel (for when you need extra juice), acc -s 7080 (restore default capacity settings (5,60,70-80))

-s|--set <s|chargingSwitch>   Set a different charging switch from the database
  e.g., acc -s s

-s|--set <s:|chargingSwitch:>   List available charging switches
  e.g., acc -s s:

-s|--set <s-|chargingSwitch->   Unset charging switch
  e.g., acc -s s-

-t|--test   Test currently set charging ctrl file
  e.g., acc -t
  Return codes: 0 (works), 1 (doesn't work) or 2 (battery must be charging)

-t|--test <file on off>   Test custom charging ctrl file
  e.g., acc -t battery/charging_enabled 1 0
  Return codes: 0 (works), 1 (doesn't work) or 2 (battery must be charging)

-v|--voltage <millivolts|file:millivolts>   Set charging voltage (3920-4349mV)
  e.g., acc -v 3920, acc -v /sys/class/power_supply/battery/voltage_max:4100

-v|--voltage   Show current voltage
  e.g., acc -v

-v|--voltage :   List available charging voltage ctrl files
  e.g., acc -v :

-v|--voltage -   Restore default voltage
  e.g., acc -v -

-v|--voltage :millivolts   Evaluate and set charging voltage ctrl files
  e.g., acc -v :4100

-x|--xtrace <other option(s)>   Run under set -x (debugging)
  acc -x -i

Tips

  Commands can be chained for extended functionality. Note that accd must be stopped first.
    e.g., acc -D stop && acc -e 30m && acc -d 6h && acc -e 85 && accd (recharge for 30 minutes, halt charging for 6 hours, recharge to 85% capacity and restart daemon)

  Pause and resume capacities can also be set with acc <pause%> <resume%>.
    e.g., acc 85 80

  That last command can be used for programming charging before bed. In this case, the daemon must be running.
     e.g., acc 45 44 && acc --set applyOnPlug usb/current_max:500000 && sleep $((60*60*7)) && acc 80 70 && acc --set applyOnPlug usb/current_max:2000000
     - "Keep battery capacity at ~45% and limit charging current to 500mA for 7 hours. Restore regular charging settings afterwards."
    - You can write this to a file and run as "sh <file>".

Run acc --readme to see the full documentation.
```



---
## NOTES/TIPS FOR FRONT-END DEVELOPERS


It's best to use full commands over short equivalents - e.g., `--set chargingSwitch` instead of `-s s`.

Use provided config descriptions for ACC settings in your app(s). Include additional information (trusted) where appropriate.


### Auto-install ACC

```
1) Check whether ACC is installed (exit code 0)
which acc > /dev/null

2) Download the installer (https://raw.githubusercontent.com/VR-25/acc/master/install-latest.sh)
- e.g., curl -#L [URL] > [output file] (progress is shown)

3) Run "sh [installer]" (progress is shown)
```

Notes

- The installer must run as root (obviously).
- Log: /sbin/_acc/install-stderr.log



---
## TROUBLESHOOTING


### Charging Switch

By default, ACC cycles through all available charging control files until it finds one that works.

However, things don't always go well.
Some switches may be unreliable under certain conditions (e.g., screen off).
Others may hold a wakelock - causing faster battery drain - while in plugged in, not charging state.

Run `acc --set chargingSwitch` to enforce a particular switch.

Test default/set switch(es) with `acc --test`.

Evaluate custom switches with `acc --test <file onValue offValue>`.


### Charging Voltage Limit

Unfortunately, not all devices/kernels support custom charging voltage limit.

Since I don't own every device under the sun, I cannot tell whether yours does.

Use `acc --voltage :millivolts` (e.g., acc -v :4050) for evaluating charging voltage control files.


### Restore Default Config

`acc --set reset`


### Slow Charging

Nullify coolDownRatio (`acc --set coolDownRatio`) or change its value. By default, coolDownRatio is null.


### Logs

Logs are stored at `/sbin/_acc/`. You can export all to `/sdcard/acc-logs-$device.tar.bz2` with `acc --log --export`. In addition to acc logs, the archive includes `config.txt` and `magisk.log`.



---
## Power Supply Log


Please upload `/sbin/_acc/acc-power_supply-*.log` to [this dropbox](https://www.dropbox.com/request/WYVDyCc0GkKQ8U5mLNlH/).
This file contains invaluable power supply information, such as battery details and available charging control files.
I'm creating a public database for mutual benefit.
Your cooperation is greatly appreciated.


Privacy Notes

- When asked for a name, give your `XDA username`.
- For the email, you can type something like `noway@areyoucrazy.com`.

Example
- Name: `VR25 .`
- Email: `myemail@iscool.com`


See current submissions [here](https://www.dropbox.com/sh/rolzxvqxtdkfvfa/AABceZM3BBUHUykBqOW-0DYIa?dl=0).



---
## LINKS

- [ACC App](https://github.com/MatteCarra/AccA/)
- [Battery University](http://batteryuniversity.com/learn/article/how_to_prolong_lithium_based_batteries/)
- [Donate](https://paypal.me/vr25xda)
- [Facebook page](https://facebook.com/VR25-at-xda-developers-258150974794782/)
- [Git repository](https://github.com/VR-25/acc/)
- [Telegram channel](https://t.me/vr25_xda/)
- [Telegram group](https://t.me/acc_magisk/)
- [Telegram profile](https://t.me/vr25xda/)
- [XDA thread](https://forum.xda-developers.com/apps/magisk/module-magic-charging-switch-cs-v2017-9-t3668427/)



---
## LATEST CHANGES

**2019.5.14-r1 (201905141)**
- Exported logs archive also includes config.txt and magisk.log
- Fixed typos
- Installer optimizations
> Note: compatible with ACCApp 1.0.6

**2019.5.14 (201905140)**
- Overwrite existing config if its format is newer than current config's
> Note: compatible with ACCApp 1.0.6

**2019.5.13 (201905130)**
- capacitySync disabled by default - some systems don't like the "dumpsys" command
- Fixed installer bugs
