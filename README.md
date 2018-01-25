# Magic Charging Switch (cs)
## VR25 @ XDA Developers



### Description
- Automatically pauses/resumes charging at set time intervals and/or % levels to extend battery lifespan.
- Battery stats are reset on pause (doesn't work on all devices).
- Install, connect charger, reboot, configure (or leave defaults: 90 80) and forget.
- If your device is incompatible, you'll find the file /sdcard/cs_debug-DEVICE.log. Upload it to the official XDA thread (find the link below).



### Disclaimer
- cs changes low level Android settings -- I shall not be held responsible for any cat harm, hair loss and/or nuclear disaster potentially triggered by the use/misuse of it.



### Usage

- Run `su` first, ALWAYS -- or make sure `su -c` goes before `cs` (i.e., `su -c cs -e 30m`).

cs [-b] [-h] [-i] [-r] [-v] [debug] [-k LEVEL] [PAUSE% RESUME%] [PAUSE%] [-m PAUSE% RESUME%] [-s --enable/disable] [-t PAUSE% RESUME%] [-d %/TIMEOUT] [-e %/TIMEOUT] [-x /path/to/switch ON_key OFF_key]

`-b` --> reset battery stats on demand (does not work on all devices)

`-h` --> cs usage instructions

`-i` --> display battery info

`-r` --> reset cs to its initial state

`-s` --> pause/resume, --enable/disable service

`-v` --> toggle extensive (loops) verbose

`-x` --> pick a different charging switch from the database

`debug` --> gather debugging data & save it to /sdcard/cs_debug-DEVICE.log

just `cs` --> run CS with default/saved settings

`-k` LEVEL --> keep/maintain battery power at a constant LEVEL (pauses CS service)

`PAUSE% RESUME%` --> pause charging at PAUSE% value (default 90); resume if battery drops below RESUME% (default 80). This is the `initial setup command`. If auto-run is OFF, the command works as is; else, new settings are saved and automatically picked up by CS service.

`-m/-t PAUSE% RESUME%` --> generate automation config (-m for MacroDroid; -t for Tasker -- pick one)

`-d [%/TIMEOUT (optional)]` --> disable charging on demand (pauses CS service)

`-e [%/TIMEOUT (optional)]` --> enable charging on demand (pauses CS service)

`-x` /path/to/switch ON_key OFF_key -- > manually set a charging switch; if keys match one of the following as is or in reverse oder -- you don't have to specify them: 1/0, enable/disable, enabled/disabled, true/false, on/off, 100/3



### Usage Examples/Tips

`cs 85` --> pause charging at 85%; resume when battery level is less or equal to 80% (default).

`cs 80 20` --> pause charging at 80%; resume when battery level is less or equal to 20%.

`cs -d` --> disable charging.

`cs -e` --> enable charging.

`cs -d 30m` --> keep charging disabled for 30 minutes

`cs -e 1h` --> keep charging enabled for 1 hour).

`cs -e 80%` --> Charge until battery level equals 80%.

`cs -d 40%` --> Charge until battery level equals 40%.

`cs -e 120 && cs -d 30m && cs -e 1h` --> charge for 120 seconds, pause for 30 minutes, then charge again for 1h.

`cs -e 30m && cs -d 30m && cs -e 90%` --> charge for 30 minutes, pause for 30 minutes, then charge again, but this time until battery level is greater or equal to 90%.

`cs -e 50% && cs -d 5h && cs -e 80% && cs -d 30m && cs -e 90%` --> charge until 50%, pause for 5 hours, charge until 80%, pause for 30 minutes, charge until 90%.

Ideally, you want your battery level between 40-60% - best, 20-80% - average, 10-90% - fair.

For best convenience, stick with cs 90 80; cs 80 70 for a perfect balance between convenience & battery wear. If you want the longest battery lifespan, use cs 42 41 or cs -k 42 (best for prolonged usage -- i.e., navigation).



### Debugging

- If your device is incompatible, cs auto-generates the file /sdcard/cs_debug-DEVICE.log.

- Before actions: `touch /data/r` -- force reinstall; `touch /data/.xcs` install cs to xbin dir instead of bin (bootloop workaround, only needed once).

- If charging control is inconsistent, run `cs -x` to pick a different switch from the database.



### Online Info/Support
- [Battery University](http://batteryuniversity.com/learn/article/how_to_prolong_lithium_based_batteries)
- [Git Repository](https://github.com/Magisk-Modules-Repo/Magic-Charging-Switch)
- [XDA Thread](https://forum.xda-developers.com/apps/magisk/module-magic-charging-switch-cs-v2017-9-t3668427)



### Recent Changes

**2017.1.25 (201801250)**
- Fixed installation error -- A/B partition devices
- General optimizations
- Updated control files database


**2017.1.13 (201801130)**
- Extended (loops) verbose -- toggle: `cs -v`
- Fixed hang/reboot upon charger connection
- Fixed Nexus 10 compatibility issues
- Major optimizations
- Support for virtually all Magisk versions to date (special downgrading procedures no longer needed)

*Release Note*
- Current settings will be reverted to defaults.


**2017.12.31 (201712310)**
- General optimizations
- `cs -x` -- pick a different charging switch from the database
- `cs -x /path/to/switch` -- manually set the charging switch; refer to the README for additional info
- Updated charging switches database

*Release Note*
- If charging control is inconsistent, run `cs -x` to pick a different switch from the database.
