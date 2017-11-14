# Magic Charging Switch (cs)
# VR25 @ XDA Developers


**Description**
- Automatically pause/resume charging at set % levels to extend battery lifespan.
- This is a terminal program.
- Install, reboot, configure and forget -- or simply install, reboot and forget if you're fine with the default settings (more details about that below). 


**Disclaimer**
- Don't quote me on the above. Do your own research on lithium-ion batteries.
- cs changes low level Android settings -- I shall not be held responsible for any cat harm, hair loss and/or nuclear disaster potentially triggered by the use/misuse of it.


**Usage**
- `cs -a` --> toggle auto-run (default: ON); resume cs service.
- `cs -c` --> manually set the control files -- useful when the user knows which those are and doesn't want to wait for the next build to use cs. The config should be pasted directly on terminal.
- `cs -i` --> display battery info.
- `cs debug` --> gather debugging data & save it to /sdcard/cs_debug.zip.
- just `cs` --> run cs with default (90 10) or saved settings.
- `cs --help` --> display cs usage instructions.
- `cs PAUSE% RESUME%` --> pause charging at PAUSE% value; resume charging if battery drops below RESUME% (default 10). This is the initial setup command. If auto-run is OFF, the command works as is; else, new settings are saved and automatically recognized by cs service.
- -m/-t PAUSE% RESUME% --> generate automation config (-m for MacroDroid; -t for Tasker -- pick one).
- `cs -d [TIMEOUT (optional)]` --> disable charging on demand (pauses cs servive).
- `cs -e [TIMEOUT (optional)]` --> enable charging on demand (pauses cs servive).


**Usage Examples**

"cs 85" --> pause charging at 85%; resume if battery level drops below 10% (default).

"cs 80 20" --> pause charging at 80%; resume if battery level drops below 20%.

"cs -d 30m" --> keep charging disabled for 30 minutes.

"cs -e 1h" --> charge for 1 hour.

"cs -e 120 && cs -d 30m && cs -e 1h" --> charge for 120 seconds, pause for 30 minutes, then charge again for 1h.

"cs -e 30m && cs -d 30m && cs 90" --> charge for 30 minutes, pause for 30 minutes, then charge again, but this time until battery level is greater or equal to 90%.


**Notes**

- If you're not relying on the automation service, then your terminal emulator app must be excluded from battery optimization(s) &/or Doze for cs to work properly. You don't need to keep the screen ON, nor the app running in foreground.
- The automation service is paused whenever a on-demand (`cs -e/-d`) command is executed. Run `cs -a` to resume it.


**Debugging**

In case of device incompatibility, cs auto-generates a zip file with debugging data & asks the user to upload it to the official XDA thread.

Control file syntaxes for cs -c: charging switch `switch "s=/path/to/file" ON OFF` -- where ON OFF may be 1 0, enable disable, enabled disabled, etc. (device-dependent). The battery info file (uevent) is i="/path/to/file" (mandatory). Example:

- `switch "s=/sys/devices/platform/7000c400.i2c/i2c-1/1-006b/charging_state" enabled disabled`
- `i="/sys/class/power_supply/battery/uevent"`


**Online Support**
- [Battery University](http://batteryuniversity.com/learn/article/how_to_prolong_lithium_based_batteries)
- [Git Repository](https://github.com/Magisk-Modules-Repo/Magic-Charging-Switch)
- [XDA Thread](https://forum.xda-developers.com/apps/magisk/module-magic-charging-switch-cs-v2017-9-t3668427)