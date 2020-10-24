print_charging_enabled() {
  :
}


reset_switch() {
  if not_charging && \
    [ $(cat $batt/capacity) -ge ${capacity[2]} ]
  then
    enable_charging
  fi
}


set_prop() {

  case ${1-} in

    # set multiple properties
    *=*)

      . $defaultConfig
      . $config

      export "$@"

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
      reset_switch
      cp -f $defaultConfig $config
      print_config_reset
      return 0
    ;;

    # print default config
    d|--print-default)
      . $defaultConfig
      . $execDir/print-config.sh | { grep -E "${2-.}" | more; } || :
      return 0
    ;;

    # print current config
    p|--print)
      . $execDir/print-config.sh | { grep -E "${2-.}" | more; } || :
      return 0
    ;;

    # set charging switch
    s|--charging*witch)
      IFS=$'\n'
      PS3="$(print_choice_prompt)"
      print_known_switches
      . $execDir/select.sh
      select_ charging_switch $(print_auto; cat $TMPDIR/ch-switches; ! grep -q / $TMPDIR/ch-curr-ctrl-files || printf '0\n250\n'; print_exit)
      [ ${charging_switch:-x} != $(print_exit) ] || exit 0
      [ ${charging_switch:-x} != $(print_auto) ] || charging_switch=
      unset IFS
    ;;

    # print switches
    s:|--charging*witch:)
      cat $TMPDIR/ch-switches
      ! grep -q / $TMPDIR/ch-curr-ctrl-files || printf '0\n250\n'
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
      . $execDir/print-config.sh | more
      return 0
    ;;

  esac

  [ ".${s-${charging_switch-x}}" = .x ] || reset_switch

  # update config.txt
  . $execDir/write-config.sh
}
