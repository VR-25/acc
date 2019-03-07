# # Advanced Charging Controller (acc)
## Copyright (C) 2017-2019, VR25 @ xda-developers
### License: GPL V3+
#### README.md



---
#### DISCLAIMER

This software is provided as is, in the hope that it will be useful, but without any warranty.
Always read/reread this reference prior to installing/upgrading.
While no cats have been harmed, I assume no responsibility under anything which might go wrong due to the use/misuse of it.

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

By default, battery stats are automatically reset once battery capacity reaches `maxCapacity%`.
Users can choose whether battery stats are also reset every time the charger is unplugged (`resetUnplugged=true/false`).

Depending on device's capabilities, charging can be controlled based on temperature conditions, battery capacity, time, voltage, current and/or more variables.
Limiting the charging voltage (i.e., to no more than 4199 millivolts) is the best thing to do for a long lasting battery service life.
There are two options for that (`onBoot` settings and `acc -v`).
Unfortunately, not all devices/kernels support custom charging voltage.
Nevertheless, acc can still keep battery voltage within less stressful thresholds -- and it does that by default.
Keep reading.

Charging is paused when battery temperature >= `maxTemp °C` or capacity >= `maxCapacity%`.
`maxTemp °C` includes a cooling timeout in seconds (default: 90).
Charging is also paused periodically to reduce voltage and temperature induced stress.
This kicks in at `coolDownCapacity%` (default: 60%) or `coolDownTemp` (default: 40°C).
Each of these can be disabled individually.

To prevent deep battery discharges and eventual cell damage, system is automatically and cleanly shutdown if battery is not charging and its capacity <= `shutdownCapacity%`.

Changes to config take effect within `loopDelay` seconds. No reboot is necessary.

If config.txt is missing, it is automatically recreated with default settings.
However if it is deliberately removed while acc daemon is running, accd crashes.

Daemon state is managed with `acc -D|--daemon <start/stop/restart>`.
accd can as well be started/restarted by simply running `accd`. It can also be stopped through the removal of the PID file `/dev/acc/pid`.
That file  contains the daemon's Process ID.

Logs are stored at `/data/media/0/acc/logs/` and `/dev/acc/` (volatile verbose).
`acc-power_supply-$deviceName.log` contains power supply information.
That's were one would look for a charging control files when the device is not supported by acc.
The other log files (`acc-daemon-$deviceName.log*`) contain runtime diagnostic information used for debugging general/advanced issues.



---
#### INCLUDED SOFTWARE

Daily Job Scheduler (djs) - run `djs` or refer to its README.md to learn how to schedule commands, profiles, and even entire scripts.



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

-f|--force|--full <capacity>   Charge to a given capacity (fallback: 100) once and uninterrupted

-i|--info   Show power supply info
  i.e., acc --info

-l|--log <editor [opts]>   Open <acc-daemon-deviceName.log> w/ <editor [opts]> (default: vim|vi)
  e.g., acc -l grep ': ' (show errors only), acc -l cat >/sdcard/acc.log (yes, this also works)

-L   Monitor log

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

-s|--set <s:|switch:>   List available charging switches

-s|--set <s-|switch->   Unset charging switch

-t|--test   Test currently set charging ctrl file
  Return codes: 0 (works), 1 (does not work) or 2 (battery must be charging)

-t|--test <file onValue offValue>   Test custom charging ctrl file
  Return codes: 0 (works), 1 (does not work) or 2 (battery must be charging)

-v|--voltage <millivolts|file:millivolts>   Set charging voltage (3920-4199mV)
  e.g., acc -v 3920, acc -v /sys/class/power_supply/battery/voltage_max:4050

-v|--voltage   Restore default voltage

-v|--voltage :   List available charging voltage control files

-v|--voltage -   Show current voltage

-v|--voltage :millivolts   Evaluate and set charging voltage control files

-x|--xtrace <other option(s)>   Run under set -x (debugging)

Tips

  Commands can be chained for extended functionality.
    e.g., acc -e 30m && acc -d 6h && acc -e 85 && accd (recharge for 30 minutes, halt charging for 6 hours, recharge to 85% capacity and restart daemon)

  Pause and resume capacities can also be set with acc <pause%> <resume%>.
    e.g., acc 85 80

  Run "djs" to learn how to schedule commands, profiles, and even entire scripts.`



---
#### DEFAULT CONFIG

`capacity=5,60,70-80 # <shutdown,coolDown,resume-pause> -- ideally, <resume> shouldn't be more than 10 units below <pause>. To disable <shutdown>, and <coolDown>, set these to 0 and 101, respectively (e.g., capacity=0,101,70-80). Note that the latter doesn't disable the cooling feature entirely, since it works not only based on battery capacity, but temperature as well.

