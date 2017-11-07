# Magic Charging Switch (cs)
# VR25 @ XDA Developers


**Description**
- Automatically pause/resume charging at set % levels to extend battery lifespan.


**Disclaimer**
- Don't quote me on the above. Do your own research on lithium-ion batteries.
- This module changes low level Android settings -- I shall not be held responsible for any cat harm, hair loss and/or nuclear disaster potentially triggered by the use/misuse of it.


**Usage**
- [WIP]`cs -a` --> toggle auto-run (default: ON)[/WIP]
- `cs -i` --> battery info
- `cs debug` --> gather debugging data & save it to /sdcard as cs_debug*
- just `cs` --> run cs with previous settings
- `cs --help` --> module usage info
- `cs PAUSE% RESUME%` --> pause charging at PAUSE% value; resume charging if battery drops below RESUME% (default 10). This is the initial setup command. [WIP]If auto-run is OFF, the command works as is; else, new settings are saved and automatically recognized by cs service.[/WIP]
- -m/-t PAUSE% RESUME% --> generate automation config (-m for MacroDroid; -t for Tasker -- pick one)
- `cs -d [TIMEOUT (optional)]` --> disable charging on demand
- `cs -e [TIMEOUT (optional)]` --> enable charging on demand


**Examples**

"cs 80 20" --> pause charging at 80%; resume if battery level drops below 20%.

"cs -d 30m" --> keep charging disabled for 30 minutes.

"cs -e 1h" --> charge for 1 hour.

"cs -e 120 && cs -d 30m && cs -e 1h" --> charge for 120 seconds, pause for 30 minutes, then charge again for 1h.

"cs -e 30m && cs -d 30m && cs 90" --> charge for 30 minutes, pause for 30 minutes, then charge again, but this time until battery level is greater or equal to 90%.


**Notes**

- If you're not relying on the automation service, then your terminal emulator app must be excluded from battery optimization(s) &/or Doze for cs to work properly. You don't need to keep the screen ON, nor the terminal running in foreground.
- The automation service is paused whenever a cs command is executed on demand. Run `cs -a` to resume it.


**Debugging**

Charging control file and its parameters can be specified in /sdcard/cs_ctrl.txt (you have to create the file). The syntax is `switch "s=/path/to/file" ON OFF` -- where ON OFF may be 1 0, enable disable, enabled disabled, etc. (device-dependent). The battery info file (uevent) is i="$/path/to/file" (mandatory). Example:

- `switch "s=/sys/devices/platform/7000c400.i2c/i2c-1/1-006b/charging_state" enabled disabled`
- `i="/sys/class/power_supply/battery/uevent"`


**Online Support**
- [Battery University](http://batteryuniversity.com/learn/article/how_to_prolong_lithium_based_batteries)
- [GitHub Repo](https://github.com/Magisk-Modules-Repo/Magic-Charging-Switch)
- [XDA Thread](https://forum.xda-developers.com/apps/magisk/module-magic-charging-switch-cs-v2017-9-t3668427)