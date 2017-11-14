# 2017.11.14-1 (201711141)
- Better Pixel/HTC devices support.
- Refined "cs -c" for simplicity & reliability.

# 2017.11.14 (201711140)
- Added option to manually set the control files (from terminal) -- useful when the user knows which those are and doesn't want to wait for the next build to use cs. The config should be pasted directly on terminal.
- Decreased "cs auto" timeout values for better charging control accuracy (cs service).
- Samsung specific changes -- to address charging control inconsistencies.

# 2017.11.13-Beta (201711130)
- Additional devices support
- Automation without apps -- install, configure (cs % %) and forget (please, read/re-read README.md).
- cs default settings -- 90 10
- Fixed "broken pipe" errors.
- Overall optimizations

# 2017.11.7 (201711070)
- Additional devices support
- Fixed "cs debug" errors
- Redesigned "get_batt_level" mechanism ("charging not found" bug is gone)

# 2017.11.6 (201711060)
- Fixed "else unexpected" error.

# 2017.11.5 (201711050)
- Additional devices support
- Control files caching for better performance
- Fixed MacroDroid config
- Massive optimizations
- Updated Tasker config
- Work in progress -- automation without apps (cs service)

# 2017.10.21 (201710210)
- Additional devices support
- Automation configs are now generated manually by running `cs -m/-t PAUSE% RESUME%`. -m is for MacroDroid; -t for Tasker -- pick one.
- Major optimizations
- Updated reference.

# v2017.10.16-4 (201710164)
- Fixed Nexus 4 (mako) battery info not being displayed (wrong uevent path).

# v2017.10.16-3 (201710163)
- More accurate Tasker integration.

# v2017.10.16-2 (201710162)
- Fixed minor Tasker XML generation error (faulty cs second % value).

# v2017.10.16-1 (201710161)
- Additional devices support
- Auto-generate a Tasker project XML file for automation every time a `cs %` or `cs % %` command is executed. Note: The user has to disable "Beginner Mode" in Tasker settings, then import the project "cs_tasker".
- Fixed Nexus 4 (mako) "uevent not found".

# v2017.10.16 (201710160)
- Additional devices support

# v2017.10.15-2 (201710152)
- Additional devices support

# v2017.10.15-1 (201710151)
- Additional devices support
- Fixed cs_ctrl error.

# v2017.10.15 (201710150)
- Additional devices support.
- Built-in zip binary to pack debugging data.
- Users can now specify the charging control file for cs to work with. Check the README for additional info.

# v2017.10.13-3 (201710133)
* Charging control mechanism enhancements for better accuracy:
-- Battery charging info refresh rate increases by ~66.7% if battery level is greater or equal to 75%.
-- Discharging info refresh rate increases by 50% if battery level is less or equal to 25%.

# v2017.10.13-2 (201710132)
- [TEST-FIX] Nexus 5 compatibility

# v2017.10.13-1 (201710131)
- Additional devices support
- General optimizations
- Updated reference & debugging info.

# v2017.10.13 (201710130)
- Additional devices support

# v2017.10.11 (201710110)
- Additional devices support
- Added Magisk's internal busybox to PATH.
- Auto gather debugging data for unsupported devices.

# v2017.10.10 (201710100)
- Additional devices support
- Enhanced debugging tool (cs debug).
- Fixed "cs -i" not displaying actual battery info.

# v2017.10.9-1 (201710910)
* Enhanced debugging option (cs debug).
-- It can now gather much better data to hopefully support an even wider range of devices.

# v2017.10.9 (201710900)
- Additional devices support
- Bug fixes & optimizations

# v2017.10.8.1 (201710810)
* Additional devices support
* Added missing "clear battery stats" flag

# v2017.10.8 (201710800)
* Added
-- Additional devices support
-- Debugging option (cs debug)
-- Ability to automatically resume charging if battery level drops below a set %
* Bug fixes
* Major optimizations
* Note: your terminal emulator must be excluded from battery optimization &/or Doze for cs to work properly.

# v2017.9.10 (20179100)
- Settings are now preserved across updates.
- Option to clear battery stats after the target % level is reached, or manually at anytime.
- Ability to start & stop charging intermittently on set time intervals until the desired % is reached.
- Improved reference for extra user friendliness (more real life usage tips).
- Module template 1400

# v2017.9.5.1
- Fixed cs history not fully read (missing percentage value).

# v2017.9.5
- Major optimizations
- Initial release

# v2017.9.1
- Initial version