coolDown=50/10 # Charge/pause ratio (in seconds) -- reduces battery temperature and voltage induced stress by periodically pausing charging. This can be disabled with a null value or a preceding hashtag. If charging is too slow, turn this off or change the charge/pause ratio. Disabling this nullifies <coolDown capacity> and <lower temperature> values -- leaving only a temperature limit with a cooling timeout.

temp=400-450_90 # <coolDown-pauseCharging_wait> -- <wait> is interpreted in seconds and it allows battery temperature to drop below <pauseCharging>. By default, temperature values are interpreted in <degrees Celsius times 10>. To disable temperature control entirely, set absurdly high temperature values (e.g., temp=900-950_90).

verbose=false # Alpha and Beta versions will generate verbose whether or not this is enabled.

resetUnplugged=false # Reset battery stats every time charger is unplugged, as opposed to only when max battery capacity is reached.

loopDelay=10 # Time interval between loops, in seconds -- do not change this unless you know exactly what you're doing!

maxLogSize=5 # Log size limit in Megabytes -- when exceeded, $log becomes $log.old. This prevents storage space hijacking.

switch= # Custom charging switch parameters (<path> <onValue> <offValue>), e.g., switch=/sys/class/power_supply/battery/charging_enabled 1 0, pro tip: <./> can be used in place of </sys/class/power_supply/> (e.g., switch=./battery/charging_enabled 1 0).

onBoot= # These settings are applied on boot. e.g., ./usb/device/razer_charge_limit_enable:1 ./usb/device/razer_charge_limit_max:80 ./usb/device/razer_charge_limit_dropdown:70 /sys/kernel/fast_charge/force_fast_charge:1

onBootExit=false # Exit after applying "onBoot" settings from above. Enabling this is particularly useful if voltage_max or similar is being set -- since keeping accd running in such cases is usually redundant.

onPlugged= # These settings are applied every time an external power supply is connected. e.g., ./wireless/voltage_max:9000000 ./usb/current_max:2000000

cVolt=./?attery/voltage_max:4199 # Used by <acc -v millivolts> command for setting charging voltage. This is automatically applied on boot. <acc -v file:millivolts> overrides the value set here -- e.g., "acc -v ./main/voltage_max:4050". For convenience and safety, voltage unit is always millivolt (mV). Only the first four digits of the original value are modified. The accepted voltage range is 3920-4199mV. "acc -v" restores the default value and "acc -v -" shows the current voltage. "acc -v :" lists available charging voltage control files files. "acc -v :millivolts" is for evaluating charging voltage control files.

selfUpgrade=true # Automatically check for a new release, download and install it - minutes after daemon is started/restarted. This has virtually no impact on mobile data. It runs only once per boot session. Update zips weigh just a few kilobytes.

rebootOnPause= # After set seconds (disabled if null).

vNow= # Pause charging for _seconds when charging voltage (voltage_now) >= mV_ (e.g., 4150_15). This is an alternative to charging voltage control. However, in order to actually benefit from it, the charging current must be low (e.g., 500-1000mA). You can use onPlugged=./usb/current_max:500000 or similar configuration, or a low current power supply to achieve that. The higher the current, the less effective this is. That is because battery voltage raises quicker with higher charging current.`



---
#### PRE-REQUISITES

- Mandatory
-- Any root solution, preferably Magisk 17.0+

- Optional
-- App to run (as root) `accd` or `/system/etc/acc/autorun.sh` or `acc -D start` on boot, if system doesn't support Magisk nor init.d
-- Basic terminal usage knowledge
-- Know how to use `Daily Job Scheduler (djs)` - run `djs` or refer to its README.md for details.
-- Terminal emulator (e.g., Termux) running as root (su)

Note: if you're not comfortable with the command line, use ACC app (linked below) by @MatteCarra to configure/manage acc.



---
#### SETUP STEPS


- Install
1. Install from Magisk Manager or custom recovery.
2. Reboot
3. [Optional] customize /data/media/0/acc/config.txt either with acc commands or a text editor.

- Upgrade
1. Install from Magisk Manager or custom recovery. Note that by default, acc upgrades itself ~10 minutes after accd is started/restarted. Update zips weigh just a few kilobytes.
2. Reboot

