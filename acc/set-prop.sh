set_prop() {

  local daemonWasUp=true restartDaemon=false

  daemon_ctrl > /dev/null || daemonWasUp=false

  (case ${1-} in

    # set multiple properties
    *=*)
      case "$*" in
        *mcv=*|*max_charging_voltage=*|*ab=*|*apply_on_boot=*|s=*|*\ s=*|*charging_switch=*|*sc=*|*shutdown_capacity=*)
          ! $daemonWasUp || daemon_ctrl stop > /dev/null
          restartDaemon=true
        ;;
      esac
      . $defaultConfig
      . $config
      export "$@"

      [ .${mcc-${max_charging_current-x}} == .x ] || {
        . $modPath/set-ch-curr.sh
        set_ch_curr ${mcc:-${max_charging_current:--}} || :
      }

      [ .${mcv-${max_charging_voltage-x}} == .x ] || {
        . $modPath/set-ch-volt.sh
        set_ch_volt ${mcv:-${max_charging_voltage:--}} || :
      }

    ;;

    # reset config
    r|--reset)
      ! $daemonWasUp || daemon_ctrl stop > /dev/null
      cp -f $defaultConfig $config
      print_config_reset
      ! $daemonWasUp || /sbin/accd
      return 0
    ;;

    # print default config
    d|--print-default)
      . $defaultConfig
      . $modPath/print-config.sh | grep -E "${2-.}"
      return 0
    ;;

    # print current config
    p|--print)
      . $modPath/print-config.sh | grep -E "${2-.}"
      return 0
    ;;

    # set charging switch
    s|--charging*witch)
      ! $daemonWasUp || daemon_ctrl stop > /dev/null
      restartDaemon=true
      IFS=$'\n'
      PS3="$(print_choice_prompt)"
      print_known_switches
      . $modPath/select.sh
      select_ chargingSwitch $(print_auto; cat $TMPDIR/ch-switches; print_exit)
      [ ${chargingSwitch:-x} != $(print_exit) ] || exit 0
      [ ${chargingSwitch:-x} != $(print_auto) ] || charging_switch=
      unset IFS
    ;;

    # print switches
    s:|--charging*witch:)
      cat $TMPDIR/ch-switches
      return 0
    ;;

    # set charging current
    c|--current)
      . $modPath/set-ch-curr.sh
      set_ch_curr ${2-}
    ;;

    # set charging voltage
    v|--voltage)
      shift
      . $modPath/set-ch-volt.sh
      set_ch_volt "$@"
    ;;

    # set language
    l|--lang)
      IFS=$'\n'
      PS3="$(print_choice_prompt)"
      . $modPath/select.sh
      eval 'select_ _lang \
        $(echo "- English (en)" | grep -v $language; \
        (for file in $(ls -1 $modPath/translations/*/strings.sh); do \
          sed -n "'s/# /- /p'" $file | grep -v $language; \
        done); \
        print_exit)'
      lang=${_lang#*\(}
      [ $lang != $(print_exit) ] || exit 0
      lang=${lang%\)*}
      unset IFS
    ;;

    # print current config (full)
    *)
      . $modPath/print-config.sh
      return 0
    ;;

  esac

  # update config.txt
  . $modPath/write-config.sh

  ! $restartDaemon || { ! $daemonWasUp || /sbin/accd; })
}
