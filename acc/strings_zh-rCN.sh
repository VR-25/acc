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
  echo "(i) accd 正在运行"
}

print_invalid_var() {
  echo "(!) 无效变量, [$var]"
}

print_config_reset() {
  echo "(i) 配置已重置"
}

print_cs_reset() {
  echo "(i) 充电开关已设置为 \"自动\""
}

print_supported_cs() {
  echo "(i) 充电开关可用"
}

print_cs_fails() {
  echo "(!) [$(get_value chargingSwitch)] 不可用"
}

print_invalid_cs() {
  echo "(!) 无效充电开关, [$(get_value chargingSwitch)]"
}

print_ch_disabled_until() {
  echo "(i) 电量高于 $1 时停止充电"
}

print_ch_disabled_for() {
  echo "(i) 停止充电 $1"
}

print_ch_disabled() {
  echo "(i) 已停止充电"
}

print_ch_enabled_until() {
  echo "(i) 电量高于 $1 时继续充电"
}

print_ch_enabled_for() {
  echo "(i) 开始充电 $1"
}

print_ch_enabled() {
  echo "(i) 已开始充电"
}


print_dvolt_restored() {
  echo "(i) 已成功还原默认充电电压阈值为 ($(grep -o '^....' $file)mV)"
}

print_dvolt_already_set() {
  echo "(i) 充电电压阈值已经重置为默认值"
}

print_invalid_input() {
  echo "(!) 无效输入, [$@]"
}

print_accepted_volt() {
  echo "- 注意, 电压的有效值在3500至4350毫伏之间"
}

print_cvolt_set() {
  echo "(i) 充电电压阈值已设置为 $(grep -o '^....' $file)mV"
}

print_cvolt_unsupported() {
  echo "(!) [$(echo -n $file)] 不是有效的文件，或者您的内核不支持自定义充电电压"
}

print_no_such_file() {
  echo "(!) [$file] 不存在"
}

print_supported_cvolt_files() {
  echo "(i) 充电电压控制文件可用"
}

print_cvolt_limit_set() {
  echo "(i) chargingVoltageLimit=$file:$1 --> config.txt"
}

print_unplugged() {
  echo "(!) 需要设备处于充电状态"
}

print_file_works() {
  echo "(i) [$file $on $off] 可用"
}

print_file_fails() {
  echo "(!) [$file $on $off] 不可用"
}

print_supported() {
  echo "(i) 设备受支持"
}

print_unsupported() {
  echo "(!) 设备不受支持"
}

print_no_modpath() {
  echo "(!) 未找到 modPath 目录"
}

