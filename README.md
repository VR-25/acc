# Magic Charging Switch (cs)
# VR25 @ XDA Developers


**Description**
- Stop charging at a set % level below 100 to extend battery lifespan. Battery stats are cleared automatically.
- Note: your terminal emulator must be excluded from battery optimization &/or Doze for cs to work properly.

**Disclaimer**
- Don't quote me on the above. Do your own research on lithium-ion batteries! This module tweaks low level Android settings -- I shall not be held responsible for any nuclear disaster potentially triggered by the use/misuse of it.


**Usage**
- cs -i --> show battery info
- cs % % --> pause charging at first %; resume charging if battery drops below second % (optional)
- cs -d [timeout (optional)] --> disable charging
- cs -e [timeout (optional)] --> enable charging
- just "cs" --> run cs with previous settings
- cs --help --> self-explanatory
- cs debug --> gather debugging data & save it to /sdcard (`cs_debug.log & cs_debug.zip`)


**Tips**

"cs 80" --> stop charging at 80%.

"cs 80 20" --> pause charging at 80%; resume if battery drops below 20%.

"-d" & "-e" options can take a "timeout" argument to automatically enable & disable charging, respectively (i.e., "cs -d 30m" --> keep charging disabled for 30 minutes, "cs -e 1h" --> charge for 1 hour).

"cs -e 120 && cs -d 30m && cs -e 1h" --> charge for 120 seconds, pause for 30 minutes, then charge again for 1h.

"cs -e 30m && cs -d 30m && cs 90" --> charge for 30 minutes, pause for 30 minutes, then charge again, but this time until battery level is greater or equal to 90%.


**Online Support**
- [Battery University](http://batteryuniversity.com/learn/article/how_to_prolong_lithium_based_batteries)
- [GitHub Repo](https://github.com/Magisk-Modules-Repo/Magic-Charging-Switch)
- [XDA Thread](https://forum.xda-developers.com/apps/magisk/module-magic-charging-switch-cs-v2017-9-t3668427)
