# 简体中文 (zh-rCN)

print_already_running() {
  echo "accd 已在运行"
}

print_started() {
  echo "accd 已启动"
}

print_stopped() {
  echo "accd 已停止"
}

print_not_running() {
  echo "accd 未运行"
}

print_restarted() {
  echo "accd 已重启"
}

print_is_running() {
  echo "accd $1 已在运行 $2"
}

print_config_reset() {
  echo "配置已重置"
}

print_invalid_switch() {
  echo "无效的充电开关,  [${chargingSwitch[@]-}]"
}

print_charging_disabled_until() {
  echo "已停止充电, 直到电池 $([ ${2:-.} = v ] && echo "电压" || echo "容量") <= $1"
}

print_charging_disabled_for() {
  echo "$1 已停止充电"
}

print_charging_disabled() {
  echo "已停止充电"
}

print_charging_enabled_until() {
  echo "已开始充电, 直到电池 $([ ${2:-.} = v ] && echo "电压" || echo "容量") <= $1"
}

print_charging_enabled_for() {
  echo "$1 已开始充电"
}

print_charging_enabled() {
  echo "已开始充电"
}

print_unplugged() {
  echo "请确保充电器已插入🔌"
}

print_switch_works() {
  echo "  开关可工作✅"
}

print_switch_fails() {
  echo "  开关不工作❌"
}

print_no_ctrl_file() {
  [ .${1-} = .v ] && echo "未找到电压控制文件" \
    || echo "未找到当前的控制文件; 尝试 temp_level 功能"
}

print_not_found() {
  echo "未找到 $1"
}


