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

print_known_switches() {
  echo "(i) 充电开关可用"
}

print_invalid_switch() {
  echo "(!) 无效充电开关, [${chargingSwitch[@]-}]"
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

print_switch_works() {
  echo "(i) [$@] 可用"
}

print_switch_fails() {
  echo "(!) [$@] 不可用"
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
