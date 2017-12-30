# Magic Charging Switch (cs)
# VR25 @ XDA Developers


**Intro**
- Automatically pauses/resumes charging at set time intervals and/or % levels to extend battery lifespan.
- Battery stats are reset on pause (doesn't work on all devices).
- Install, connect charger, reboot, configure (or leave defaults: 90 80) and forget.
- If your device is incompatible, you'll find the file /sdcard/cs_debug-DEVICE.log. Upload it to the official XDA thread (find the link below).


**Disclaimer**
- cs changes low level Android settings -- I shall not be held responsible for any cat harm, hair loss and/or nuclear disaster potentially triggered by the use/misuse of it.


**Usage**

- Run `su` first, ALWAYS -- or make sure `su -c` goes before `cs` (i.e., `su -c cs -e 30m`).

cs [-b] [-c] [-h] [-i] [-r] [-x] [debug] [-k LEVEL] [PAUSE% RESUME%] [PAUSE%] [-m PAUSE% RESUME%] [-s --enable/disable] [-t PAUSE% RESUME%] [-d %/TIMEOUT] [-e %/TIMEOUT]

`-b` --> reset battery stats on demand (does not work on all devices)

`-c` --> manually set charging switch config (/path/to/ctrl/file ON OFF)

`-h` --> cs usage instructions

`-i` --> display battery info

`-r` --> reset cs to its initial state

`-s` --> pause/resume, --enable/disable service

`x` --> toggle store_mode/batt_slate_mode (Samsung); charging_enabled/battery_charging_enabled (generic)

`debug` --> gather debugging data & save it to /sdcard/cs_debug-DEVICE.log

just `cs` --> run CS with default/saved settings

`-k` LEVEL --> keep/maintain battery power at a constant LEVEL (pauses CS service)

`PAUSE% RESUME%` --> pause charging at PAUSE% value (default 90); resume if battery drops below RESUME% (default 80). This is the `initial setup command`. If auto-run is OFF, the command works as is; else, new settings are saved and automatically picked up by CS service.

`-m/-t PAUSE% RESUME%` --> generate automation config (-m for MacroDroid; -t for Tasker -- pick one)

`-d [%/TIMEOUT (optional)]` --> disable charging on demand (pauses CS service)

`-e [%/TIMEOUT (optional)]` --> enable charging on demand (pauses CS service)


**Usage Examples/Tips**

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

For best convenience, stick with cs 90 80; cs 80 70 for a perfect balance between convenience & battery wear. If you want the longest battery lifespan, aim for cs 45 40 (best for prolonged usage -- i.e., navigation).


**Debugging**

- If your device is incompatible, cs auto-generates the file /sdcard/cs_debug-DEVICE.log.

- Before actions: `touch /data/r` -- force reinstall; `touch /data/.xcs` install cs to xbin dir instead of bin (bootloop workaround, only needed once).

- `cs -x` switches between available control files for supported devices. For instance, Samsung devices have `store_mode` & `batt_slate_mode`; stock/near-stock Android smartphones have `charging_enabled` & `battery_charging_enabled`. Use this command only in case of charging control inconsistencies.

- `cs -c` syntax: `cs -c /path/to/ctrl/file ON OFF` -- where ON OFF, depending on the device, can be 1 0, 0 1, enable disable, enabled disabled, etc.. Example: `cs -c /sys/devices/platform/7000c400.i2c/i2c-1/1-006b/charging_state enabled disabled`. The booleans 1/0, on/off, true/false, 100/3, enable/disable and enabled/disabled are automatically assigned -- so you don't need to specify any of them.


**Online Info/Support**
- [Battery University](http://batteryuniversity.com/learn/article/how_to_prolong_lithium_based_batteries)
- [Git Repository](https://github.com/Magisk-Modules-Repo/Magic-Charging-Switch)
- [XDA Thread](https://forum.xda-developers.com/apps/magisk/module-magic-charging-switch-cs-v2017-9-t3668427)



**Changelog**

2017.12.30 (201712300)
- Better compatibility (devices & Magisk)
- `cs -x` is back -- run it once if charging doesn't stop. Refer to the README for details.
- General optimizations
- New and enhanced debugging engine
- Updated charging switches database
- Wait for charger before initial setup instead of just reminding the user to plug it in.

Release Notes
- 3rd call: owners of "still unsupported devices", please upload new debugging data. Reverse engineering this stuff can take a while. The sooner you provide me the data, the closer you'll be to having your devices supported.
- Bootloop? Run `touch /data/.xcs` as root before installing. Unless you clear /data or I change the key, this flag is only needed once.
- Previous settings will be wiped.


2017.12.24 (201712240)
- `cs -s` & `cs -s --enable/disable` -- toggle pause/resume & enable/disable service
- Enhanced device compatibility assessment
- General optimizations
- Minor cosmetic changes
- New charging control algorithm (automatically cycles through available control files to make sure charging is enabled/disabled; `cs -x` is officially dead)

Release Notes
- 2nd call: owners of "still unsupported devices", please upload new debugging data. Reverse engineering this stuff can take a while. The sooner you provide me the data, the closer you'll be to having your devices supported.
- Previous settings will be wiped.


2017.12.22 (201712220)
- Magisk v14.6 support
- Enhanced `cs debug`
- Installer verbose always ON
- Top to bottom optimizations
- Updated control files database

Release notes
- `cs -x` switches between available control files for supported devices. For instance, Samsung devices have `store_mode` & `batt_slate_mode`; stock/near-stock Android smartphones have `charging_enabled` & `battery_charging_enabled`. Use the command only in case of charging control inconsistencies.
- Owners of "still unsupported devices", please install this version and upload a new debug zip/log generated by it.
