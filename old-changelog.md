**v2020.4.8-beta (202004080)**
- acc -t: fixed "charging-switches: no such file" error
- accd: fixed crash on plug/unplug that affected some users
- Current control optimizations
- Enhanced battery calibration helper (acc -C)
- More intuitive versioning scheme
- Stricter config integrity checks (auto-reset broken config)

**2020.4.4-dev (202004040)**
- acc -(e|d): do not do unnecessary work
- acc -f: fixed capacity limit bypass
- acc -F: general fixes and optimizations
- accs: acc foreground service, works exactly as accd, but remains attached to the terminal
- "acc -t --" is now "acc -t"
- ACC/service trigger vibrations on certain events (charging enabled/disabled, errors, auto-shutdown warnings and acc -C 100% reached); vibration patterns are customizable
- Auto-reset broken/invalid config
- Enhanced acc -C compatibility
- Fixed busybox setup issues on devices not rooted with Magisk
- Misc fixes
- Major optimizations
- Updated documentation

**2020.3.30-r1-dev (202003301)**
- Misc fixes
- Preserve as many config parameters as possible across (up|down)grades

**2020.3.30-dev (202003300)**
- `-C|--calibrate`: charge until battery_status == "Full"
- `acc -i`: fixed current_now conversion (Redmi 6 Pro and other msm8953 based devices)
- `acc -u, install-online.sh`: optional -k|--insecure flag
- accd manages capacity_sync loop_delay_charging, loop_delay_discharging and switch_delay parameters dynamically
- Charging switch tests take  significantly longer (switch_delay=18); this leads to more consistent results
- Enable Android battery saver on capacity <= shutdown_capacity + 5
- Enriched help text (acc -h|--help)
- Major optimizations
- More modular design
- Portability enhancements
- Vibrate 3 times when an error occurs
- Vibrate 5 times on capacity <= shutdown_capacity + 5, and again on each subsequent capacity drop
- Vibrate 5 times when `acc --calibrate` reaches 100%
- Updated documentation

**2020.3.14-dev (202003140)**
- `acc -s v`: fixed "voltage unit not shown"
- `cooldownCurrent=(file raw_current charge_seconds pause_seconds)`, cooldown_current (ccr): dedicated and independent cooldown settings for quick charging
- General optimizations
- Updated documentation

**2020.3.11-dev (202003110)**
- Fixed capacity_sync issues

**2020.3.10-dev (202003100)**
- ACC Wizard: auto-restart after upgrade
- Installer optimizations
- Universal zip flasher: default_PWD = /storage/emulated/0/Download/, support for filenames containing spaces, more intuitive

**2020.3.9-dev (202003090)**
- Block "ghost charging on steroids" (Xiaomi Redmi 3 - ido)
- General optimizations
- Workaround for "Magisk forgetting service.sh" issue

