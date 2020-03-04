wizard() {

  clear
  echo
  echo "Advanced Charging Controller $accVer ($accVerCode)
(c) 2017-2020, VR25 (patreon.com/vr25)
GPLv3+"

  echo
  { daemon_ctrl | sed "s/ $accVer ($accVerCode)//"; } || :
  echo

echo "1) $(print_lang)
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
d) $(print_flash_zip)
e) $(print_exit)
"
  echo -n "?: "
  read -n 1 choice
  echo
  echo

  case $choice in

    1)
      . $modPath/set-prop.sh; set_prop --lang
      exec /sbin/acc
    ;;

    2)
      print_help > $TMPDIR/.help
      edit $TMPDIR/.help
      rm $TMPDIR/.help
      exec wizard
    ;;

   3)
      edit $readMe
      exec wizard
    ;;

    4)
      /sbin/accd
      exec wizard
    ;;

    5)
      daemon_ctrl stop > /dev/null || :
      exec wizard
    ;;

    6)
      logf --export
      echo
      print_press_enter
      read
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
      echo -n "%: "
      read level
      clear
      /sbin/acc --full ${level-}
      exit $?
    ;;

  8)
    print_quit CTRL-C
    print_press_enter
    read
    set +euo pipefail 2>/dev/null
    $modPath/uninstall.sh
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
    /sbin/acc --test -- || :
    print_press_enter
    read
    exec wizard
  ;;

   c)
    /sbin/acc --upgrade || :
    print_press_enter
    read
    exec wizard
  ;;

  d)
    (
      set +euxo pipefail 2>/dev/null
      trap - EXIT
      $modPath/install-zip.sh "$2"
    ) || :
    echo
    print_press_enter
    read
    exec wizard
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
