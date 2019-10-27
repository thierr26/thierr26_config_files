alias ds='du -sBM'
alias e='vi -O'
alias ggrep='git grep --no-index'
alias la='ls $LS_OPTIONS -a'
alias lla='ls $LS_OPTIONS -la'

disk_health() {

    # Attempt a "smartctl -H" command on every device (not partitions) listed
    # by lsblk and show the results. Also show if "smartctl -c" does not report
    # that selt-test is supported.

    for DEV in $(lsblk|grep "\s\+\<disk\>"|sed "s/\s.\+$//"); do

        RSLT=$(smartctl -H "/dev/$DEV" | \
            grep "result:\s\+" | \
            sed "s/^.\+:/\/dev\/$DEV:/");

        if [ -n "$RSLT" ]; then

            C_G_S_T_S=$(smartctl -c "/dev/$DEV" | \
                grep "Self-test supported");

            if [ -z "$C_G_S_T_S" ]; then
                RSLT="$RSLT (self-test NOT supported)"
            fi;

            echo "$RSLT";

        else
            echo "/dev/$DEV: No SMART support";
        fi;

    done

}