print_help() {
  cat << HELP
高级充电控制器
Copyright (c) 2017-2019, VR25 (xda-developers.com)
协议: GPLv3+
版本号: $(sed -n 's/versionCode=//p' $modPath/module.prop)

示例: acc <-x|--xtrace> <option(s)> <arg(s)>

-c|--config <editor [opts]>   使用指定编辑器修改配置 (默认编辑器: nano|vim|vi)
  例如, acc -c

-d|--disable <#%, #s, #m or #h (可选)>   停止充电, 可以不加条件
  例如,
    acc -d 70% (电量降至70%后再充电)
    acc -d 1h (1小时后再充电)

-D|--daemon   显示当前 acc 后台程序 (accd) 状态
  例如, acc -D (别名: "accd,")

-D|--daemon <start|stop|restart>   管理 accd 状态
  例如,
    acc -D restart
    accd -D stop (别名: "accd.")

-e|--enable <#%, #s, #m or #h (可选)>   充电或在指定条件下充电
  例如, acc -e 30m (充电30分钟)

-f|--force|--full <电量值>   不间断充电至指定电量, 默认充满
  例如, acc -f 95

-i|--info   显示电源信息
  例如, acc -i

-l|--log <-a|--acc> <editor [opts]>   使用指定编辑器查看 accd 日志(默认)或者 acc 日志(-a) (默认编辑器: nano|vim|vi)
  例如, acc -l grep ': ' (仅显示显式错误)

-l|--log -e|--export   导出所有日志至 /sdcard/acc-logs-<device>.tar.bz2
  例如, acc -l -e

-L|--logwatch   实时查看 accd 日志
  例如, acc -L

-r|--readme   使用指定编辑器打开 README.md (默认编辑器: vim|vi)
  例如, acc -r

-R|--resetbs   重置电池状态
  例如, acc -R

-s|--set   显示当前配置
  例如, acc -s

-s|--set <r|reset>   恢复默认配置
  例如, acc -s r

-s|--set <var> <value>   设置配置参数 (可选: -s|--set <regexp> <value> (可交互))
  例如,
    acc -s capacity 5,60,80-85 (5: 关机, 60: 冷却, 80: 恢复, 85: 暂停)
    acc -s cool 55/15

-s|--set <resume-stop preset>   可以为 4041|endurance+, 5960|endurance, 7080|default, 8090|lite, 9095|travel
  例如,
    acc -s endurance+ (换言之, "锂电池最佳工作状态"; 最适合 GPS 导航和其他长时间操作)
    acc -s travel (当你需要榨干电池时)
    acc -s 7080 (恢复默认电量设置 (5,60,70-80))

-s|--set <s|chargingSwitch>   从数据库中设置不同的充电开关
  例如, acc -s s

-s|--set <s:|chargingSwitch:>   列出可用的充电开关
  例如, acc -s s:

-s|--set <s-|chargingSwitch->   复位充电开关
  例如, acc -s s-

-t|--test   测试当前设置的充电控制文件
  退出码: 0 (可用), 1 (不可用) 或 2 (需要充电状态)
  例如, acc -t

-t|--test <file on off>   测试指定的充电控制文件
  退出码: 0 (可用), 1 (不可用) 或 2 (需要充电状态)
  例如, acc -t battery/charging_enabled 1 0

-t|--test -- <file (默认: $modPath/switches.txt)>   从指定文件测试充电开关
  这还将报告是否支持 "电池空闲" 模式
  退出码: 0 (可用), 1 (不可用) 或 2 (需要充电状态)
  例如, acc -t -- /sdcard/experimental_switches.txt

-u|--upgrade [-c|--changelog|-f|--force|-n|--non-interactive] [reference]   升级/降级
  例如,
    acc -u dev (升级至最新开发版本)
    acc -u (最新稳定版本)
    acc -u master^1 -f (前一个稳定版本)
    acc -u -f dev^2 (低于最新开发版本的倒数第三个开发版本)
    acc -u 201905110 --force (2019.5.11 版本)

-U|--uninstall 卸载

-v|--voltage   显示当前充电电压
  例如, acc -v

-v|--voltage :   列出可用/默认充电电压控制文件
  例如, acc -v :

-v|--voltage -   恢复默认充电电压阈值
  例如, acc -v -

-v|--voltage <millivolts>   设置充电电压阈值 (默认/已设置控制文件)
  例如, acc -v 4100

-v|--voltage <file:millivolts>   设置充电电压阈值 (自定义控制文件)
  例如, acc -v battery/voltage_max:4100

-V|--version   显示 acc 版本号
  例如, acc -V

-x|--xtrace   运行为调试模式 (记录详细信息)
  例如, acc -x -t --

提示

  可以为扩展功能拼接命令.
    例如, acc -e 30m && acc -d 6h && acc -e 85 && accd (充电半小时, 中断充电6小时, 继续充电至85%并重启后台程序)

  也可以通过 'acc <pause%> <resume%>' 命令设置暂停和恢复充电时的电量.
    例如, acc 85 80

  最后一个命令可以用于在睡觉前编排充电。在这种情况下，后台程序必须处于运行状态.
    例如, acc 45 44 && acc --set applyOnPlug usb/current_max:500000 && sleep $((60*60*7)) && acc 80 70 && acc --set applyOnPlug usb/current_max:2000000
    - "保持电池容量在45%左右, 并将充电电流限制在500毫安, 持续7小时. 之后恢复常规充电设置."
    - 为了方便起见, 可以将其写入文件并使用"sh <file>"运行.
    - 如果你的设备支持自定义充电电压阈值, 最好使用如下命令代替: "acc -v 3920 && sleep $((60*60*7)) && acc -v -".

运行 acc --readme 查看完整的文档.
HELP
}

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
