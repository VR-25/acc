set_ch_curr() {

  ${verbose:-true} || {
    execDir=/data/adb/acc
    exxit() { exit $?; }
    . $execDir/misc-functions.sh
    cd $execDir
  }

  # check support
  grep -q ::v $TMPDIR/ch-curr-ctrl-files || {
    if ${verbose:-true} && not_charging; then
      print_read_curr
      print_wait_plug
      (while not_charging; do sleep 1; set +x; done)
      echo
      . $execDir/read-ch-curr-ctrl-files-p2.sh
      grep -q ::v $TMPDIR/ch-curr-ctrl-files || {
        print_no_ctrl_file
        return 1
      }
    else
      . $execDir/read-ch-curr-ctrl-files-p2.sh
      grep -q ::v $TMPDIR/ch-curr-ctrl-files || {
        ! ${verbose:-true} || print_no_ctrl_file
        return 1
      }
    fi
  }

  if [ -n "${1-}" ]; then

    # restore
    if [ $1 = - ]; then
      apply_on_plug default
      max_charging_current=
      ! ${verbose:-true} || print_curr_restored

    else

      apply_current() {
        eval "maxChargingCurrent=($1 $(sed "s|::v|::$1|" $TMPDIR/ch-curr-ctrl-files))" \
          && unset max_charging_current mcc \
          && apply_on_plug \
          && {
            noEcho=true
            ! ${verbose:-true} || print_curr_set $1
          } || return 1
      }

      # [0-9999] milliamps range
      if [ $1 -ge 0 -a $1 -le 9999 ]; then
        apply_current $1 || return 1
      else
        ! ${verbose:-true} || echo "(!) [0-9999]$(print_mA; print_only)"
        return 11
      fi
    fi

  else
    # print current value
    ! ${verbose:-true} && echo ${maxChargingCurrent[0]-} \
      || echo "${maxChargingCurrent[0]:-$(print_default)}$(print_mA)"
    return 0
  fi
}
