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

- **v2021.12.20 (202112200)**
- [accd, misc-functions]: prevent unwanted crashes related to `eval` and `set -eu`;
- [batt-info]: filter out the unreliable `POWER_SUPPLY_CHARGE_TYPE` property (note: this change makes AccA always display "unknown" charge type);
- [batt-info]: fixed current reading issue;
- [batt-info]: round current and voltage values to two decimal places;
- [ctrl-files]: added `battery/op_disable_charge 0 1` switch;
- [README]: updated troubleshooting section;
- General optimizations.
