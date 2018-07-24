# Magic Charging Switch (mcs)
## VR25 @ xda-developers



### DISCLAIMER
- This software is provided as is, in the hope that it will be useful, but without any warranty. Always read the reference prior to installing/updating it. While no cats have been harmed in any way, shape or form, I assume no responsibility under anything that might go wrong due to the use/misuse of it.
- A copy of the GNU General Public License, version 3 or newer is included with every version. Please, read it prior to using, modifying and/or sharing any part of this work.
- To avoid fraud, DO NOT mirror any link associated with the project.



### DESCRIPTION
- Automatically pauses/resumes charging at set time intervals and/or % levels to extend battery lifespan.
- Battery stats are reset on pause (doesn't work on all devices).
- Install, connect charger, reboot, configure (or leave defaults: 90 80) and forget.
- If your device is incompatible, you'll find the file /sdcard/cs_debug-$DEVICE-$mcsVER-$DATE.log. Upload it to the official XDA thread (find the link below).



### DEPENDENCIES
- Magisk
- Terminal emulator app (optional)



### USAGE

- Run `su` first, ALWAYS -- or make sure `su -c` goes before `mcs` (i.e., `su -c mcs -e 30m`).

mcs [-b] [-h] [-i] [-r] [-v] [debug] [-k LEVEL] [PAUSE% RESUME%] [PAUSE%] [-m/t PAUSE% RESUME%] [-s --enable/disable] [-d/e %/TIMEOUT] [-x /path/to/switch ON_key OFF_key]

`-b` --> reset battery stats on demand (does not work on all devices)

`-i` --> display battery info

`-r` --> reset settings

`-s` --> pause/resume, --enable/disable service

`-v` --> toggle extensive (loops) verbose

`-x` --> pick a different charging switch from the database

`debug` --> gather debugging data & save it to /sdcard/cs_debug-$DEVICE-$mcsVER-$DATE.log

`-k` LEVEL --> keep/maintain battery power at a constant LEVEL (pauses MCS service)

`[no args]` --> run mcs with default/previous settings

`-h/--help/help` --> usage instructions

`PAUSE% RESUME%` --> pause charging at PAUSE% value (default 90); resume if battery drops below RESUME% (default 80). This is the `initial setup command`. If auto-run is OFF, the command works as is; else, new settings are saved and automatically picked up by MCS service.

`-m/-t PAUSE% RESUME%` --> generate automation config (-m for MacroDroid; -t for Tasker -- pick one)

`-d/e [%/TIMEOUT (optional)]` --> disable/enable charging on demand (pauses MCS service)

`-x` /path/to/switch ON_key OFF_key -- > manually set a charging switch; if keys match one of the following as is or in reverse oder -- you don't have to specify them: 1/0, enable/disable, enabled/disabled, true/false, on/off, 100/3



### USAGE EXAMPLES/TIPS

`mcs 90` --> pause charging at 90%; resume when battery level is less or equal to 80% (default).

`mcs 80 20` --> pause charging at 80%; resume when battery level is less or equal to 20%.

`mcs -d` --> disable charging.

`mcs -e` --> enable charging.

`mcs -d 30m` --> keep charging disabled for 30 minutes

`mcs -e 1h` --> keep charging enabled for 1 hour).

`mcs -e 80%` --> Charge until battery level equals 80%.

`mcs -d 40%` --> Charge until battery level equals 40%.

`mcs -e 120 && mcs -d 30m && mcs -e 1h` --> charge for 120 seconds, pause for 30 minutes, then charge again for 1h.

`mcs -e 30m && mcs -d 30m && mcs -e 90%` --> charge for 30 minutes, pause for 30 minutes, then charge again, but this time until battery level is greater or equal to 90%.

`mcs -e 50% && mcs -d 5h && mcs -e 80% && mcs -d 30m && mcs -e 90%` --> charge until 50%, pause for 5 hours, charge until 80%, pause for 30 minutes, charge until 90%.

Ideally, you want your battery level between 40-60% - best, 20-80% - average, 10-90% - fair.

For best convenience, stick with mcs 90 80; mcs 80 70 for a perfect balance between convenience & battery wear. If you want the longest battery lifespan, use mcs 42 41 or mcs -k 42 (best for prolonged usage -- i.e., navigation).



### DEBUGGING

- If your device is incompatible, mcs auto-generates the file /sdcard/cs_debug-$DEVICE-$mcsVER-$DATE.log.

- Before actions: `touch /data/r` -- force reinstall; `touch /data/.bcs` -- install mcs to bin dir instead of xbin (bootloop workaround, persistent accross updates).

- If charging control is inconsistent, run `mcs -x` to pick a different switch from the database.



### ONLINE INFO/SUPPORT
- [Battery University](http://batteryuniversity.com/learn/article/how_to_prolong_lithium_based_batteries)
- [Git Repository](https://github.com/Magisk-Modules-Repo/Magic-Charging-Switch)
- [XDA Thread](https://forum.xda-developers.com/apps/magisk/module-magic-charging-switch-cs-v2017-9-t3668427)



### RECENT CHANGES

**2018.7.24 (201807240)**
- Enhanced debugging function.
- Fixed "automation config still calling `cs` instead of `mcs`."
- Fixed modPath detection & bad PATH variable issues (Magisk V16.6).
- Updated charging switches database (more devices supported)
- Reliability improvements
- Updated documentation


**2018.3.6 (201803060)**
- Additional devices support
- Major optimizations
- Renamed executable to `mcs` (formerly `cs`)
- Reworked control file testing logic
- Upgraded debugging engine
- Updated documentation

*Release Note*
- Current settings will be reverted to defaults.


**2018.1.27 (201801270)**
- General optimizations
- Minor cosmetic changes
- Stability improvements
- Updated MCS service function

*Release Note*
- Unsupported devices whose owners already provided a debug zip won't be supported anytime soon. Most, if not all of those lack advanced charging control functionality -- custom kernel [or proper hardware] required.
