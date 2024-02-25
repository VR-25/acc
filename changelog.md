**v2024.2.25-rc (202402250)**

- Ability to specify (regex) thermal management processes to temporarily suspend after disabling charging
- [acc -c d string] Quotes are no longer mandatory
- Fix config parsing issues
- Optimize exec wrappers

- Improve the stability of idleApps

- -c|--config h string   Print config help text associated with "string" (config variable, e.g., acc -c h rt (or resume_temp))
- [acc -f] Don't use scripts from the default config & disengage as soon as the charger is unplugged, regardless of battery level; fix rt issue
- [acc -i] Avoid duplicate lines & redundant information
- [acc -p] Filter more useless sysfs nodes
- Add timestamp to all non-stable flashable zips
- Always replace one-line scripts with the same name (case-insensitive)
- Fix idle detection issues
- Support cooldown_current with temp_level as back-end (e.g., acc -s cdc=60% to limit current by 60%)
- Support curl binary without --dns-server option (for upgrades)
- Support Nexus 10 (manta)

- [acc -p] Add filters
- Also consider pc_port/online for plug state detection
- Fix accd ungraceful stop issue
- Minimize the use of subshells
- Set idleAbovePcap threshold to (pause_capacity + 1)
- Set millivolts idleAbovePcap threshold to (pause_capacity + 50)
- Try honoring allowIdleAbovePcap=false only 2x at most, per accd session

- [acc -p] Filter out more useless stuff
- [acc -t] Add status column hint
- [acc -t] Show currently set charging switche(s)
- [accd] Miscellaneous fixes & optimizations
- [allowIdleAbovePcap=false] Fall back to idle mode as soon as capacity <= pause_capacity
- [Config updater] Remove redundant text
- [Refactor] -b[c] restores previous installation; "c" includes the config
- Fix current and voltage control files parsing logic
- Optimize busybox handling
- Patches for KSU/Apatch, install notes and "no reboot needed" workaround
- Show applied config patches after upgrades (Android notification)
- Simplify rt-mt logic

- Add debug info to acc-t_output-${device}.log
- Check dc/online as well for plug state info
- Fix config printing issues
- Lower switch test timeout
- Optimize --info's output
- Optimize battStatusWorkaround logic
- Optimize mi_thermald dynamic suspend logic
- Reset "auto switch" and move it to the end of the list only if unsolicitedResumes = 3, rather than 1
- Reset switch (in auto-mode) if pbim changes via --set
- Set defaults allow_idle_above_pcap=false & idle_threshold=30
- Set discharge_polarity automatically even while charging
- Support additional busybox paths (including Apatch's)

- Improve charger plug detection

- [push.sh] Support KernelSU
- Fix typos in doc
- Improve charger plug detection
- Recommend trying temp_level if no regular current control file is found
- Suppress missing current control file errors

- Restore scheduler changes from v2023.11.26-dev

- Implement idle_apps
- Improve charger online detection
- Make it possible to post multiple notifications with acc -n
- Optimize current and voltage logic

- Dynamically pause my_thermald to keep it from disabling idle mode
- Fix issue with pc, rc, mt and rt null values
- Fix wizard option 8 (uninstall)
- Forbid mt - rt > 10 (fallback to rt = mt - 1)
- Notifications include time
- Parse current and voltage control files only once per boot session to avoid "false defaults"
- Rewrite scheduling logic
- Use hard instead of soft links for KernelSU/Magisk mount files

- Forbid control files modifications by 3rd-party
- Improve online upgrade, temp_level and schedules logic
- In acc -c a ': sleep profile; at 22:00 "acc -s pc=60 mcc=500; acc -n \"sleep profile\""', the quotes are optional and all ";" can be replaced with ","
- Include dmesg and logcat in log archive
- Support "," in place of "|" for egrep patterns (e.g., acc -i curr,volt; acc -w curr,volt; acc -sp cap,temp)
- Support unquoted notify string (e.g., acc -n switched to sleep profile)
- Suppress "Terminated" messages


**v2023.10.16 (202310160)**
- "edit g" shall work with non-root apps (acc -h g, acc -l g, acc -la g)
- -f supports additional options (e.g., acc -f -sc 500)
- -h|--help [[editor] [editor_opts] | g for GUI] prints the help text, plus the config
- -sd shall not print user scripts
- accd auto-updates mcc and mcv arrays (missing ctrl files or array[1] "-" marker)
- Added dev tag to update checker
- Additional charging switches
- Additional current control files
- allowIdleAbovePcap=true, if set to false, accd will avoid idle mode (if possible) when capacity > pause_capacity
- Auto-move failing switches to the end of the list
- Default acc -w refresh rate set to 1 second
- Default capacity_sync set to false
- Dropped obsolete code & information
- Ensure charging switch is set before a pause condition is hit
- Fixed html hyperlinks and duplicate temp in acc -i (OnePlus 7)
- Implement "rt ct mt" restricted charging hysteresis
- Improved current control files parsing & automatic switch logic
- KaiOS support
- Log export function invokes Android's share dialog
- Optimized loop delays (loopDelay=(3 9): 3 seconds while charging/idle, 9 seconds while discharging)
- prioritizeBattIdleMode=no has the opposite effect (prioritize non-idle mode)
- Refactored battery health calculator and cooldown logic
- resume_temp and cooldown_temp optionally override resume_capacity (if resume_temp has a trailing "r", as in resume_temp=35r)
- Selection lists count from 0 instead of 1
- Show /dev/ prefix tip only if acc is not in $PATH
- Suspend regular daemon functions until discharge_polarity is set, either automatically or manually
- Updated documentation
- Validate current control files only while charging
- Wizard is more user-friendly

**v2023.8.19 (202308190)**
- 1936210 Fix print_quit error
- 28d68bd Fix -f and temp_level
- 08e2c3f Fix --upgrade
- 6f69b45 Add constant_charge_current* control files
- 312a429 Update resume_temp information
- 2744859 Fix module info updater
- 6dac4a7 resume_temp with trailing r always overrides resume_capacity
