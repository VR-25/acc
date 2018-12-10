# Advanced Charging Controller (acc)
## Copyright (C) 2017-2018, VR25 @ xda-developers
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

This is primarily intended for extending battery lifespan (or service life). On the flip side, it is a general purpose /sys interface manipulation utility (i.e., for setting CPU Governor, scaling frequencies and pretty much anything else). It works with any root solution. Magisk 17.0+ is preferred. Versions below that are not supported.

Battery stats are automatically reset once battery capacity reaches `maxCapacity %`. However, this is not guaranteed to work on all systems.

Charging is controlled based on temperature, capacity, time and other variables.

Charging is paused when battery temperature >= `maxTemp °C` or capacity >= `maxCapacity %`.

To prevent deep battery discharges and eventual cell damage, system is automatically and cleanly shutdown if battery is not charging and its capacity <= `shutdownCapacity %`.

Changes to config take effect within `loopDelay` seconds). No reboot is necessary.

If config.txt is missing, it is automatically recreated with default settings. However if it is deliberately removed while acc daemon is running, accd crashes.

accd state is managed with `acc -D/--daemon <start/stop/restart>`. It can also be stopped through the removal of the lock file `/dev/acc/running`. This file  contains the daemon's PID.

Config instructions are on the config file itself (`/data/media/0/acc/config.txt`).

Config can be edited with `acc -c/--config <editor [opts]>`. If `editor <opts>` is not specified, vim/vi is used. An usage example is `acc -c nano -l`. The terminal utility has additional features and it is self-documented. Run `acc` for details.

Logs are stored at `/data/media/0/acc/logs/`.



---
#### TERMINAL

`Usage: acc <options> <args>

-c/--config <editor [opts]>   Edit config w/ <editor [opts]> (default: vim/vi)

-d/--disable <#%, #s, #m or #h (optional)>   Disable charging or disable charging with <condition>

-D/--daemon <start/stop/restart>   Manage acc daemon (accd) state
            <no args>              Show current accd state

-e/--enable <#%, #s, #m or #h (optional)>   Enable charging or enable charging with <condition>

-i/--info   Show power supply info

-l/--log <editor [opts]>   Open <acc-daemon-deviceName.log> w/ <editor [opts]> (default: vim/vi)

-r/--readme   Open <README.md> w/ <editor [opts]> (default: vim/vi)

-s/--set <var> <value>   Set config parameters

-s/--set <resume-stop preset>   Can be 4041/endurance+, 5960/endurance, 7080/default, 8090/lite 9095/travel
         <s/switch>             Set a different charging switch
         <no args>              Show current config`



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
3. [Optional] configure (/data/media/0/acc/config.txt) -- recall that `acc --config <editor [opts]>` opens config.txt w/ <editor [opts]> (default: vim/vi).


Upgrade
1. Install from Magisk Manager or custom recovery.
2. Reboot

After ROM updates
- Unless `addon.d` feature is supported by the ROM, follow the upgrade steps above.

Uninstall
1. Magisk: use Magisk Manager or other tool; legacy: flashing the same version again removes all traces of acc from /system.
2. Reboot



---
#### SUPPORT

