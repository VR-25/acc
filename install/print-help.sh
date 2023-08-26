print_help_() {

  {
    print_header
    echo
    echo
    print_help
  } > $TMPDIR/.help

  case "$language" in
    en|"")
      {
        echo
        echo
        echo CONFIG
        echo
        sed 's/^# //' $config
      } >> $TMPDIR/.help
    ;;
  esac

  edit $TMPDIR/.help "$@"
}
