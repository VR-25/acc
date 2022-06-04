**v2022.6.4 (202206040)**
- `-n|--notif [[string] [user]]`: post Android notification; may not work on all systems;
- `-t|--test [p|parse]`: parse potential charging switches from power supply log (as `acc -p`), test them all, and add the working ones to the list of known switches; implies `-x`;
- `acc -p`: exclude all known switches and additional troublesome ctrl files;
- `acc -s`: Enforce valid pause_capacity and resume_capacity difference;
- `acc -t`: show more useful information; source read-ch-curr-ctrl-files-p2.sh;
- `accd`: if possible, avoid idle mode when capacity > pause_capacity;
- Additional charging switches;
- Blacklisted usb/vbus_disable;
- Fixed `accd /path/to/config --init`;
- Fixed `runCmdOnPause` and `loopCmd` parsing issues;
- Fixed: "after a reboot, accd doesn't control charging, until the keyguard is unlocked";
- General refactor;
- Hard reset wipes config and control file blacklists (`acc -sr a` or acc --set --reset a);
- Improved advanced battery status detection;
- Misc fixes & optimizations;
- New config variables: `batt_status_override=Idle|Discharging|'custom'`, `batt_status_workaround=true`, `reboot_resume=false`, `reset_batt_stats_on_plug=false`, `schedule='HHMM command...'` (refer to the config or readme files for details);
- One-line scripts;
- Parse config `ampFactor` from `batt-interface.sh` as well;
- Post exit code notification if accd stops due to an error;
- Removed obsolete source code files;
- Run dexopt-job only once per boot session (if battery is charging, and system has been up for at least 15 minutes);
- Save acc -t output to /sdcard/Download/acc-t_output.txt;
- Tuning variables for not_charging() timeout (seqCount) and voltage-based idle mode (voltOff);
- Updated documentation;
- Updates can be downloaded with busybox's wget as well (may not work on all systems). Try upgrading with `acc -u`.

**v2022.2.22.1 (202202221)**
- acc -ss and -t show more info/hints;
- Fixed `acc: inaccessible or not found` following acc -t execution;
- Minor additions to readme.

**v2022.2.20 (202202200)**
- [acc -t]: show hints, fixed return code issues (10: no switch or all switches fail, 0: success, 15: idle mode works);
- Additional charging switches;
- Consider STATUS=Discharging, if idle() returns false, current turns negative or drops by 101+ mA -- and its absolute value is less than 750 mA;
- Fixed: capacityMask going over 100%;
- Fixed: custom unit conversion factors not effective for acca -i;
- General optimizations;
- Improved busybox detection;
- Misc changes for front-ends;
- New presets for charging_switch=<mA|mV>;
- Updated links in README.md;
- Updated naming conventions for release files;
- updateJSON API for front-ends (details in the readme);
- Use idleThreshold=95 (mA) for mtk devices and 15 for the rest.
