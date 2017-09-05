# Magic Charging Switch (cs)
# VR25 @ XDA Developers


**Description**

Automagically stops charging at a given % level to extend battery lifespan.


**Disclaimer**

Don't quote me on the above. Do your own research on lithium-ion batteries! This module tweaks low level Android settings -- I shall not be held responsible for any nuclear disaster potentially triggered by the use/misuse of it.


**Usage**

cs -i --> Show battery info.

cs -d --> Disable charging mechanism.

cs -e --> Enable charging mechanism.

cs % --> Stop charging at given % (i.e., 80).

just "cs" --> Stop charging at last given % (includes last UpdateFreq).

cs --help --> Self explanatory


**Tips**

"cs 80 30" updates charging info every 30 seconds & switches charging OFF at 80% battery level. You can also use minutes or hours instead of seconds (#m or #h). If "UpdateFreq" value is not specified, then the default (60 seconds) is used.

"-d" & "-e" options can also take a "timeout" argument to automatically enable & disable charging, respectively (i.e., "cs -d 30m" --> disables charging for 30 minutes, "cs -e 1h" --> enables charging for 1 hour).


**Online Support**

[XDA Thread](https://forum.xda-developers.com/apps/magisk/module-magic-charging-switch-cs-v2017-9-t3668427)

[GitHub Repo](https://github.com/VR-25/Magic-Charging-Switch)