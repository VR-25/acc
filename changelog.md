**v2022.7.29-dev (202207290)**
* f93098e --test shall skip missing ctrl files
* 04bf46f Fix ctrl file write function
* 3b96bae Rewrite ctrl file write logic
* b7583e5 Fix & optimize capacity_sync
* d55cd89 Optimize --force
* 142d160 Miscellaneous fixes
* f740feb Fix --parse issues
* 171ec2f Use 3600mV to stop charging with voltage regulators, and don't mask status as "Idle"
* 294297c Print "Hang on..." to make "Terminated" messages less obscure
* a035559 Update documentation
* d08ad09 Update default config layout and comments
* 622dd59 [Wizard] change "exit" option from "g" to "z"
* a8378b0 Additional charging switches
* 7d5f899 Add adb push helper
* 1228f3d Undo "disable mi_thermald"
* 54a8f53 Misc charging control fixes
* bcfc477 Fix "acc -t file"
* d2711ef Fix battery info issues
* d601bce Current and voltage control fixes
* 18485bf Fix AccSettings
* 6cf01cd Fix & optimize cooldown

**v2022.7.19-dev (202207190)**
* Bump version
* 423fadb Misc charging control fixes and optimizations
* d74a647 Systemlessly disable mi_thermald
* deb4736 Add support for cooldown_charge=0 (to be used with cooldown_current)
* 6286223 Update documentation
* ded8b86 Rewrite script scheduler
* 950709b Update BATT_HEATH calculator
* e778686 Goodbye loopCmd (replaced by one-line scripts)
* e5110f4 Improve force_off

**v2022.7.10-dev (202207100)**
* 4240644 Add voltage support to -e and -d options
* 5a63ada Fix offMid
* fee795b Each ctrl file gets written to 2x
* 6c6badb Optimize force_off
* 4a26458 Bump charging status check timeout

**v2022.7.4-dev (202207040)**
* 24dcfd7 Update translation info
* 3b882c1 Merge pull request #156 from Babilinx/dev (French translations)
* d0b8b42 Merge pull request #160 from cutiness/dev (Turkish translations)
* 744911d Report status "Idle" as "Not charging" to "fix" AccA
* 36266da Update readme
* 873128e Implement current limiting hack (temp_level)
* 3a72767 Optimize charging control loop
* bc46b40 Optimize forceOff
* 8bada33 Half batt status poll rate
* 426e749 Check config (reset if broken/missing) before loading it
* 50e19b6 Disable seqDrop timeout
* f270ad7 Update config reference
* 21f68d1 Implement forceOff: for keeping stubborn switches off
* e2edbf7 Add new wireless charging switch
* 45cd831 Make less invasive ctrl file permission changes
* fb5cc27 Make each ctrl file read-only after writing to it
* 9f4a5c5 Improve "unplugged" detection
* 19fb9e0 Rename BATT_HEALTH -> HEALTH
* eb0014e Fix: chargingSwitch[@], parameter not set

**v2022.6.28-dev (202206280)**
* 18c08c4 Improve emulated idle mode feedback (info)
* 84b82de Fix typos
* e9188ae Auto-set discharge_polarity
* 8eba418 Fix acc-p.txt generation
* fda19e8 Improve battery status detection

**v2022.6.25-dev (202206250)**
* 6e3ad43 Optimize memory usage
* de4150c (origin/dev, origin/HEAD) Rewrite discharge polarity handling logic
* 348e707 Miscellaneous optimizations
* cf2de3b Remember auto-detected discharge polarity until accd is reinitialized
* 660132b Fix language selector
* 7a38b5e Prevent unwanted switch blacklisting
* ec3b204 Remove re-plug notice
* ad922cd Fix: daemon stop timeout not honored
* cf368d3 Exclude additional misleading uevent information
* 942c251 Show battery health % and power supply info (if interfaces are available)
* e8171ba Determine discharge polarity only when the battery is actually discharging
* a725111 Re-enable daemon stop timeout (10 seconds)
* 3a9aeaa Add Zelle donation info
* b768746 Fix switch filter
* bf13dfa Add new charging switches
* 92687bb Fix: misleading "Idle" status
* d2db8e3 acc -p: filter out additional files
* 863e5b1 Fix --parse (acc -p) crash
* 1db225b Fix voltage based idle mode inconsistencies
* 88855fd Disable verbose for -l|--log
* 61961b2 Fix typo

**v2022.6.21-dev (202206210)**
* 8fc9e92 Update strings
* 5b791e6 Add re-plug notice
* 6884e69 If flip=on, wait for charging to resume
* d22ac4b Update discharge_polarity description
* 637ca4a Fix read_status()
* f8a04d9 Fix AccA idle mode support detection
* 624487c Assume battery is "Discharging" if charging status is unknown/weird
* 20e20c9 Fix: charging can't be enabled, if it was disabled above pause_capacity

**v2022.6.19-dev (202206190)**
* b1b02c3 Battery status workaround enhancements
* 3c988ff Lower ctrl file write frequency and time
* fcc0e1e Update README & translations
* 07b620b Add offMid toggle

**v2022.6.12-dev (202206120)**
- 9110ed8 Always check uevent batt status before comparing current
- 5746f7e Fix acc -f
- 1076997 Fix "charging keeps stopping at min < capacity < max"
- 06fff97 Add Turkish tranlations (Türkçe (tr)) by github.com/cutiness
- e429770 Enhance current unit and polarity detection
- ddc8c50 Accelerate accd stop
- 8df12eb Export log archive to /sdcard/Download/
- 9c4cce3 Include acc-t_output-${device}.log in log archive
- 1579304 Save acc -t output to /sdcard/Download/acc-t_output-${device}.log
- a0846f9 Blacklist /sys/class/qcom-battery/vbus_disable 0 1
- 12ceb6a --parse: exclude all known switches
- fc1e98b Fix typo

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
