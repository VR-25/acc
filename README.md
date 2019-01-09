# Advanced Charging Controller (acc)
## Copyright (C) 2017-2019, VR25 @ xda-developers
### License: GPL V3+
#### README.md



---
#### DISCLAIMER

This software is provided as is, in the hope that it will be useful, but without any warranty. Always read/reread this reference prior to installing/upgrading. While no cats have been harmed, I assume no responsibility under anything which might go wrong due to the use/misuse of it.

A copy of the GNU General Public License, version 3 or newer ships with every build. Please, study it prior to using, modifying and/or sharing any part of this work.

To prevent fraud, DO NOT mirror any link associated with this project; DO NOT share ready-to-flash-builds (zips) on-line!



---
#### WARNING

acc manipulates Android's low level (kernel) parameters which control the charging circuitry.
While nothing went wrong with my devices so far, I assume no responsibility under anything which might break due to the use/misuse of this software.
By choosing to use/misuse acc, you agree to proceed at your own risk!



---
#### DESCRIPTION

This is primarily intended for extending battery service life. On the flip side, the name says it all.

By default, battery stats are automatically reset once battery capacity reaches `maxCapacity%`. Users can choose whether battery stats are also reset every time the charger is unplugged (`resetUnplugged=true/false`).

Depending on device's capabilities, charging can be controlled based on temperature conditions, battery capacity, time, voltage, current and/or more variables. Limiting the charging voltage (i.e., to no more than 4.2 Volts) is the best thing to do for a long lasting battery service life. There's an option for that (`onBoot` settings). Unfortunately, not all devices/kernels allow modifying `voltage_max` (even with read-write permissions). Fortunately, for those who are deprived of this ability, acc can keep battery voltage within less stressful thresholds -- and it does that by default. Read on...

Charging is paused when battery temperature >= `maxTemp °C` or capacity >= `maxCapacity%`. `maxTemp °C` includes a cooling timeout in seconds (default: 90). Charging is paused periodically as well to reduce voltage and temperature induced stress. This kicks in at `coolDown capacity` (default: 60) or `lower temperature` (default: 40°C) values. Each of these controls can be disabled individually.

To prevent deep battery discharges and eventual cell damage, system is automatically and cleanly shutdown if battery is not charging and its capacity <= `shutdownCapacity%`.

Changes to config take effect within `loopDelay` seconds). No reboot is necessary.

If config.txt is missing, it is automatically recreated with default settings. However if it is deliberately removed while acc daemon is running, accd crashes.

Daemon state is managed with `acc -D|--daemon <start/stop/restart>`. accd can as well be started/restarted by simply running `accd`. It can also be stopped through the removal of the lock file `/dev/acc/running`. This file  contains the daemon's Process ID (PID).

Logs are stored at `/data/media/0/acc/logs/`. `acc-power_supply-$deviceName.log` contains power supply information. That's were one would look for a charging switch when the device is not supported by acc. The other log files (`acc-daemon-$deviceName.log*`) contain runtime diagnostic information used for debugging general/advanced issues.



---
#### TERMINAL

`Usage: acc <options> <args>

-c|--config <editor [opts]>   Edit config w/ <editor [opts]> (default: vim|vi)
  e.g., acc -c nano -l

-d|--disable <#%, #s, #m or #h (optional)>   Disable charging or disable charging with <condition>
  e.g., acc -d 70% (do not recharge until capacity drops to 70%), acc -d 1h (do not recharge until 1 hour has passed)

-D|--daemon   Show current acc daemon (accd) state
  i.e., acc -D

-D|--daemon <start|stop|restart>   Manage accd state
  e.g., acc -D restart

-e|--enable <#%, #s, #m or #h (optional)>   Enable charging or enable charging with <condition>
  e.g., acc -e 30m (recharge for 30 minutes)

-i|--info   Show power supply info
  i.e., acc --info

-l|--log <editor [opts]>   Open <acc-daemon-deviceName.log> w/ <editor [opts]> (default: vim|vi)
  e.g., acc -l grep ': ' (show errors only), acc -l cat >/sdcard/acc.log (yes, this also works)

-r|--readme   Open <README.md> w/ <editor [opts]> (default: vim|vi)
  i.e., acc -r

 -R|--resetstats   Reset battery stats

-s|--set   Show current config
  i.e., acc --set

-s|--set <var> <value>   Set config parameters
  e.g., acc -s verbose true (enable verbose), acc -s capacity 5,60,80-85 (5: shutdown (default), 60: cool down (default), 80: resume, 85: pause)

-s|--set <resume-stop preset>   Can be 4041|endurance+, 5960|endurance, 7080|default, 8090|lite 9095|travel
  e.g., acc -s endurance+ (a.k.a, "the li-ion sweet spot"; best for GPS navigation and other long operations), acc -s travel (for when you need extra juice), acc -s 7080 (restore default capacity settings (5,60,70-80))

-s|--set <s|switch>   Set a different charging switch from the database
  i.e., acc -s s

Tips

  Pause and resume capacities can also be set with acc <pause%> <resume%>.
    e.g., acc 85 80

  Commands can be chained for extended functionality.
    e.g., acc -e 30m && acc -d 6h && acc -e 85 && accd (recharge for 30 minutes, halt charging for 6 hours, recharge to 85% capacity and restart daemon)`



