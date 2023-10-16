ls_ch_switches() {
  echo "
*/*charging_enable* 1 0
*/*disable_charg* 0 1
*/charge_disable 0 1
*/charge_enabled 1 0
*/charger_control 1 0
*/charging_state enabled disabled
*/enable_charg* 1 0
*/input_suspend 0 1
battery/batt_slate_mode 0 1
battery/battery_input_suspend 0 1
battery/bd_trickle_cnt 0 1
battery/device/*stop_charging 0 1
battery/device/Charging_Enable 1 0
battery/op_disable_charge 0 1
battery/store_mode 0 1
battery/test_mode 2 1
battery_ext/smart_charging_interruption 0 1
idt/pin_enabled 1 0
battery/siop_level 100 0

battery/charging_enabled 0 0 battery/op_disable_charge 0 1 battery/charging_enabled 1 1
battery/input_suspend 0 1 /proc/mtk_battery_cmd/en_power_path 1 1

/proc/*disable_chrg 0 1
/sys/class/battchg_ext/*charge_disable 0 1
/sys/class/battchg_ext/*input_suspend 0 1
/sys/class/hw_power/charger/charge_data/enable_charger 1 0
/sys/class/qcom-battery/input_suspend 0 1
/sys/devices/*/*/*/charging_state enabled disabled
/sys/devices/platform/*/*/*/charging_state enabled disabled
/sys/devices/platform/huawei_charger/enable_charger 1 0
/sys/devices/platform/lge-unified-nodes/charging_completed 0 1
/sys/devices/platform/lge-unified-nodes/charging_enable 1 0
/sys/devices/platform/mt-battery/disable_charger 0 1
/sys/devices/platform/omap/omap_i2c.?/i2c-?/?-00??/charge_enable 1 0
/sys/devices/platform/soc/soc:google,charger/charge_disable 0 1
/sys/devices/platform/soc/soc:oplus,chg_intf/oplus_chg/battery/*charging_enable 1 0
/sys/devices/platform/soc/soc:qcom,pmic_glink/soc:qcom,pmic_glink:qcom,battery_charger/force_charger_suspend 0 1
/sys/devices/soc/soc:lge,*/lge_power/lge_*/charging_enabled 1 0
/sys/devices/virtual/oplus_chg/battery/*charging_enable 1 0
/sys/kernel/debug/google_charger/chg_suspend 0 1
/sys/kernel/debug/google_charger/input_suspend 0 1
/sys/kernel/nubia_charge/charger_bypass off on
/sys/module/pm*_charger/parameters/disabled 0 1

/proc/driver/charger_limit_enable 0 1 /proc/driver/charger_limit 100 battery/capacity
/proc/driver/charger_limit_enable 0 1 /proc/driver/charger_limit 100 5
/proc/mtk_battery_cmd/current_cmd 0::0 0::1
/proc/mtk_battery_cmd/current_cmd 0::0 0::1 /proc/mtk_battery_cmd/en_power_path 1 0
/sys/class/qcom-battery/night_charging 0 1
/sys/module/lge_battery/parameters/charge_stop_level 100 battery/capacity battery/input_suspend 0 0
/sys/module/lge_battery/parameters/charge_stop_level 100 5 battery/input_suspend 0 0

# experimental
/sys/class/qcom-battery/cool_mode 0 1
/sys/devices/platform/google,charger/charge_stop_level 100 5
/sys/devices/platform/google,charger/charge_stop_level 100 battery/capacity
/sys/kernel/debug/google_charger/chg_mode 0 1
/sys/kernel/fast_charge/force_fast_charge 1 0
#/sys/module/qpnp_fg/parameters/batt_range_pct 0 1
#/sys/module/qpnp_smbcharger/parameters/dynamic_icl_wipower_en 0 1
#battery/charge_control_limit 0 1
#bbc/hiz_mode 0 1
#bms/ignore_false_negative_isense 1 0
#bms/update_now 0 1
#CROS_USB_PD_CHARGER0/charge_control_limit_max 0 1
#usb/cc_toggle_enable 1 0
#usb/otg_fastroleswap 0 1
battery/charge_control_limit 0 battery/charge_control_limit_max
battery/hmt_ta_charge 1 0
battery/restricted_charging 0 1
battery/system_temp_in_level 0 battery/num_system_temp_in_levels
battery/system_temp_level 0 battery/num_system_temp_levels
bms/temp_cool 0 900
main/cool_mode 0 1
maxfg/offmode_charger 0 1
wireless/restricted_charging 0 1
wireless/system_temp_in_level 0 wireless/num_system_temp_in_levels
wireless/system_temp_level 0 wireless/num_system_temp_levels

# troublesome
#/sys/devices/platform/battery_meter/FG_daemon_disable 0 1
#/sys/power/pnpmgr/battery/charging_enabled 1 0
#/sys/class/qcom-battery/vbus_disable 0 1
/sys/devices/platform/battery/ChargerEnable 1 0
battery/ChargerEnable 1 0
#usb/vbus_disable 0 1

# deprecated
battery/op_disable_charge 0 1 battery/input_suspend 0 0
"
}

ls_curr_ctrl_files() {
  echo "
*/ac_charge
*/ac_input
*/aca_charge
*/aca_input
*/batt_tune_*_charge_current
#*/batt_tune_chg_limit_cur
*/car_charge
*/car_input
*/constant_charge_current*
*/current_max
*/dcp_charge
*/hv_charge
*/input_current*
*/mhl_2000_charge
*/mhl_2000_input
*/restrict*_cur*
*/sdp_charge
*/sdp_input
*/so_limit_charge
*/so_limit_input
*/wc_charge
*/wc_input
*dcp_input
/sys/class/qcom-battery/restrict*_cur*
"
}

ls_volt_ctrl_files() {
  echo "
*/batt_tune_float_voltage
*/constant_charge_voltage*
*/fg_full_voltage
*/voltage_max
/sys/d/charger/vfloat_uv
/sys/d/smb*/vfloat_mv
"
}
