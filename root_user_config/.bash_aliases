alias ds='du -sBM'
alias e='vi -O'
alias ggrep='git grep --no-index'
alias la='ls $LS_OPTIONS -a'
alias lla='ls $LS_OPTIONS -la'
alias nscan='nmap -sP -n 192.168.0.0/24'
alias sysupgrade='apt-get update && apt-get dist-upgrade'

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

update_fw_for_sysupgrade() {

    # Allow outgoing http and https requests to some specific servers, used on
    # system updates.

    # Allow outgoing DNS queries.
    nft add rule inet firewall fw_out tcp dport 53 accept
    nft add rule inet firewall fw_out udp dport 53 accept

    # Create a set named "debian_sources" in table "firewall" that can store
    # multiple individual IPv4 addresses.
    nft add set inet firewall debian_sources { type ipv4_addr \; }

    # Add elements to "debian_sources" set.
    nft add element inet firewall debian_sources \
        { "a.debian.repo", \
          "debian.security.org", \
          "dl.google.com", \
          "debian.map.fastlydns.net" }

    # Allow outgoing http and https queries to the addresses in the set.
    nft add rule inet firewall fw_out \
        ip daddr @debian_sources tcp dport http accept
    nft add rule inet firewall fw_out \
        ip daddr @debian_sources tcp dport https accept

}

echo_nft_handle() {

    # Runs a 'nft -a' command, piped to grep (twice), piped to sed. The first
    # piping to grep is to keep only lines containing a handle. The first
    # argument is used as the regular expression provided to grep (in the
    # second piping). The other arguments are provided as arguments to the
    # 'nft -a' command. sed is used to eliminate all but the tail handle
    # number.

    REG_EXPR="$1";
    shift;

    nft -a $* \
        | grep " # handle [0-9]\+$" \
        | grep "$REG_EXPR" \
        | sed "s/^.\+\s\([0-9]\+\)$/\1/";

}

restore_fw_after_sysupgrade() {

    # Revert the changes made by 'update_fw_for_sysupgrade'.

    nft delete rule inet firewall fw_out handle \
        $(echo_nft_handle \
            "\stcp dport 443 accept " list chain inet firewall \
            fw_out);
    nft delete rule inet firewall fw_out handle \
        $(echo_nft_handle \
            "\stcp dport 80 accept " list chain inet firewall \
            fw_out);

    nft delete set inet firewall debian_sources;

    nft delete rule inet firewall fw_out handle \
        $(echo_nft_handle \
            "\stcp dport 53 accept " list chain inet firewall \
            fw_out);
    nft delete rule inet firewall fw_out handle \
        $(echo_nft_handle \
            "\sudp dport 53 accept " list chain inet firewall \
            fw_out);

}
