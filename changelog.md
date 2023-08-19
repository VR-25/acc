**v2023.8.19 (202308190)**
- 1936210 Fix print_quit error
- 28d68bd Fix -f and temp_level
- 08e2c3f Fix --upgrade
- 6f69b45 Add constant_charge_current* control files
- 312a429 Update resume_temp information
- 2744859 Fix module info updater
- 6dac4a7 resume_temp with trailing r always overrides resume_capacity

**v2023.8.12 (202308120)**
- -H|--health <mAh>: Print estimated battery health
- -r|--readme now sends intent to open README.html
- Additional charging switches
- Fix set_temp_level()
- Fixed one-line scripts identifier
- Fixed random accd crash
- Implemented resume_temp; deprecated max_temp_pause
- Refactored edit handler; use "g" (instead of "app") for GUI editor
- Set default temp_level to null to accommodate battery/siop_level
- Set list number width to 2 columns

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
