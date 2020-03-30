print_help_() {
  print_help > $TMPDIR/.help
  case "$language" in
    en|"")
      {
        echo
        echo
        cat $TMPDIR/.config-help
      } >> $TMPDIR/.help
    ;;
  esac
  edit $TMPDIR/.help
  rm $TMPDIR/.help
}
