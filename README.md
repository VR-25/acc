# Magic Charging Switch (cs)
# VR25 @ XDA Developers


**Description**
- Automagically stops charging at a given % level to extend battery lifespan.


**Disclaimer**
- Don't quote me on the above. Do your own research on lithium-ion batteries! This module tweaks low level Android settings -- I shall not be held responsible for any nuclear disaster potentially triggered by the use/misuse of it.


**Usage**
- cs % --> Stop charging at given % (i.e., 80).
- cs -a --> Run "cs" & "cs -c" afterwards.
- cs -c --> Clear battery stats.
- cs -d --> Disable charging mechanism.
- cs -e --> Enable charging mechanism.
- cs -i --> Show battery info.
- cs --help --> Self explanatory
- just "cs" --> Stop charging at last given %.


**Tips**

"cs 80 30" updates charging info every 30 seconds & switches charging off at 80% battery level. You can also use minutes or hours instead of seconds (#m or #h). If "UpdateFreq" value is not specified, then the default (60 seconds) is used.

"-d" & "-e" options can also take a "timeout" argument to automatically enable & disable charging, respectively (i.e., "cs -d 30m" --> keep charging disabled for 30 minutes, "cs -e 1h" --> charge for 1 hour).

"cs -a" runs "cs" with your last settings (% & UpdateFreq), then executes "cs -c" to clear battery stats.

"cs -c 80" switches off charging at 80% & clears battery stats afterwards.

"cs -c 80 2m" updates charging info every 2 minutes, switches off charging at 80% & clears battery stats afterwards.

"cs -e 1h && cs -c" charge for 1 hour, then clear battery stats.

"cs -e 120 && cs -d 30m && cs -e 1h" charge for 120 seconds, then stop for 30 minutes, then charge again for 1h.

"cs -e 30m && cs -d 30m && cs 90" charge for 30 minutes, then stop for 30 minutes, then charge again, but this time until battery level is greater or equal to 90%.


**Online Support**
- [XDA Thread](https://forum.xda-developers.com/apps/magisk/module-magic-charging-switch-cs-v2017-9-t3668427)
- [GitHub Repo](https://github.com/VR-25/Magic-Charging-Switch)