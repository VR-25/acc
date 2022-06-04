# 繁體中文 (zh-rTW)

print_already_running() {
  echo "accd 目前是執行狀態"
}

print_started() {
  echo "accd 已啟動"
}

print_stopped() {
  echo "accd 已停止"
}

print_not_running() {
  echo "accd 目前沒有執行"
}

print_restarted() {
  echo "accd 以重啟"
}

print_is_running() {
  echo "accd $1 正在執行 $2"
}

print_config_reset() {
  echo "設定已重製"
}

print_invalid_switch() {
  echo "無效的充電開關, [${chargingSwitch[@]-}]"
}

print_charging_disabled_until() {
  echo "電量高於 $1 時停止充電"
}

print_charging_disabled_for() {
  echo "停止充電 $1"
}

print_charging_disabled() {
  echo "已停止充電"
}

print_charging_enabled_until() {
  echo "電量高於 $1 時繼續充電"
}

print_charging_enabled_for() {
  echo "開始充電 $1"
}

print_charging_enabled() {
  echo "已開始充電"
}

print_switch_works() {
  echo "[$@] 可用"
}

print_switch_fails() {
  echo "[$@] 不可用"
}

print_not_found() {
  echo "未找到 $1 目錄"
}

#print_help() {

print_exit() {
  echo "離開"
}

print_choice_prompt() {
  echo "(?) 請選擇, 確認鍵結束: "
}

print_auto() {
  echo "自動"
}

print_default() {
 echo "預設"
}
