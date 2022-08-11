# 简体中文 (zh-rCN)

print_already_running() {
  echo "accd 已处于运行状态"
}

print_started() {
  echo "accd 已启动"
}

print_stopped() {
  echo "accd 已停止"
}

print_not_running() {
  echo "accd 当前没有运行"
}

print_restarted() {
  echo "accd 已重启"
}

print_is_running() {
  echo "accd $1 正在运行 $2"
}

print_config_reset() {
  echo "配置已重置"
}

print_invalid_switch() {
  echo "无效充电开关, [${chargingSwitch[@]-}]"
}

print_charging_disabled_until() {
  echo "电量高于 $1 时停止充电"
}

print_charging_disabled_for() {
  echo "停止充电 $1"
}

print_charging_disabled() {
  echo "已停止充电"
}

print_charging_enabled_until() {
  echo "电量高于 $1 时继续充电"
}

print_charging_enabled_for() {
  echo "开始充电 $1"
}

print_charging_enabled() {
  echo "已开始充电"
}

print_unplugged() {
  echo "确保充电器已插上 🔌"
}

print_switch_works() {
  echo "[$@] 可用 ✅"
}

print_switch_fails() {
  echo "[$@] 不可用 ❌"
}

print_no_ctrl_file() {
  echo "未找到控制文件"
}

print_not_found() {
  echo "未找到 $1 目录"
}

# print_ext_app() {

# print_help() {

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
  echo "按 $1 退出"
  [ -z "${2-}" ] || echo "- 或按 $2 保存并退出"
}

print_curr_restored() {
  echo "已恢复默认最大充电电流"
}

print_volt_restored() {
  echo "已恢复默认最大充电电压"
}

print_read_curr() {
  echo "需要先读取默认最大充电电流"
}

print_curr_set() {
  echo "已将最大充电电流设定为 $1$(print_mA)"
}

print_volt_set() {
  echo "已将最大充电电压设定为 $1$(print_mV)"
}

print_wip() {
  echo "未知选项"
  echo "- 运行 acc -h 或 -r 获取帮助 "
}

print_press_key() {
  printf "按任意键继续..."
}

print_lang() {
  echo "语言 🌐"
}

print_doc() {
  echo "文档 📘"
}

print_cmds() {
  echo "所有命令"
}

print_re_start_daemon() {
  echo "启动/重启进程 ▶️ 🔁"
}

print_stop_daemon() {
  echo "停止进程 ⏹️"
}

print_export_logs() {
  echo "导出日志"
}

print_1shot() {
  echo "不受限制地一次性冲到指定电量 (默认: 100%)"
}

print_charge_once() {
  echo "一次性冲到 #%"
}

print_mA() {
  echo " 毫安"
}

print_mV() {
  echo " 毫伏"
}

print_uninstall() {
  echo "卸载"
}

print_edit() {
  echo "编辑 $1"
}

print_flash_zips() {
  echo "刷写 zip"
}

print_reset_bs() {
  echo "重置电池状态"
}

print_test_cs() {
  echo "测试充电开关"
}

print_update() {
  echo "检查更新 🔃"
}

print_W() {
  echo " 瓦"
}

print_V() {
  echo " 伏"
}

print_available() {
  echo "$@ 可用"
}

print_install_prompt() {
  printf "- 我应该下载并安装它吗? ([回车]: 是, CTRL-C: 否) "
}

print_no_update() {
  echo "无更新"
}

print_A() {
  echo " 安"
}

# print_only() {

print_wait() {
  echo "这可能需要一些时间... ⏳"
}

print_as_warning() {
  echo "⚠️ 警告: 如果你不充电，我将在 ${1}% 的电量时关机!"
}

print_i() {
  echo "电池信息"
}

print_undo() {
  echo "撤销更新"
}

print_blacklisted() {
  echo "  开关已被加入黑名单; 不会对其进行测试 🚫"
}


# print_acct_info() {


# print_panic() {


print_resume() {
  echo "  ##########
  等待恢复充电...
  如果几秒钟后并未恢复,请尝试重新插上充电器。
  如果等得太久了,请拔掉充电器,使用 CTRL-C 停止测试,运行 accd -i,并等待几秒,然后重启。
  在极端情况下，应在 $dataDir/logs/write.log 中注释掉（blacklist）这个开关，重启（以启用充电），并重新进行测试。
  ##########"
}


print_hang() {
  echo "稍等..."
}