**2020.3.5-dev (202003050)**
- Added Galaxy S7 current control files
- General optimizations
- Milliamps current control support
- Wizard (`acc`) option `c` (check for update) is fully interactive (won't download updates without confirmation)

**2020.3.4-r1-dev (202003041)**
- /sbin/acca optimizations
- `acc` (wizard): every option is mapped to a single ASCII character (letter or number); pressing [enter] is no longer required for confirming most operations
- Default editor: nano/vim/vi
- Fixed oem-custom "mismatched /" error
- Fixed zip flasher
- Use `less` instead of `vim/vi` to open files in read-only mode (e.g., *.log, *.md)
- Updated help text

**2020.3.4-dev (202003040)**
- Hotfix: get_prop() in oem-custom.sh

**2020.3.3-dev (202003030)**
- `/sbin/acca`: fixed file path issues; ~90%+ faster than version 2020.2.29-r1-dev
- `acc -i`: fixed current/voltage conversion and power calculation issues
- `acc -i`: output current in Amps
- Include kernel details in power supply logs
- Major optimizations
- MediaTek specific fixes

**2020.2.29-r1-dev (202002291)**
- Fixed typos and reset_batt_stats_on_unplug

**2020.2.29-dev (202002290)**
- `/sbin/acca`: acc executable for front-ends (more efficient than /sbin/acc)
- `acc -F|--flash`: added support for batch zip flashing, custom path in interactive mode, and more
- `acc -w#|--watch#`: monitor battery uevent (# == update time in secs, can be zero or decimal, default 3)
- General optimizations
- Ghost charging issue management is fully automatic
- Initial work on cooldown cycle redesign (coolDownCapacity=(capacity charge/pause), coolDownCurrent=(current charge/pause), coolDownTemp=(temp charge/pause))
- Translation strings for `acc --upgrade`
- Updated help text (`acc --help`)
- Updated `README.md > NOTES/TIPS FOR FRONT-END DEVELOPERS`

**2020.2.28-dev (202002280)**
- acc -i: fixes for MTK and HTC One M9, print battery power in/out (Watts)
- Autodetect and block ghost charging (refer to "README.md > DEFAULT CONFIGURATION > ghost_charging" for details)
- Fixed config reset issues
- General optimizations

**2020.2.26-dev (202002260)**
- acc -i: htc_himauhl, read VOLTAGE_NOW from bms/uevent
- acc -i: print current_now, temp and voltage_now over MediaTek's odd property names
- Fixed `acc -d`
- General optimizations
- ghost_charging toggle (refer to "README.md > DEFAULT CONFIGURATION > ghost_charging" for details)
- Updated busybox configuration, documentation and framework-detais.txt

**2020.2.25-dev (202002250)**
- Added alternate `curl` setup instructions to README.md
- Default switch_delay: 3.5 seconds
- Fixed typos
- General optimizations
- Updated module framework

**2020.2.24-dev (202002240)**
- Enhanced general wizard ("acc" command)
- Stripped untranslated strings
- Updated zip flasher and module framework

**2020.2.23-r1-dev (202002231)**
- acc -F: call pick_zip() when there's no arg
- Fixed typos

**2020.2.23-dev (202002230)**
- Updated strings

**2020.2.22-r1-dev (202002221)**
- acc -D: show accd version and PID as well
- acc -F: optimizations
- acc -s s: fixed "print_known_cs: not found"
- acc -v: new output format - `version (version_code)`

**2020.2.22-dev (202002220)**
- Ability to set/nullify multiple properties with a single command (e.g., `acc -s prop1=value "prop2=value1 value2 ..." prop3=`)
- `acc --uninstall` (-U) and the flashable uninstaller remove AccA as well
- Better localization support
- capacity_sync and cooldown cycle improvements
- Changes made by `apply_on_boot()` and `apply_on_plug()` are reverted automatically when appropriate
- config.txt contains a comprehensive help text as well
- Dedicated current control conmands
- Custom configuration for specific devices (`acc/oem-custom.sh`)
- Enhanced commmand list and examples (`acc -h`)
- Extended device support (ASUS, MediaTek, Pixel 4/XL, Razer, 1+7 and more)
- General wizard (`acc` command)
- Greater charging control flexibility
- More modular design
- New config format and more flexible APIs
- Optimized busybox setup
- Prevent power events from waking the screen during the cooldown cycle
- `runCmdOnPause`
- Self-disable after a bootloop event
- Symlink `installDir` to `/data/adb/acc` and `/data/adb/modules/acc`
- The help text (acc -h), documentation (acc -r), logs (acc -l) and config (acc -c) open in vim/vi by default (scrollable)
- Universal zip flasher (`acc -F "zip_file"`)
- Updated documentation and framework
> Notes: incompatible with AccA versions lower than 1.0.21; config will be reset

**2019.10.13-r2-dev (201910132)**
- `forceStatusAt100`: ensure the battery service is ready before freezing/unfreezing the charging status

**2019.10.13-r1-dev (201910131)**
- `acc --upgrade`: use `curl` over `wget`
