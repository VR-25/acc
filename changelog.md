**v2023.7.17 (202307170)**
- Do not disengage "charge once to %" until unplugged (requires "plug state" API)
- Fixed capacity_mask miscalculations (@kaljade)
- KernelSu support (#197)
- Support Samsung's battery/siop_level by default
- XDA S-trace's vFloat kernel patch support (voltage control for SDM660 devices)

**v2023.6.26 (202306260)**
* A bunch of new features and bug fixes
* Updated logic
* Full changelog [link](https://github.com/VR-25/acc/compare/v2022.6.4...v2023.6.26)

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