print_help() {
  cat << EOF
Usage

  acc   向导

  accd   启动/重启 accd

  accd.   停止 acc/守护进程

  accd,   打印 acc/守护进程状态 (已在运行或未运行)

  acc [暂停容量/毫伏 [恢复容量/毫伏, 默认值: 暂停容量/毫伏 - 5%/50mV]]
    例如,
      acc 75 70
      acc 80 (恢复充电容量默认为 80% - 5)
      acc 3900 (与 acc 3900 3870 相同, 更好的空闲模式代替方案)

  acc [选项] [参数]   请参阅下面的选项列表

  acca [选项] [参数]   针对前端进行了优化的 acc

  acc[d] -x [选项] [参数]   设置 log=/sdcard/Download/acc[d]-\${device}.log; 对于不需要重启的调试有用

  第一个参数可以为自定义配置文件指定路径 (如果第二个使用 -x).
  如果该文件不存在, 则克隆当前配置.
    例如,
      acc /data/acc-night-config.txt --set pause_capacity=45 resume_capacity=43
      acc /data/acc-night-config.txt --set --current 500
      accd /data/acc-night-config.txt --init

  有关 accd 的注意事项:
    - "--init|-i" 的顺序无关紧要.
    - 配置文件路径中不得包含 "--init|-i".


选项

  -b|--rollback [nv]   恢复以前的安装; 使用 "n" 参数不会恢复配置; 使用 "v" 参数除了打印已恢复的版本外, 不执行任何操作
  -c|--config [[editor] [editor_opts] | g for GUI]   编辑配置文件 (默认编辑器: nano/vim/vi)
    例如,
      acc -c (edit w/ nano/vim/vi)
      acc -c less
      acc -c cat

  -c|--config a|d string|regex   给配置文件追加 (a) 或删除 (d) 值或方案
    例如,
      acc -c a : sleep profile, at 22:00 acc -s pc=50 mcc=500 mcv=3900, acc -n switched to sleep profile (追加一个计划)
      acc -c d sleep (删除所有匹配 "sleep" 的行)

  -c|--config h string   输出与 "值" (配置文件变量) 相关的配置帮助文本
    例如, acc -c h rt (或 resume_temp)

  -d|--disable [#%, #s, #m, #h or #mv (选项)]   停止充电
    例如,
      acc -d 70% (容量 <= 70% 时停止充电)
      acc -d 1h (1 小时后再充电)
      acc -d 4000mv (电池电压 <=4000mV 时停止充电)

  -D|--daemon   显示守护进程状态, (如果正在运行显示) 版本和 PID
    例如, acc -D (别称: "accd,")

  -D|--daemon [start|stop|restart]   管理守护进程
    例如,
      acc -D start (别称: accd)
      acc -D restart (别称: accd)
      accd -D stop (别称: "accd.")

  -e|--enable [#%, #s, #m, #h or #mv (选项)]   启用充电
    例如,
      acc -e 75% (充电至 75%)
      acc -e 30m (充电 30 分钟)
      acc -e 4000mv (充电至 4000mV)

  -f|--force|--full [capacity] [additional opts/args]   充电至指定容量一次 (默认值: 100%), 不受限制
    例如,
      acc -f 95 (充电至 95%)
      acc -f (充电至 100%)
      acc -f -s mcc=500 (充电至 100%, 限制电流为 500 mA)

  -F|--flash ["zip_file"]   刷写任何包含 update-binary 的 shell 脚本的压缩包文件
    例如,
      acc -F (启动压缩包刷写向导)
      acc -F "file1" "file2" "fileN" ... (安装多个压缩包文件)
      acc -F "/sdcard/Download/Magisk-v20.0(20000).zip"

  -h|--help [[editor] [editor_opts] | g for GUI]   打印此帮助文本以及配置文件

  -H|--health <mAh>   打印估计的电池健康状态

  -i|--info [case insensitive 正则表达式 (默认值: ".")]   显示电池信息
    例如,
      acc -i
      acc -i volt
      acc -i volt,curr (多种方式)

  -l|--log [-a|--acc] [[editor] [editor_opts] | g for GUI]   打印/编辑 accd 日志 (默认) 或 acc 日志 (-a|--acc)
    例如,
      acc -l (与 acc -l less 相同)
      acc -l rm
      acc -l -a cat
      acc -l grep ': ' (仅显示明确的错误)

  -la   与 -l -a 相同

  -l|--log -e|--export   导出所有日志到 /sdcard/Download/acc-logs-\$deviceName.tgz
    例如, acc -l -e

  -le   与 -l -e 相同

  -n|--notif [["STRING" (默认值: ":)")] [USER ID (默认值: 2000 (shell))]]   发送 Android 通知；可能不适用于所有系统
    例如, acc -n "Hello, World!"

  -p|--parse [<base file> <file to parse>] | <file to parse>]   快速的帮助找到可能的充电开关, 适用于所有设备
    例如,
      acc -p   解析 $dataDir/logs/power_supply-\*.log 并打印 $TMPDIR/ch-switches 中不存在的可能的充电开关
      acc -p /sdcard/power_supply-harpia.log   解析指定的文件并打印不存在 $TMPDIR/ch-switches 中的可能的充电开关
      acc -p /sdcard/charging-switches.txt /sdcard/power_supply-harpia.log   解析 /sdcard/power_supply-harpia.log 并打印 /sdcard/charging-switches.txt 中不存在的可能的充电开关

  -r|--readme [g for GUI]]   打开手册

  -R|--resetbs   重置电池统计信息
    例如, acc -R

  -s|--set   打印当前配置文件
    例如, acc -s

  -s|--set file   从文件获取配置 (采用 "acc -s" 格式); 文件路径必须是绝对路径
    例如, acc -s /data/config

  -s|--set prop1=value "prop2=value1 value2"   设置 [多个] 属性
    例如,
      acc -s charging_switch=
      acc -s pause_capacity=60 resume_capacity=55 (快捷方式: acc -s pc=60 rc=55, acc 60 55)
      acc -s "charging_switch=battery/charging_enabled 1 0" resume_capacity=55 pause_capacity=60
    注意: 所有属性都有简短的别称, 以便更快地输入; 运行 "acc -c cat" 即可查看它们

  -s|--set c|--current [milliamps|-]   设置/打印/恢复默认 最大充电电流 (范围: 0-9999$(print_mA))
    例如,
      acc -s c (打印电流限制)
      acc -s c 500 (设置)
      acc -s c - (恢复默认)

  -sc [milliamps|-]   与上面相同

  -s|--set l|--lang   更改语言
    例如, acc -s l

  -sl   与上面相同

  -s|--set d|--print-default [正则表达式 (默认值: ".")]   打印默认配置，不包含空行
    例如,
      acc -s d (显示整个默认配置)
      acc -s d cap (仅显示与 "cap" 相关的条目)
      acc -s cap,temp (多种方法)

  -sd [正则表达式 (默认值: ".")]   与上面相同

  -s|--set p|--print [正则表达式 (默认值: ".")]   打印当前配置，不包含空行 (参考前面的示例)

  -sp [正则表达式 (default: ".")]   与上面相同

  -s|--set r|--reset [a]   恢复默认配置 ("a" 代表 "全部": 配置文件和控制文件黑名单, 本质上是硬重置)
    例如,
      acc -s r

  -sr [a]   与上面相同


  -s|--set s|charging_switch   强制执行特定的充电开关
    例如, acc -s s

  -ss    与上面相同

  -s|--set s:|chargingSwitch:   列出已知的充电开关
    例如, acc -s s:

  -ss:   与上面相同

  -s|--set v|--voltage [millivolts|-] [--exit]   设置/打印/恢复默认 最大充电电压 (范围: 3700-4300$(print_mV))
    例如,
      acc -s v (打印)
      acc -s v 3900 (设置)
      acc -s v - (恢复默认)
      acc -s v 3900 --exit (应用设置后停止守护进程)

  -sv [millivolts|-] [--exit]   与上面相同

  -t|--test [ctrl_file1 on off [ctrl_file2 on off]]   测试指定的充电开关
    例如,
      acc -t battery/charging_enabled 1 0
      acc -t /proc/mtk_battery_cmd/current_cmd 0::0 0::1 /proc/mtk_battery_cmd/en_power_path 1 0 ("::" is a placeholder for " " - MTK only)

  -t|--test [file]   从文件测试充电开关 (默认值: $TMPDIR/ch-switches)
    例如,
      acc -t (测试已知的开关)
      acc -t /sdcard/experimental_switches.txt (测试自定义/外部的开关)

  -t|--test [p|parse]   从电源日志中解析可能的充电开关 (如 "acc -p"), 然后测试全部, 并将可工作的开关添加到已知开关列表中
    Implies -x, as acc -x -t p
    例如, acc -t p

  -T|--logtail   监控 accd 日志 (tail -F)
    例如, acc -T

  -u|--upgrade [-c|--changelog] [-f|--force] [-n|--non-interactive]   在线升级/降级
    例如,
      acc -u dev (升级至最新的 dev 版本)
      acc -u (当前分支的最新版本)
      acc -u master^1 -f (先前的稳定版本)
      acc -u -f dev^2 (最新 dev 版本的前两个版本)
      acc -u v2020.4.8-beta --force (强制升级/降级至 v2020.4.8-beta)
      acc -u -c -n (如果有可用的更新, 则打印版本代码 (整数值) 和更新日志)
      acc -u -c (与上面相同, 但带有安装提示)

  -U|--uninstall   彻底删除 acc 和 AccA
    例如, acc -U

  -v|--version   打印 acc 版本和版本代码
    例如, acc -v

  -w[#]|--watch[#] [pattern1,pattern2,...]   监控电池事件
    e.g.,
      acc -w (每秒更新信息)
      acc -w0.5 (每半秒更新信息)
      acc -w0 (无额外延迟)
      acc -w curr,volt


退出代码

  0. 正确/成功
  1. 错误或一般失败
  2. 命令语法不正确
  3. 缺少 BusyBox 库
  4. 未以 root 身份运行
  5. 有可用的更新 ("--upgrade")
  6. 无可用的的更新 ("--upgrade")
  7. 无法停止充电
  8. 守护进程已在运行 ("--daemon start")
  9. 守护进程未在运行 ("--daemon" and "--daemon stop")
  10. 所有充电开关均失效 (--test)
  11. 电流 (mA) 超出 0-9999 范围
  12. 初始化失败
  13. 无法锁定 $TMPDIR/acc.lock
  14. ACC 无法初始化, 因为 Magisk 设置了模块禁用标识
  15. 支持空闲模式(--test)
  16. 无法启用充电 (--test)

  当退出代码为 1、2 和 7 时，日志会自动导出 ("--log --export").


提示

  可以将命令套嵌起来以扩展功能.
    例如, 充电 30 分钟, 暂停充电 6 小时, 充电至 85% 和重启守护进程
    acc -e 30m && acc -d 6h && acc -e 85 && accd
  可以使用单行脚本和内置的 "at" 函数来计划配置文件 (请参阅 -c|--config).

  示例配置文件
    acc -s pc=60 mcc=500 mcv=3900
      这样可以将电池容量保持在 55-60% 之间, 将充电电流限制为 500 mA 和电压为 3900 mV.
      它非常适合夜间和 "永远插电".

  请参阅 acc -r (或 --readme) 获取完整文档 (推荐)
EOF
}


print_exit() {
  echo "退出"
}

print_choice_prompt() {
  echo "(?) 请选择, [回车键确认]: "
}

print_auto() {
  echo "自动"
}

print_default() {
 echo "默认"
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
  echo "最大充电电流设置为 $1$(print_mA)"
}

print_volt_set() {
  echo "最大充电电压设置为 $1$(print_mV)"
}

print_wip() {
  echo "无效选项"
  echo "- 运行 acc -h 或 -r 获取帮助 "
}

print_press_key() {
  printf "按下任意键以继续..."
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
  echo "启动/重启守护进程 ▶️ 🔁"
}

print_stop_daemon() {
  echo "停止守护进程 ⏹️"
}

print_export_logs() {
  echo "导出日志"
}

print_1shot() {
  echo "充电至指定容量一次 (默认值: 100%), 不受限制"
}

print_charge_once() {
  echo "充电一次至 #%"
}

print_mA() {
  echo " mA"
}

print_mV() {
  echo " mV"
}

print_uninstall() {
  echo "卸载"
}

print_edit() {
  echo "编辑 $1"
}

print_flash_zips() {
  echo "刷写压缩包"
}

print_reset_bs() {
  echo "重置电池统计信息"
}

print_test_cs() {
  echo "测试充电开关"
}

print_update() {
  echo "检查更新 🔃"
}

print_W() {
  echo " W"
}

print_V() {
  echo " V"
}

print_available() {
  echo "可用的 $@"
}

print_install_prompt() {
  printf "- 下载并安装? ([回车键]: 是, CTRL-C: 否) "
}

print_no_update() {
  echo "无可用的更新"
}

print_A() {
  echo " A"
}

print_only() {
  echo "仅"
}

print_wait() {
  echo "可能还要等一下... ⏳"
}

print_as_warning() {
  echo "⚠️ 警告: 如果在电池电量 ${1}% 前不插入充电器将会关机!"
}

print_i() {
  echo "电池信息"
}

print_undo() {
  echo "回退升级"
}

print_blacklisted() {
  echo "  开关已被列入黑名单; 将不会测试 🚫"
}


print_acct_info() {
  echo "
💡注意/提示:

  某些开关 -- 尤其是控制电流和电压的开关 -- 容易出现不一致. 如果开关至少正常工作两次, 则假设其功能正常.

  结果可能因电源和条件的不同而不同, 如 \"readme > troubleshooting > charging switch\" 中所述.

  想要测试所有可能的开关? \"acc -t p\" 从电源日志中解析它们 (如 \"acc -p\"), 测试全部, 并将正常工作的开关添加到已知开关列表中.

  要设置充电开关, 运行 acc -ss (向导) 或 acc -s s=\"switches go here --\".

  电池空闲模式: 设备是否支持直接使用充电器运行.
  如果不支持, 您仍有选项. 请参阅 \"README > FAQ > What's idle mode, and how do I set it up?\"

  此命令的输出将保存到 ${logF}."
}


print_panic() {
  printf "\n警告: 实验性功能, 保持注意!
根据已知方式排除可能存在问题的控制文件.
一些触发重启的控制文件会被自动列入黑名单. 
您是否想在测试之前查看/编辑可能的开关列表?
a: 中止操作 | n: 否 | y: 是 (默认)"
}


print_resume() {
  echo "  ##########
  等待充电恢复...
  如果几秒后仍未恢复, 请尝试重新插入充电器. 
  如果时间过长, 请拔下充电器, 然后使用 CTRL-C 停止测试, 再运行 accd -i, 先等待几秒, 然后重新测试.
  在极端情况下, 应在 $dataDir/logs/write.log 中注释 (黑名单) 此开关, 重启 (以启用充电), 然后重新运行测试.
  ##########"
}


print_hang() {
  echo "请稍等..."
}
