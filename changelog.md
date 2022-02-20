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

**v2022.2.3 (202202030)**
- Additional charging switches;
- Auto detect and blacklist unwritable charging control files and those that trigger unexpected reboots;
- Blacklisted troublesome charging switches;
- Fixed bg-dexopt-job wrapper causing long accd stop delay;
- Fixed typos in README.md;
- Fixed voltage "millivolts --exit" error;
- Improved charging status logic;
- Magisk updateJson support;
- Misc fixes & optimizations;
- Moved changelog from README.md to changelog.md;
- Removed README.html;
- Support for a new charging switch format: `ctrl_file1 <on_value|file> <off_value|file> ctrl_file2 <on_value|file> <off_value|file> ...`, `file` is where to get the on/off value from, e.g., `battery/charge_control_limit 0 battery/charge_control_limit_max`;
- Updated unexpected reboot troubleshooting guide.

**v2022.1.8 (202201080)**
- `acc -p` finds even more potential switches;
- Enhanced charging status detection;
- General fixes & optimizations;
- Improved idle mode support;
- New charging switches;
- Optimize system performance and battery utilization, by forcing `bg-dexopt-job` on daemon [re]start, if charging;
- Support for Qualcomm SnapDragon 8 Gen 1 devices, Nokia 2.2 and more;
- Updated documentation.
