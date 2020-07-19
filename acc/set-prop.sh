set_prop() {

  local daemonWasUp=true restartDaemon=false

  daemon_ctrl > /dev/null || daemonWasUp=false

  (case ${1-} in

    # set multiple properties
    *=*)

      case "$*" in
        s=*|*\ s=*|*charging_switch=*|*sc=*|*shutdown_capacity=*)
          ! $daemonWasUp || daemon_ctrl stop > /dev/null
          restartDaemon=true
        ;;
      esac

      . $defaultConfig
      . $config

      export "$@"

      case "$*" in
        *ab=*|*apply_on_boot=*)
          apply_on_boot
        ;;
      esac

      [ .${mcc-${max_charging_current-x}} = .x ] || {
        . $execDir/set-ch-curr.sh
        set_ch_curr ${mcc:-${max_charging_current:--}} || :
      }

      [ .${mcv-${max_charging_voltage-x}} = .x ] || {
        . $execDir/set-ch-volt.sh
        set_ch_volt ${mcv:-${max_charging_voltage:--}} || :
      }
    ;;

    # reset config
    r|--reset)
      ! $daemonWasUp || daemon_ctrl stop > /dev/null
      cp -f $defaultConfig $config
      print_config_reset
      ! $daemonWasUp || /dev/accd
      return 0
    ;;

    # print default config
    d|--print-default)
      . $defaultConfig
      . $execDir/print-config.sh | grep -E "${2-.}" || :
      return 0
    ;;

    # print current config
    p|--print)
      . $execDir/print-config.sh | grep -E "${2-.}" || :
      return 0
    ;;

    # set charging switch
    s|--charging*witch)
      ! $daemonWasUp || daemon_ctrl stop > /dev/null
      restartDaemon=true
      IFS=$'\n'
      PS3="$(print_choice_prompt)"
      print_known_switches
      . $execDir/select.sh
      select_ charging_switch $(print_auto; cat $TMPDIR/ch-switches; print_exit)
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
      . $execDir/set-ch-curr.sh
      set_ch_curr ${2-}
    ;;

    # set charging voltage
    v|--voltage)
      shift
      . $execDir/set-ch-volt.sh
      set_ch_volt "$@"
    ;;

    # set language
    l|--lang)
      IFS=$'\n'
      PS3="$(print_choice_prompt)"
      . $execDir/select.sh
      eval 'select_ _lang \
        $(echo "- English (en)" | grep -v $language; \
        (for file in $(ls -1 $execDir/translations/*/strings.sh); do \
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
      . $execDir/print-config.sh
      return 0
    ;;

  esac

  # update config.txt
  . $execDir/write-config.sh

  ! $restartDaemon || { ! $daemonWasUp || /dev/accd; })
}
