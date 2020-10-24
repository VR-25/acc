wizard() {

  clear
  echo
  print_header

  echo
  { daemon_ctrl | sed "s/ $accVer ($accVerCode)//"; } || :
  echo

echo -n "1) $(print_lang)
2) $(print_cmds)
3) $(print_doc)
4) $(print_re_start_daemon)
5) $(print_stop_daemon)
6) $(print_export_logs)
7) $(print_charge_once)
8) $(print_uninstall)
9) $(print_edit config.txt)
a) $(print_reset_bs)
b) $(print_test_cs)
c) $(print_update)
d) $(print_flash_zips)
e) $(print_exit)

#? "
  read -n 1 choice
  echo
  echo

  case $choice in

    1)
      . $execDir/set-prop.sh; set_prop --lang
      exec /dev/.vr25/acc/acc
    ;;

    2)
      . $execDir/print-help.sh
      print_help_
      exec wizard
    ;;

    3)
      edit $readMe
      exec wizard
    ;;

    4)
      /dev/.vr25/acc/accd
      sleep 1
      exec wizard
    ;;

    5)
      daemon_ctrl stop > /dev/null || :
      exec wizard
    ;;

    6)
      logf --export
      echo
      print_press_key
      read -n 1
      exec wizard
    ;;

    7)
      clear
      echo
      echo -n "(i) "
      print_1shot
      echo
      print_quit CTRL-C
      echo
      echo -n "%? "
      read level
      clear
      /dev/.vr25/acc/acc --full ${level-}
      exit $?
    ;;

    8)
      print_quit CTRL-C
      print_press_key
      read -n 1
      set +eu
      $execDir/uninstall.sh
    ;;

    9)
      edit $config
      exec wizard
    ;;

    a)
      dumpsys batterystats --reset || :
      rm /data/system/batterystats* 2>/dev/null || :
      exec wizard
    ;;

    b)
      /dev/.vr25/acc/acc --test || :
      print_press_key
      read -n 1
      exec wizard
    ;;

    c)
      /dev/.vr25/acc/acc --upgrade --changelog || :
      print_press_key
      read -n 1
      exec /dev/.vr25/acc/acc
    ;;

    d)
      (
        set +eux
        trap - EXIT
        $execDir/flash-zips.sh
      ) || :
      echo
      print_press_key
      read -n 1
      exec /dev/.vr25/acc/acc
    ;;

    e)
      exit 0
    ;;

    *)
      print_wip
      sleep 2
      exec wizard
    ;;
  esac
}