- Uninstall
1. Use Magisk Manager or other utility.
2. Reboot


- Notes on legacy (/system install)
If the ROM supports addon.d, acc persists across ROM updates. Flashing the same acc version again uninstalls it.



---
#### TROUBLESHOOTING

- Charging switch
By default, acc cycles through available charging control files until it finds one that works. However, things don't always go well.
Certain switches may be unreliable under certain conditions.
Others may hold a wakelock - causing faster battery drain - while in plugged in, not charging state.
Run `acc -s s` to enforce a particular switch. It's best trying the first one last.
Test default switches with `acc -t`.
Evaluate custom switches with `-t|--test <file onValue offValue>`.

- Charging voltage limit
Unfortunately, not all devices/kernels support custom charging voltage.
Since I don't own every device under the sun, I cannot tell whether yours does.
Use `acc -v :millivolts` (e.g., acc -v :4050) for evaluating charging voltage control files.

- [Important info](https://bit.ly/2TRqRz0)

- Restore default settings
`acc -s r`

- Slow charging
- Disable coolDown (`acc -s coolDown`) or play around with its charge/pause ratio.



---
#### LINKS

- [ACC App](https://github.com/MatteCarra/AccA/)
- [Battery University](http://batteryuniversity.com/learn/article/how_to_prolong_lithium_based_batteries/)
- [Daily Job Scheduler](https://github.com/Magisk-Modules-Repo/djs/)
- [Donate](https://paypal.me/vr25xda)
- [Facebook page](https://facebook.com/VR25-at-xda-developers-258150974794782/)
- [Git repository](https://github.com/Magisk-Modules-Repo/acc/)
- [Telegram channel](https://t.me/vr25_xda/)
- [Telegram group](https://t.me/acc_magisk/)
- [Telegram profile](https://t.me/vr25xda/)
- [XDA thread](https://forum.xda-developers.com/apps/magisk/module-magic-charging-switch-cs-v2017-9-t3668427/)



---
#### LATEST CHANGES

**2019.3.7 (201903070)**
- `acc --log` commands determine the target log file based on verbose state.
- Enhanced self-upgrade.
- Fixed instalation error faced by some users.
- Generate `/dev/acc/installed` after successful install/upgrade.
- Include version code in log files.
- New (experimental) charging switches (in `switches.txt`)
- Reduced installer verbose.
- `resetUnplugged` doesn't apply within `coolDown` loop.
- Updated documentation (mainly the troubleshooting section).
- Updated installation instructions in `install.sh` (for app developers).
- Use regular `reboot` commands instead of the unreliable `am bla bla` for system reboot and power off.
- `vNow=mV_pauseSeconds` - monitor `voltage_now` as part of `coolDown` (experimental, default: null (off)).

**2019.3.3-r1 (201903031)**
- `acc -f|--force|--full <capacity>`: charge to a given capacity (fallback: 100) once and uninterrupted.
- `acc -s s` has an "auto" option (unsets switch).
- `acc -v $@` commands accept and output voltage values in millivolts only. Outputs include the unit (e.g., 4050mV).
- `acc -v file:millivolts` saves settings to config if <file> works.
- Additional devices support
- Custom charging voltage limit is automatically set on boot (without `onBoot=file:voltage`).
- Daemon exit text
- General fixes and optimizations
- Faster power supply log generator - users no longer have  wait for it.
- `rebootOnPause= # After set seconds (disabled if null).`
- The output of `acc -v :` is cleaner.
- Updated documentation and debugging tools

**2019.2.27 (201902270)**
- Advanced and assisted charging voltage control. Refer to README.md or `acc --help` for details.
- Automatically unset nonworking charging switch (fallback to cycling through all).
- Daily Job Scheduler (djs) -- run `djs` or refer to its README.md to learn how to schedule commands, profiles, and even entire scripts. That's a standalone Magisk module.
- Enhanced debugging tools (e.g., `acc -x|--xtrace <other option(s)>`)
- Flexible framework and easy installer for app developers
- Log monitoring (`acc -L`)
- Major fixes and optimizations
- On demand charging control files tester
- Reset config with `acc -s r`.
- Self-upgrade (enabled by default, virtually no impact on mobile data - acc zips weigh just a few kilobytes)
- Updated documentation -- added troubleshooting section and more.
- Updated links and default config.
- When persistent verbose is off, volatile verbose is generated (`/dev/acc/acc-daemon-*.log`).
- Workaround for Magisk service.sh bug (script not executed)
