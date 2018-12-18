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
#### LINKS

- [Battery University](http://batteryuniversity.com/learn/article/how_to_prolong_lithium_based_batteries/)
- [Facebook page](https://facebook.com/VR25-at-xda-developers-258150974794782/)
- [Git repository](https://github.com/Magisk-Modules-Repo/acc/)
- [Telegram channel](https://t.me/vr25_xda/)
- [Telegram profile](https://t.me/vr25xda/)
- [XDA thread](https://forum.xda-developers.com/apps/magisk/module-magic-charging-switch-cs-v2017-9-t3668427/)



---
#### LATEST CHANGES

**2018.12.18 (201812180)**
- [acc] Non-interactive shell support
- [accd] Always overwrite charging switch.
- [accd] Higher coolDown sensitivity
- [accd] Make sure the number of running instances is at most one.
- [accd] More efficient log size watchdog
- [accd] Pause execution until data is decrypted.
- [General] Rearranged charging switches to accommodate newer devices, such as the OnePlus 6/6T. Reports suggest that these don't work correctly with .../battery/charging_enabled.
- [Installer] When updating config.txt, try patching relevant lines only, instead of overwriting the whole file.

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
