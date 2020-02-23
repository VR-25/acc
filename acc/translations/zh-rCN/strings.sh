# 简体中文 (zh-rCN)

print_already_running() {
  echo "(i) accd 已处于运行状态"
}

print_started() {
  echo "(i) accd 已启动"
}

print_stopped() {
  echo "(i) accd 已停止"
}

print_not_running() {
  echo "(i) accd 当前没有运行"
}

print_restarted() {
  echo "(i) accd 已重启"
}

print_is_running() {
  echo "(i) accd $1 正在运行 $2"
}

print_config_reset() {
  echo "(i) 配置已重置"
}

print_known_switch() {
  echo "(i) 充电开关可用"
}

print_switch_fails() {
  echo "(!) [${chargingSwitch[@]}] 不可用"
}

print_invalid_switch() {
  echo "(!) 无效充电开关, [${chargingSwitch[@]}]"
}

print_charging_disabled_until() {
  echo "(i) 电量高于 $1 时停止充电"
}

print_charging_disabled_for() {
  echo "(i) 停止充电 $1"
}

print_charging_disabled() {
  echo "(i) 已停止充电"
}

print_charging_enabled_until() {
  echo "(i) 电量高于 $1 时继续充电"
}

print_charging_enabled_for() {
  echo "(i) 开始充电 $1"
}

print_charging_enabled() {
  echo "(i) 已开始充电"
}

print_unplugged() {
  echo "(!) 需要设备处于充电状态"
}

print_switch_works() {
  echo "(i) [$@] 可用"
}

print_switch_fails() {
  echo "(!) [$@] 不可用"
}

print_supported() {
  echo "(i) 设备受支持"
}

print_unsupported() {
  echo "(!) 设备不受支持"
}

print_not_found() {
  echo "(!) 未找到 $1 目录"
}

#print_help() {

print_exit() {
  echo "退出"
}

print_choice_prompt() {
  echo "(?) 请选择, 回车键结束: "
}

print_auto() {
  echo "自动"
}

print_default() {
 echo "默认"
}

print_quit() {
  echo "(i) Press $1 to quit"
}

print_curr_restored() {
  echo "(i) Default max charging current restored"
}

print_volt_restored() {
  echo "(i) Default max charging voltage restored"
}

print_read_curr() {
  echo "(i) Need to read default max charging current value(s) first"
  print_unplugged
  echo -n "- Waiting... (press CTRL-C to abort)"
}

print_curr_set() {
  echo "(i) Max charging current set to $1 milliamps"
}

print_volt_set() {
  echo "(i) Max charging voltage set to $1 millivolts"
}

print_curr_range() {
  echo "(!) [$1] (milliamps) only"
}

print_volt_range() {
  echo "(!) [$1] (millivolts) only"
}

print_wip() {
  echo "(i) Work in progress"
  echo "- Run acc -h or -r for help"
}

print_press_enter() {
  echo -n "(i) Press [enter] to continue..."
}

print_lang() {
  echo "Language"
}

print_doc() {
  echo "Documentation"
}

print_cmds() {
  echo "All commands"
}

print_re_start_daemon() {
  echo "Start/restart daemon"
}

print_stop_daemon() {
  echo "Stop daemon"
}

print_export_logs() {
  echo "Export logs"
}

print_1shot() {
  echo "Charge once to a given level (default: 100%), without other restrictions"
}

print_charge_once() {
  echo "Charge once to #%"
}

print_mA() {
  echo "milliamps"
}

print_mV() {
  echo "millivolts"
}
