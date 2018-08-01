# Magic Charging Switch (mcs)
## (c) 2017-2018, VR25 @ xda-developers
### License: GPL v3+



#### DISCLAIMER

- This software is provided as is, in the hope that it will be useful, but without any warranty. Always read the reference prior to installing/updating. While no cats have been harmed, I assume no responsibility under anything that might go wrong due to the use/misuse of it.
- A copy of the GNU General Public License, version 3 or newer ships with every build. Please, read it prior to using, modifying and/or sharing any part of this work.
- To prevent fraud, DO NOT mirror any link associated with this project.



#### DESCRIPTION

- Advanced battery charging controller for automatically pausing/resuming charging at set time intervals and/or % levels to extend battery lifespan.
- Battery stats are reset on pause (doesn't work on all devices).



#### PRE-REQUISITES

- Magisk
- Kernel with advanced charging control support
- Terminal emulator app for settings custom values (optional)



#### SETUP STEPS

1. Install from Magisk Manager or TWRP.
2. Connect charger.
3. Reboot.
4. Use terminal to change settings (optional)



#### TEMINAL USAGE

mcs [-b] [-h] [-i] [-r] [-v] [debug] [-k %LEVEL] [%PAUSE %RESUME] [%PAUSE] [-m/t %PAUSE %RESUME] [-s start/stop] [-d/e %/TIMEOUT] [-x /path/to/switch onValue offValue]

-b --> reset battery stats on demand (does not work on all devices)

-i --> display power info

-r --> reset settings

-s --> pause/resume, start/stop daemon

-v --> toggle extensive (loops) verbose

-x --> pick a charging switch from the database

debug --> gather debugging data & save it to $logsDir/mcs_debug_log-\$device-\$csVER-\$DATE.txt

-k %LEVEL --> keep/maintain battery power at a constant %LEVEL (pauses mcs daemon)

[no args] --> run with default/previous settings

-h/--help/help --> help

%PAUSE %RESUME --> pause charging at %PAUSE value (default 90); resume if battery drops below %RESUME (default 80). This is the INITIAL SETUP COMMAND. If auto-run is OFF, the command works as is; else, new settings are saved and automatically picked up by mcs daemon.

-m/-t %PAUSE %RESUME --> generate automation config (-m for MacroDroid; -t for Tasker -- pick one)

-d/e [%/TIMEOUT (optional)] --> disable/enable charging on demand (pauses mcs daemon)

-x /path/to/switch onValue offValue -- > manually set a charging switch; if values match one of the following groups, as is or in reverse order -- you don't have to specify them: 1/0, enable/disable, enabled/disabled, true/false, on/off, 100/3, Charging/Discharging


Usage Examples/Tips

"mcs 90" --> pause charging at 90%; resume when battery level is less or equal to 80% (default).

"mcs 80 20" --> pause charging at 80%; resume when battery level is less or equal to 20%.

"mcs -d" --> disable charging.

"mcs -d" --> enable charging. 

"mcs -d 30m" --> keep charging disabled for 30 minutes.

"mcs -e 1h" --> keep charging enabled for 1 hour. 

"mcs -e 80%" --> Charge until battery level equals 80%.

"mcs -d 40%" --> Charge until battery level equals 40%.

"mcs -e 120 && mcs -d 30m && mcs -e 1h" --> charge for 120 seconds, pause for 30 minutes, then charge again for 1h.

"mcs -e 30m && mcs -d 30m && mcs -e 90%" --> charge for 30 minutes, pause for 30 minutes, then charge again, but this time until battery level is greater or equal to 90%.

"mcs -e 50% && mcs -d 5h && mcs -e 80% && mcs -d 30m && mcs -e 90%" --> charge until 50%, pause for 5 hours, charge until 80%, pause for 30 minutes, charge until 90%.

Ideally, you want your battery level between 40-60% - best, 20-80% - average, 10-90% - fair.

For best convenience, stick with mcs 90 80; mcs 80 70 for a perfect balance between convenience & battery wear. If you want the longest battery lifespan, use mcs 42 41 or mcs -k 42 (best for prolonged usage -- i.e., navigation).



#### DEBUGGING

- logsDir=/data/media/mcs/logs
- If charging control is inconsistent or doesn't work with the current control file, run `mcs -x` to pick a different one from the database.



#### ONLINE INFO/SUPPORT

- [Battery University](http://batteryuniversity.com/learn/article/how_to_prolong_lithium_based_batteries)
- [Git Repository](https://github.com/Magisk-Modules-Repo/Magic-Charging-Switch)
- [XDA Thread](https://forum.xda-developers.com/apps/magisk/module-magic-charging-switch-cs-v2017-9-t3668427)



#### RECENT CHANGES


**2018.8.1 (201808010)**
- General optimizations
- Improved debug()
- Striped down (removed unnecessary code & files)
- Updated documentation


**2018.7.29 (201807290)**
- Auto-detect whether mcs should go to bin or xbin dir to avoid bootloops
- Fixed automation config generator
- New and simplified installer
- New debugging engine
- Top to bottom optimizations
- Updated documentation

*Release Note*
- Current settings will be reverted to defaults.


**2018.7.24 (201807240)**
- Enhanced debugging function.
- Fixed "automation config still calling `cs` instead of `mcs`."
- Fixed modPath detection & bad PATH variable issues (Magisk V16.6).
- Updated charging switches database (more devices supported)
- Reliability improvements
- Updated documentation