---
#### DEFAULT CONFIG

`capacity=5,60,70-80 # <shutdown,coolDown,resume-pause> -- ideally, <resume> shouldn't be more than 10 units below <pause>. To disable <shutdown>, and <coolDown>, set these to 0 and 101, respectively (e.g., capacity=0,101,70-80). Note that the latter doesn't disable the cooling feature entirely, since it works not only based on battery capacity, but temperature as well.

coolDown=50/10 # Charge/pause ratio (in seconds) -- reduces battery temperature and voltage induced stress by periodically pausing charging. This can be disabled with a null value or a preceding hashtag. If charging is too slow, turn this off or change the charge/pause ratio. Disabling this nullifies <coolDown capacity> and <lower temperature> values -- leaving only a temperature limit with a cooling timeout.

temp=400-450_90 # <coolDown-pauseCharging_wait> -- <wait> is interpreted in seconds and it allows battery temperature to drop below <pauseCharging>. By default, temperature values are interpreted in <degrees Celsius times 10>. To disable temperature control entirely, set absurdly high values (e.g., temp=900-950_90).

verbose=false # Alpha and Beta versions will generate verbose whether or not this is enabled.

resetUnplugged=false # Reset battery stats every time charger is unplugged, as opposed to only when max battery capacity is reached.

loopDelay=10 # Time interval between loops, in seconds -- do not change this unless you know exactly what you're doing!

maxLogSize=10 # Log size limit in Megabytes -- when exceeded, $log becomes $log.old. This prevents storage space hijacking.

#switch= # Custom charging switch parameters (<path> <onValue> <offValue>), e.g., switch=/sys/class/power_supply/battery/charging_enabled 1 0, pro tip: <./> can be used in place of </sys/class/power_supply/> (e.g., switch=./battery/charging_enabled 1 0).

#onBoot=./usb/device/razer_charge_limit_enable:1 ./usb/device/razer_charge_limit_max:80 ./usb/device/razer_charge_limit_dropdown:70 # These settings are applied on boot.

onBootExit=false # Exit after applying "onBoot" settings from above. Enabling this is particularly useful if voltage_max or similar is being set -- since keeping accd running in such cases is pointless.

#onPlugged=./wireless/current_max:2000000 ./usb/current_max:2000000 # These settings are applied every time an external power supply is connected.`



---
#### PRE-REQUISITES

- Any root solution, preferably Magisk 17.0+
- App to run (as root) `accd` or `/system/etc/acc/autorun.sh` or `acc -D start` on boot, if system doesn't support Magisk nor init.d
- Basic terminal usage knowledge
- Terminal Emulator (i.e., Termux)



---
#### SETUP STEPS

First time
1. Install from Magisk Manager or custom recovery.
2. Reboot
3. Customize /data/media/0/acc/config.txt (optional).

Upgrade
1. Install from Magisk Manager or custom recovery.
2. Reboot

After ROM updates
- If the ROM supports `addon.d` feature, skip this. Else, follow the upgrade steps above.

Uninstall
1. Magisk: use Magisk Manager or other tool; legacy: flashing the same version again removes all traces of acc from /system.
2. Reboot



---
#### LINKS

- [Battery University](http://batteryuniversity.com/learn/article/how_to_prolong_lithium_based_batteries/)
- [Facebook page](https://facebook.com/VR25-at-xda-developers-258150974794782/)
- [Git repository](https://github.com/Magisk-Modules-Repo/acc/)
- [Telegram channel](https://t.me/vr25_xda/)
- [Telegram profile](https://t.me/vr25xda/)
- [XDA thread](https://forum.xda-developers.com/apps/magisk/module-magic-charging-switch-cs-v2017-9-t3668427/)



---
#### LATEST CHANGES

**2019.1.9 (201901090)**
- Additional devices support
- Enhanced power supply logger. Owners of still unsupported devices, upload the newly generated acc-power_supply-$deviceName.log file.
- Cycle through all supported charging switches (new algorithm). Users no longer need to run <acc -s s> if charging control is inconsistent - unless they want to enforce a particular switch or set custom charging switch parameters.
- General fixes & optimizations
- Updated building and debugging tools.
- Updated documentation & default config.

**2018.12.26.1 (201812261)**
- [accd] Fixed "not autostarting if data is encrypted"

**2018.12.26 (201812260)**
- [acc] New option: -R|--resetstats (reset battery stats)
- [Core] New feature: `onPlugged` settings (applied every time an external power supply is connected)
- [General] Fixes & optimizations
- [General] Updated documentation & default config
- [Installer] Enhanced modularization for easier maintenance