- [Battery University](http://batteryuniversity.com/learn/article/how_to_prolong_lithium_based_batteries/)
- [Facebook page](https://facebook.com/VR25-at-xda-developers-258150974794782/)
- [Git repository](https://github.com/Magisk-Modules-Repo/acc/)
- [Telegram channel](https://t.me/vr25_xda/)
- [Telegram profile](https://t.me/vr25xda/)
- [XDA thread](https://forum.xda-developers.com/apps/magisk/module-magic-charging-switch-cs-v2017-9-t3668427/)



---
#### LATEST CHANGES

**2018.12.10 (201812100)**
- Fixed installation error <MOUNTPATH0 not found> (Magisk 18.0)
- Flash the same version again to disable the module (recovery)
- General cosmetic changes
- General fixes and optimizations
- Improved legacy (/system install) support
- Minimum Magisk version supported is now 17.0
- Module data moved to /data/media/0/acc/ (/sdcard/acc/).
- Option to exit after applying misc settings; enabling this is particularly useful if voltage_max or similar is being set -- since keeping accd running in such cases is pointless
- Option to overwrite switch file regardless of its value; useful when charging control is inconsistent
- Option to reset battery stats automatically every time charger is unplugged, as opposed to only when max battery capacity is reached
- Updated documentation and installer
* Notes: config will be reset and legacy version (mcs) will be automatically removed

**2018.11.24-beta (201811240)**
- Daemon management syntax is now <acc -D/--daemon [start/stop/restart]>.
- Enable/disable charging on demand (<acc -e/--enable>, <acc -d/--disable>) -- time and battery capacity conditions are supported (i.e., <acc -d/--disable 80%>, <acc -e/--enable #s/m/h>). A Chain of commands is also fine (i.e., <acc -e 1h && acc -d 120s && acc -e 3m && acc -e 80%>).
- General fixes & optimizations
- Minor cosmetic changes
- Updated documentation

**2018.11.23-beta (201811230)**
- After starting/restarting daemon from terminal emulator, the app can be closed.
- Clean downgrade support (prevents incompatibility issues)
- Fixed <acc -s s/switch>
- General fixes & optimizations
- Open log (acc -l/--log) and README.md (acc -r/--readme) w/ specified <editor [opts]> (else, with vim/vi).
- Support for system mode (legacy/Magisk-unsupported devices) and Magisk Canary builds. Flashing the same version again uninstalls acc from /system. If your system doesn't support init.d, use an app to run <accd> or <acc -d/--daemon start> on boot. Once accd starts, the app can be closed.

**2018.11.22-beta (201811220)**
- Automatically evaluate available charging switches and pick one for use.
- General optimizations and cosmetic changes
- Introduced misc() -- miscellaneous settings, check config.txt for details.
- The charging switch can be changed at any time with <acc -s/--set s/switch> (select from a list) or <acc -s/--set switch "[path] [onValue] [offValue]"> (custom).
- Updated documentation

**2018.11.15-beta (201811150)**
- Always overwrite charging control files to ensure kernel always notices the changes on time.
- Disabled <coolDownUSB> (dedicated); the current implementation doesn't work for all. For the time being, <coolDown> (regular) will work with USB charging as well.
- Enhanced debugging tools (better logs, more info)

**2018.11.13-beta (201811130)**
- Fixed temperature reading issues (Samsung, Xiaomi, possibly others).
- General optimizations

**2018.11.12-beta (201811120)**
- Added <9095/travel> preset.
- Blacklisted problematic switches.
- General optimizations
- Merged <keys.txt> into <switches.txt> to prevent misleading value readings; more advanced functions to handle that. These changes solve charging control issues on Samsung devices.
- Pause for 1 second after toggling a switch, only if necessary (accuracy and efficiency).

**2018.11.10-beta (201811100)**
- Additional setup info in config.txt
- <coolDown> can be configured for capacity (voltage) only, temperature only or both. There's also <coolDownUSB> now, which is exactly what the name suggests.
- Default maxLogSize set to ~2MB
- General fixes
- Improved daemon manager (acc -d <start/stop/restart>); </dev/acc/running> now contains the daemon's PID (Process ID).
- Pause for 1 second after toggling each switch, for better accuracy and efficiency.
- Updated documentation
* Release notes: I tried disabling charging indicators. It worked. However I immediately realized this is a bad idea. It interferes with charging control. About the broken cooling engine... I've made major changes to that. So far, I had no issues getting it to function. Now It's up in the wild for you guys to test.

**2018.11.9-beta (201811090)**
- Default coolDown (charge/pause ratio) set to 50/10 seconds (can be edited).
- Major changes and new config format -- these simplify setup to a great extent and bring back advanced functionality.
- Removed log size watchdog in favor of a more resource-friendly algorithm. Whenever max capacity is reached, $log is automatically copied to $log.old and zero'd out if its size exceeds $maxLogSize.

**2018.11.8.1-beta (201811081)**
- Fixed flawed cool down loop causing capacity% to exceed maxCapacity%
- Updated support links

**2018.11.8-beta (201811080)**
- Do not suppress enable_charging() and disable_charging() errors.
- General improvements
- Fixed <wrong logic for [re-]enabling charging>
- If battery temperature is greater or equal to <maxTemp>, sleep for 90 seconds after disabling charging. This gives the battery  some time to cool down, while reducing system resources usage.
- More intuitive commands, run <acc> for details.

**2018.11.7-beta (201811070)**
- Automatic battery cool down applies to regular USB charging as well.
- Fixed <customSwitch> issues. Now it can be disabled by commenting out the line.
- New command, <acc -i> - power supply info
- No longer relying on <dumpsys battery> for battery data. This command proved to be unreliable on some devices. A more universal and foolproof method consists on using <cat battery/<property>> with <PWD> set to </sys/class/power_supply/>.
- Only write to control files when necessary.
- Reverted maxTemp value to 450 (45ºC).
- Rewritten ctrl_charging() for the sake of readability and efficiency.
- Save device-specific diagnostic info to </data/media/0/acc/logs/> as opposed to </sdcard/>.
- Start daemon as soon as possible. Do not wait until system has fully booted.

**2018.11.5-beta (201811050)**
- Config can be edited with <acc -c [editor [opts]]>. If <editor [opts]> is not specified, vi/vim is used. An usage example is <acc -c nano -l>. The terminal utility has additional features and it is self-documented. Run <acc> for details.
- Cool down seconds/ratio is managed internally and automatically.
- Custom charging switch parameters can be set in config.txt.
- Major optimizations
- maxTemp set to 500 (50ºC)
- Simplified config
- Stripped down to the bone for speed and efficiency
- Updated building and debugging tools
- Updated documentation, installer and support links
* Release note: from now on, installed builds (beta/stable/both) will be automatically replaced.

**2018.10.12.1-beta (201810121)**
- Fixed <battery cooling mechanism not working>.

**2018.10.12-beta (201810120)**
- Fixed <unreliable plugged/unplugged detection>.
- Read charging status from </sys/class/power_supply/*battery*/status> (path), as opposed to <dumpsys battery> (command, unreliable).

**2018.10.11-beta (201810110)**
- Default <coolDownratio> set to 30/20.
- Updated charging control keys.
- Use alternate charging status detection method to prevent device-specific plugged/unplugged status disparities.

**2018.10.9-beta (201810090)**
- Cool down while charging via USB is optional (off by default -- coolDownUSB=false).
- Default coolDownRatio set to 90/60. I'm trying to find the sweetest spot for a nice balance between charging time and optimal battery temperature/voltage. Expect frequent changes to this default setting! Your battery is happy about that.
- Fixed <auto-shutdown at shutdownCapacity% not working>.
- Fixed <unreliable verbose state detection>.
- Improved overall efficiency
- Use actual capacity value for coolDownCapacity as opposed to a maxCapacity difference (more flexible battery temperature and voltage control). The default value is set to 60.
- Updated documentation
- Verbose is enabled by default on beta builds. This setting is not enforced, though.

**2018.10.7-beta (201810070)**
- Improved diagnostics engine
- Keep an eye on battery capacity while in cool down loop to make sure charging doesn't stop early or a few % over <maxCapacity%>.
- <log=<path>> is now <verbose=true/false>. If enabled, comprehensive diagnostic data is generated. Else, only basic debugging info is logged. The log path is </data/media/0/acc/acc.log*>.
- Renamed config variable <sleep> to <loopDelay> to prevent confusion.
- Use seconds instead of minutes for coolDownRatio.

**2018.10.6-beta (201810060)**
- Always enable charging before daemon stops.
- Auto-recreate <modData/>.
- Auto-restart daemon after errors.
- Added log watchdog to automatically zero-out the log file when its size exceeds <maxLogSizeM>.
- Redirect stdout & stderr to </dev/acc/acc.log> if verbose is disabled.
- Run main() only after system has fully booted.
- Set default coolDownRatio=1/1 to make sure battery charges via USB while device is in use.
- Set default sleep=10 (loop delay)
- Updated documentation
- Zenfone 2/Zoon and more devices supported.

**2018.10.5-beta (201810050)**
- <chmod +w ctrl_file> before echoing value to it.
- Enhanced logic and efficiency.
- Removed PATH modification entry (unnecessary).
- Set PWD to </sys/class/power_supply/>.
- Two charging control mechanisms: <charger ON/OFF switch> (primary) and <current_max control> (secondary, fallback)
- Updated documentation

**2018.10.3-beta (201810030)**
- Bug fixes
- Initial re-work on non-amperage based charging control.

**2018.10.1-beta (201810010)**
- Extended charging current control for general compatibility and wireless charging support.
- Generate debugging info on install/upgrade (/sdcard/$MODID-debug-$(getprop ro.product.device || getprop ro.build.product).log)."

**2018.9.30-beta (201809300)**
- Fixed typos.
- Use non-persistent lock file (/dev/acc/.running).

**2018.9.29-beta (201809290)**
- Auto-shutdown if battery capacity drops to `$shutdownCapacity%`.
- Control charging based on temperature, battery capacity, current (amperage), and more.
- Greater device support (perhaps)
- Halt charging if battery temperature reaches `$maxTemp°C`. Resume slow/fast charging when conditions are appropriate.
- New config format/syntax
- No extra/terminal features (for now)
- Slowdown charging at a set temperature range, and at `$coolDownCapacity%` before battery capacity reaches `$maxCapacity%`.
- Simplified documentation
