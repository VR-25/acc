wizard() {

  clear
  echo
  echo "Advanced Charging Controller $accVer ($accVerCode)
(c) 2017-2020, VR25 (patreon.com/vr25)
GPLv3+"

  echo
  { daemon_ctrl | sed "s/ $accVer ($accVerCode)//"; } || :
  echo

  select choice in "$(print_lang)" "$(print_cmds)" "$(print_doc)" \
    "$(print_re_start_daemon)" "$(print_stop_daemon)" "$(print_export_logs)" \
    "$(print_charge_once)" "$(print_uninstall)" "$(print_edit config.txt)" "$(print_reset_bs)" \
    "$(print_test_cs)" "$(print_update)" "$(print_flash_zip)" "$(print_exit)"
  do

    case $choice in

      "$(print_exit)")
        exit 0
      ;;

      "$(print_doc)")
        echo
        edit $readMe
        exec wizard
      ;;

      "$(print_cmds)")
        print_help > $TMPDIR/.help
        echo
        edit $TMPDIR/.help
        rm $TMPDIR/.help
        exec wizard
      ;;

      "$(print_lang)")
        echo
        . $modPath/set-prop.sh; set_prop --lang
        exec /sbin/acc
      ;;

      "$(print_re_start_daemon)")
        /sbin/accd
        exec wizard
      ;;

      "$(print_stop_daemon)")
        daemon_ctrl stop > /dev/null || :
        exec wizard
      ;;

      "$(print_export_logs)")
        echo
        logf --export
        echo
        print_press_enter
        read
        exec wizard
      ;;

      "$(print_charge_once)")
        clear
        echo
        echo -n "(i) "
        print_1shot
        echo
        print_quit CTRL-C
        echo
        echo -n "%: "
        read level
        clear
        /sbin/acc --full ${level-}
        exit $?
      ;;

	  "$(print_uninstall)")
      echo
      print_quit CTRL-C
      print_press_enter
      read
      set +euo pipefail 2>/dev/null
      $modPath/uninstall.sh
	  ;;

    "$(print_edit config.txt)")
      echo
      edit no-quit-msg $config
      exec wizard
    ;;

    "$(print_flash_zip)")
      echo
      (set +euxo pipefail 2>/dev/null
      trap - EXIT
      $modPath/install-zip.sh "$2") || :
      echo
      print_press_enter
      read
      exec wizard
    ;;

    "$(print_reset_bs)")
      dumpsys batterystats --reset || :
      rm /data/system/batterystats* 2>/dev/null || :
      exec wizard
    ;;

     "$(print_test_cs)")
      /sbin/acc --test -- || :
      print_press_enter
      read
      exec wizard
    ;;

     "$(print_update)")
      /sbin/acc --upgrade || :
      print_press_enter
      read
      exec wizard
    ;;

      *)
        echo
        print_wip
        sleep 1.5
        exec wizard
      ;;
    esac
  done
}
