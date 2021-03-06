alias am=alsamixer
alias clear_gpg_agent='gpg-connect-agent reloadagent /bye'
C=connected;
alias displays="xrandr|grep '^[A-Z][^ ]\+ \+$C '|sed 's/ \+$C .*$//'"
unset C;
alias ds='du -sBM'
alias e='vim -O'
alias fm='fetchmail --mda "procmail -f %F" && inc'
alias g=git
alias gb=gprbuild
alias gc='gprclean -q'
alias gen_cov_html_cum_report='without_gnat_ce \
    && [ ${PWD##*/} == "src" ] \
    && rm -rf ../lcov_cum \
    && mkdir ../lcov_cum \
    && gprclean -q -r -P default.gpr -XOMPACC_BUILD_MODE=coverage \
    && gprbuild -p -P default.gpr -XOMPACC_BUILD_MODE=coverage \
    && lcov -c \
        -i -d ../gnat_build/src-coverage-obj/ \
        -o ../lcov_cum/cum_report_prerun.info \
        -t cum_$(basename $(readlink -f $(pwd)/..)) \
    && run-parts ../gnat_build/src-coverage-bin \
    && lcov -c \
        -d ../gnat_build/src-coverage-obj/ \
        -o ../lcov_cum/cum_report_postrun.info \
        -t cum_$(basename $(readlink -f $(pwd)/..)) \
    && lcov \
        -a ../lcov_cum/cum_report_prerun.info \
        -a ../lcov_cum/cum_report_postrun.info \
        -o ../lcov_cum/cum_report_full.info \
        -t cum_$(basename $(readlink -f $(pwd)/..)) \
    && lcov \
        -r ../lcov_cum/cum_report_full.info \
        '*/adainclude/*' '*/src-coverage-obj/*' \
        -o ../lcov_cum/cum_report.info \
        -t cum_$(basename $(readlink -f $(pwd)/..)) \
    && mkdir -p ../lcov_cum/html \
    && genhtml ../lcov_cum/cum_report.info -o ../lcov_cum/html \
        -t cum_$(basename $(readlink -f $(pwd)/..)) \
    && with_gnat_ce'
alias gen_cov_html_report='without_gnat_ce \
    && [ ${PWD##*/} == "src" ] \
    && rm -rf ../lcov \
    && mkdir ../lcov \
    && gprclean -q -r -P default.gpr -XOMPACC_BUILD_MODE=coverage \
    && gprbuild -p -P $(ls *_test.gpr) -XOMPACC_BUILD_MODE=coverage \
    && ../gnat_build/src-coverage-bin/harness \
    && lcov -c \
        -d ../gnat_build/src-coverage-obj/ -o ../lcov/report_full.info \
        -t $(basename $(readlink -f $(pwd)/..))_test \
    && lcov \
        -r ../lcov/report_full.info '*/adainclude/*' '*/src-coverage-obj/*' \
        -o ../lcov/report.info \
        -t $(basename $(readlink -f $(pwd)/..))_test \
    && mkdir -p ../lcov/html \
    && genhtml ../lcov/report.info -o ../lcov/html \
        -t $(basename $(readlink -f $(pwd)/..))_test \
    && with_gnat_ce'
alias ggrep='git grep --no-index'
alias gquit=gnome-session-quit
alias gstudio='gnatstudio -P default.gpr &'
alias guestinfo='sudo virsh list --all && sudo virsh net-dhcp-leases default'
alias ifp='sudo ifp'
alias list_installed_packages='dpkg-query -f '\''${binary:Package}\n'\'' -W'
alias lla='ls -la'
alias m=make
alias mute='amixer -q -c 0 sset Master playback mute'
alias nflow='wget -q -O - http://mafreebox.freebox.fr/pub/fbx_info.txt \
    | grep -a "^\s*WAN\|Ethernet\|USB\|Switch " \
    | grep -v " Non connect" \
    | sed -e "s/^\s*\([^ ]\+\) \+[^ ]\+ \+\([0-9.]\+ \)/\1 \2/" \
          -e "s/^WAN/WAN      in /" \
          -e "s/^Ethernet/Ethernet in /" \
          -e "s/^USB/USB      in /" \
          -e "s/^Switch/Switch   in /" \
          -e "s/\/s\( \+\)\([0-9]\)/\1out \2/"'
alias noise='aplay /usr/share/sounds/alsa/Noise.wav'
alias no_power_save='xset s off && xset -dpms'
alias oc='octave --quiet'
alias power_save='xset s on && xset +dpms'
alias spam='refile +Spam'
alias t=task
alias ta='task add pri:M'
alias tapp='task add pri:H +appointment'
alias tmks='tmux kill-server'
alias tv='vlc http://mafreebox.freebox.fr/freeboxtv/playlist.m3u &'
alias vi='vi -u NONE'
alias vim.tiny='vi -u NONE'
alias x=startx

config_clean_filters() {

    # Configure the clean filters for the Git repository. Nothing is done if
    # the current directory is not part of a Git repository and if any of the
    # following files is absent of the repository top level directory:
    # '.gitconfig', '.procmailrc' and '.bash_aliases'.
    #
    # 'git ls-files' is used to check the presence of the files (combined with
    # 'git rev-parse --show-toplevel').

    # Top level directory of the repository.
    local TOP=$(git rev-parse --show-toplevel 2>/dev/null);

    if [ -n "$TOP" ] \
            && [ $(git ls-files "$TOP"/.gitconfig|wc -l) == 1 ] \
            && [ $(git ls-files "$TOP"/.procmailrc|wc -l) == 1 ] \
            && [ $(git ls-files "$TOP"/.bash_aliases|wc -l) == 1 ]; then

        git config --local filter.hide_git_name_and_email.clean \
            'clean_filters/hide_git_name_and_email %f'
        git config --local filter.hide_mail_dir.clean \
            'clean_filters/hide_mail_dir %f'
        git config --local filter.hide_secret_dir.clean \
            'clean_filters/hide_secret_dir %f'

    else
        echo Not in a proper directory to do that 1>&2;
    fi;
}

find_sort_by_time() {

    # Invoke 'find' with all the arguments provided plus more arguments to show
    # the modification date of found items, and pipe the output to 'sort'.

    find $* -printf "%TY-%Tm-%Td %TH:%TM:%TS %p\n" | sort;
}

cpu() {

    # Show CPU Mhz (obtained via a 'lscpu|grep "^CPU MHz: "' command) and
    # individual core loads (obtained via the 'top' program).

    local REGEX="^CPU MHz: \+";
    lscpu|grep "$REGEX"|sed "s/$REGEX\([^\s]\+\)/Running at \1 MHz/";
    local REGEX="^%Cpu[0-9]\s*:";
    top -b -n1 -1|grep "$REGEX"|sed "s/$REGEX//"
}

display_positions() {

    # Issue a 'xrandr --auto' command followed by a
    # 'xrandr --output <first argument> --left-of <second argument>' command,
    # unless the first argument is "LVDS-1" or "DVI-1". In this case, the
    # second command is
    # 'xrandr --output <second argument> --right-of <first argument>'.

    xrandr --auto;

    if [ "$1" == "LVDS-1" ] || [ "$1" == "DVI-1" ]; then
        xrandr --output "$2" --right-of "$1";
    else
        xrandr --output "$1" --left-of "$2";
    fi;
}

ip_addr() {

    # IP address of local host.

    ip addr | grep "^\s*inet\s" | grep -v 127.0.0.1 \
        | sed "s/^\s*inet\s\+\(\([0-9]\+\.\)\{3\}[0-9]\+\).*/\1/";

}

host_name() {

    # Output the host name for the IP address provided as argument, based on
    # '/etc/hosts'. If no argument is provided or if the provided argument
    # equals the output of the 'ip_addr' function, then the output of command
    # 'hostname' is output.

    if [ $# -eq 0 ] || [ "$1" == "$(ip_addr)" ]; then

        hostname;

    else

        local L=$(grep "^\s*$1\s" /etc/hosts|tail -1);
        if [ -n "$L" ]; then
            echo "$L"|sed "s/^.\+\s\([^ ]\+\)\s*$/\1/";
        fi;

    fi;

}

nscan() {

    # Issue a 'sudo nmap -sP -n' command and filter the output (one line per
    # host, with IP address, latency (if available) and MAC address). The
    # target specification provided to nmap is "192.168.0.0/24" unless one or
    # more arguments are provided on the command line. In this case, the
    # command line argument(s) are provided to nmap as target specification(s).

    local TARGET=192.168.0.0/24;
    if [ $# -gt 0 ]; then
        TARGET="$1";
        shift;
    fi;

    # IP address of local host.
    local SELF_IP=$(ip_addr);

    local IP=;
    local OUTPUT_LINE=;
    while IFS= read -r LINE; do

        if [ "$(echo "$LINE"|grep -c \
                '^Nmap scan report for \([0-9]\+\.\)\{3\}[0-9]\+' \
                )" -gt 0 ]; then

            if [ -n "$OUTPUT_LINE" ]; then
                echo "$OUTPUT_LINE";
            fi;

            IP=$(echo "$LINE"|sed "s/^.\+ //");

        elif [ "$(echo "$LINE"|grep -c '^Host is up (')" -gt 0 ]; then

            OUTPUT_LINE=$(echo "$LINE"|sed "s/^.\+(/$IP, /"|sed "s/).\+$//");

        elif [ "$(echo "$LINE"|grep -c '^Host is up\.')" -gt 0 ]; then

            if [ "$IP" == "$SELF_IP" ]; then
                OUTPUT_LINE="$IP, local host";
            else
                OUTPUT_LINE=$(echo "$LINE" \
                    | sed "s/^.\+(/$IP, /"|sed "s/).\+$//" \
                    | sed "s/).*$//");
            fi;

        elif [ "$(echo "$LINE"|grep -c '^MAC Address: ')" -gt 0 ]; then

            OUTPUT_LINE="$OUTPUT_LINE, $LINE";

        fi;

    done < <(sudo nmap -sP -n $TARGET $*);

    echo "$OUTPUT_LINE";

}

data_dir() {
    echo ~/data;
}

snapshot_dir() {
    echo ~/snapshot;
}

timestamp() {

    # Output current UTC date in ISO 8601 format (except that the ":"
    # characters are substituted with "." characters).

    date -u -Iseconds|sed "s/+.\+$/Z/"|sed "s/:/./g";
}

freespace() {

    # Output a line indicating available space and percentage used on the drive
    # containing the directory or file provided as argument.

    local F=$(readlink -f "$1");
    echo $(df --output=avail -h "$F" | tail -n 1) available in "$F" \
        "($(df --output=pcent "$F" | tail -n 1|sed "s/^ *\(.\+\)/\1/") used)";
}

secret_tar() {

    # Archive (using tar) the directory provided as argument and pipe the
    # output to gpg for symmetric encryption. The original directory is then
    # destroyed.

    tar -cvf - "$1"|gpg -e > "${1%/}".tar.gpg \
        && find "$1" -type f -exec shred {} \; \
        && rm -rf "$1";
}

secret_untar() {

    # Decrypt (using 'gpg -d') the .tar.gpg file provided as argument and pipe
    # the output to tar for archive extraction.

    gpg -d "$1"|tar -xvf -;
}

secret() {

    # Handle "secret" directory. Exactly one argument required (the option).
    #
    # Option "-n": Output path to secret directory (which may exist or not).
    # Option "-a": Output path to secret directory archive (.tar file) (which
    #              does probably not exist, used as temporary file).
    # Option "-p": Output path to encrypted secret directory archive (.tar.gpg
    #              file).
    # Option "-e": Encrypt secret directory.
    # Option "-d": Decrypt secret directory (keeps encrypted file).

    local ERR_PREF="${FUNCNAME[0]}: ";
    local SECRET_DIR_PATH="$(data_dir)"/secret/directory; # Adapt to your needs.
    local SECRET_FILE_PATH="$SECRET_DIR_PATH".tar;
    local SECRET_GPG_PATH="$SECRET_FILE_PATH".gpg;
    local SECRET_PARENT="${SECRET_DIR_PATH%/*}";
    local ARG=true;
    local VALID_ARG=true;
    local EXAC="Exactly one argument required";
    local DONE="Done ";
    local ENCR="Encrypting";
    local DECR="Decrypting";

    [ $# -ne 1 ] && ARG=false;

    [ $ARG = true ] \
        && [ "$1" != "-n" ] \
        && [ "$1" != "-a" ] \
        && [ "$1" != "-p" ] \
        && [ "$1" != "-e" ] \
        && [ "$1" != "-d" ] \
        && VALID_ARG=false;

    [[ $ARG = "false" || $VALID_ARG = "false" ]] \
        && echo "${ERR_PREF}$EXAC:" \
            "\"-n\", \"-a\", \"-p\", \"-e\" or \"-d\"." 1>&2 \
        && return 1;

    case "$1" in
        -n)
            echo "$SECRET_DIR_PATH";
            ;;
        -a)
            echo "$SECRET_FILE_PATH";
            ;;
        -p)
            echo "$SECRET_GPG_PATH";
            ;;
        -e)
            [ ! -d "$SECRET_DIR_PATH" ] \
                && echo \
                    "${ERR_PREF}Directory $SECRET_DIR_PATH not found" 1>&2 \
                && return 1;
            echo "$ENCR"...;
            rm -f "$SECRET_GPG_PATH";
            [ -f "$SECRET_FILE_PATH" ] && shred -u "$SECRET_FILE_PATH";
            tar -C "$SECRET_PARENT" -cvf \
                "$SECRET_FILE_PATH" "${SECRET_DIR_PATH##*/}";
            gpg -e "$SECRET_FILE_PATH";
            shred -u "$SECRET_FILE_PATH";
            find "$SECRET_DIR_PATH" -type f -exec shred {} \;
            rm -rf "$SECRET_DIR_PATH";
            echo "$DONE$ENCR";
            ;;
        -d)
            [ -d "$SECRET_DIR_PATH" ] \
                && echo \
                    "${ERR_PREF}Directory $SECRET_DIR_PATH already exists" \
                        1>&2 \
                && return 1;
            [ ! -f "$SECRET_GPG_PATH" ] \
                && echo "${ERR_PREF}$SECRET_GPG_PATH not found" 1>&2 \
                && return 1;
            echo "$DECR"...;
            [ -f "$SECRET_FILE_PATH" ] && shred -u "$SECRET_FILE_PATH";
            gpg "$SECRET_GPG_PATH";
            tar -C "$SECRET_PARENT" -xvf "$SECRET_FILE_PATH";
            shred -u "$SECRET_FILE_PATH";
            echo "$DONE$DECR";
    esac;
}

secret_dump() {

    # Dump a file of encrypted secret directory archive. Exactly one argument
    # required (the path to the file in the archive, with some leading
    # directories possibly removed).

    [ $# -ne 1 ] \
        && echo "${ERR_PREF}Exactly one argument required." 1>&2 \
        && return 1;

    local STR=" found in secret directory archive.";
    local DECRYPT_CMD="gpg -d $(secret -p)";

    local FILE_MATCH_COUNT=$($DECRYPT_CMD 2>/dev/null \
        | tar -tf - | grep -c "\/$1$");

    [ "$FILE_MATCH_COUNT" -eq 0 ] \
        && echo "No matching file$STR" 1>&2 \
        && return 1;

    [ "$FILE_MATCH_COUNT" -gt 1 ] \
        && echo "Multiple matching files$STR" 1>&2 \
        && return 1;

    $DECRYPT_CMD 2>/dev/null | tar -xOf - \
        $($DECRYPT_CMD 2>/dev/null | tar -tf - | grep "\/$1$");
}

backup_dot_gnupg() {

    # Backup ~/.gnupg.

    local TARGET=~/data/office/gpg/gpg.tar.gpg;
    local TARGET_DIR=${TARGET%/*};
    local BACKUP_SUBDIR="$TARGET_DIR/backup_$(timestamp)";
    local TARGET_NAME=${TARGET%.tar.gpg};
    local SOURCE=~/.gnupg;
    local SOURCE_COPY_NAME=$(echo "$SOURCE" \
        |sed "s/^.\+\/\.\([^\/]\+\)$/dot_\1/");

    [ -f "$TARGET" ] \
        && mkdir "$BACKUP_SUBDIR" \
        && mv "$TARGET" "$BACKUP_SUBDIR";

    mkdir "$TARGET_NAME";
    cp -R ~/.gnupg "$TARGET_NAME/$SOURCE_COPY_NAME";

    gpg --armor --export --output "$TARGET_NAME"/pubkeys.asc
    gpg --armor --export-secret-keys --output "$TARGET_NAME"/privkeys.asc

    TARGET_NAME="${TARGET_NAME##*/}";
    tar -C "$TARGET_DIR" -cvf "$TARGET_DIR/$TARGET_NAME".tar "$TARGET_NAME";
    gpg -c "$TARGET_DIR/$TARGET_NAME".tar;
    shred -u "$TARGET_DIR/$TARGET_NAME".tar;
    find "$TARGET_DIR/$TARGET_NAME" -type f -exec shred {} \;
    rm -rf "$TARGET_DIR/$TARGET_NAME";
}

rsync_data_backup() {

    # Backup ~/data to /media/$USER/<target_name>/$USER (or restore
    # /media/$USER/<target_name>/$USER/data to ~ if option "--restore" is used)
    # using rsync.
    #
    # <target_name> must be provided as the last argument on the command line.
    #
    # There can be one or two optional arguments (options) before
    # <target_name>:
    # - "--dry-run": causes the "-n" option is used in the rsync command to
    #   make it a dry run.
    # - "--restore": Performs a restoration instead of a backup.
    #
    # The following assumptions are made:
    # - Possible values for <target_name> are "chil", "ikki", "mang", "mysa",
    #   "rama" and "thuu".
    # - In the case of the "chil" and "rama" tsarget, you want to exclude (that
    # is you don't want to backup) ~/data/image and ~/data/music (see the
    #   SPECIFIC_EXCLUDE local variable).
    # - For all targets, you want to exclude the item (directory or file)
    #   output by "secret -n" and the one output by "secret -a" (see the
    #   "--exclude" options in the rsync command and see the "secret" function
    #   above).
    # - Backup destination directory /media/$USER/<target_name>/$USER/data
    #   already exists.
    #
    # Note the --delete option in the rsync command: Files removed from ~/data
    # are removed in the backup.
    #
    # Note also that there is no trailing slash on the ~/data argument to the
    # rsync command. It implies the the "data" directory is recreated in
    # /media/$USER/<target_name>/$USER.
    # (see
    # qdosmsq.dunbar-it.co.uk/blog/2013/02/rsync-to-slash-or-not-to-slash).
    #
    # One last note to mention that the function creates or modifies a file
    # named rsync_data_backup_runs in ~/data (only if none of he options are
    # used). The modification is to append a line indicating the UTC date, the
    # hostname and the backup target.

    local ERR_PREF="${FUNCNAME[0]}: ";
    local U="$USER";
    local DUPL_OPT_ERR="Duplicated option";
    local DRYRUN_OPT=;
    local BACKUP=true;
    local TARGET=;
    local SPECIFIC_EXCLUDE=;
    local DEST_DIR=;
    local DEST=;
    local SOURCE=;
    local SN="$(secret -n)";
    local SA="$(secret -a)";
    local RSYNC=;
    local DATA_DIR="$(data_dir)";

    [ $# -eq 0 ] \
        && echo "${ERR_PREF}At least one argument required." 1>&2 \
        && return 1;

    while [[ "$1" != "" && "${1%%--*}" = "" ]]; do

        case "$1" in
            --dry-run)
                [ -n "$DRYRUN_OPT" ] \
                    && echo "${ERR_PREF}$DUPL_OPT_ERR: $1." 1>&2 \
                    && return 1;
                DRYRUN_OPT=-n;
                shift;
                ;;
            --restore)
                [ "$BACKUP" = "false" ] \
                    && echo "${ERR_PREF}$DUPL_OPT_ERR: $1." 1>&2 \
                    && return 1;
                BACKUP=false;
                shift;
                ;;
            *)
                echo "${ERR_PREF}Invalid option: $1." 1>&2 && return 1;
                ;;
        esac;

    done;

    [ $# -eq 0 ] \
        && echo "${ERR_PREF}Missing target name argument." 1>&2 \
        && return 1;

    [ $# -gt 1 ] \
        && echo "${ERR_PREF}Too many arguments." 1>&2 \
        && return 1;

    TARGET="$1";

    case "$TARGET" in
        ikki | mang | mysa | thuu)
            ;;
        chil | rama)
            SPECIFIC_EXCLUDE="--exclude=image --exclude=music";
            ;;
        *)
            echo "${ERR_PREF}Unknown target: $TARGET" 1>&2 \
                && return 1;
            ;;
    esac;

    RSYNC="rsync $DRYRUN_OPT -aAXv --delete $SPECIFIC_EXCLUDE";

    if [ "$BACKUP" = "false" ]; then

        SOURCE="/media/$U/$TARGET/$U/${DATA_DIR##*/}";
        $RSYNC "$SOURCE" ~;
        freespace ~;

    else

        DEST="/media/$U/$TARGET/$U";

        [ ! -d "$DEST" ] \
            && echo "${ERR_PREF}Destination directory not found: $DEST." 1>&2 \
            && return 1;

        if [ -z "$DRYRUN_OPT" ]; then
            echo $(timestamp) $(hostname) "->" "$TARGET" \
                >> "$DATA_DIR/"${FUNCNAME[0]}_runs;
        fi;

        $RSYNC \
            --exclude="${SN#"$DATA_DIR"/}" \
            --exclude="${SA#"$DATA_DIR"/}" \
            "$DATA_DIR" "$DEST";
        freespace "$DEST";

    fi;
}

rsync_snapshot() {

    # Copy the content of a directory provided as argument to a subdirectory of
    # the ~/snapshot directory using rsync. Providing no directory is
    # equivalent to providing the current working directory.
    #
    # For example, the content of directory ~/data/work/important_project would
    # be copied to a directory named like
    # ~/snapshot/2019-07-26T14.00.40Z_work__important_project (not the double
    # underscore between "work" and "important_project").
    #
    # An encrypted archive is also created
    # (~/snapshot/2019-07-26T14.00.40Z_work__important_project.tar.gpg).
    # Decrypt with
    # gpg ~/snapshot/2019-07-26T14.00.40Z_work__important_project.tar.gpg
    #
    # I you don't want the encrypted archive, add option "--no-gpg" as first
    # argument.
    #
    # You can also provide additional rsync options before the directory
    # argument (if any) and after the "--no-gpg" option (if any). Example:
    #
    # rsync_snapshot \
    #     --no-gpg --exclude=unwanted_subdir ~/data/work/important_project
    #
    # Note the function won't attempt the directory copy if that directory is
    # one of:
    # - ~/data
    # - ~/data/image
    # - ~/data/music
    # - The output of "secret -n" (see the "secret" function above)
    # - Any directory not in ~/data tree
    #
    # Note also that the directory and file as output by "secret -n" and
    # "secret -a" are ignored (i.e. not copied).

    local ERR_PREF="${FUNCNAME[0]}: ";
    local GPG_ARCHIVE=true;
    local DATA_DIR="$(data_dir)";
    local SNAP_DIR="$(snapshot_dir)";
    local DIR="$(pwd)";
    local DEST=;
    local DEST_TAR=;
    local SECRET_DIR_PATH="$(secret -n)"/secret/directory; # Adapt to your needs.
    local SECRET_FILE_PATH="$(secret -a)";
    local SECRET_DIR_REL_PATH=;
    local SECRET_FILE_REL_PATH=;
    local EXCL=;
    local WONTATTEMPT="Won't attempt to snapshot";
    local USER_RSYNC_OPT=;

    if [ "$1" = --no-gpg ]; then
        GPG_ARCHIVE=false;
        shift;
    fi;

    while [ $# -gt 0 ] && [ "$(echo "$1"|grep -c "^--")" -gt 0 ]; do
        USER_RSYNC_OPT="$USER_RSYNC_OPT $1";
        shift;
    done;

    [ $# -gt 1 ] \
        && echo "${ERR_PREF}Too many arguments." 1>&2 \
        && return 1;

    [ $# -gt 0 ] && DIR=$(readlink -f "$1");

    [[ "$DIR" = "$DATA_DIR" \
    || "$DIR" = "$SECRET_DIR_PATH" \
    || "$DIR" = "$DATA_DIR"/image \
    || "$DIR" = "$DATA_DIR"/music ]] \
        && echo "${ERR_PREF}$WONTATTEMPT $DIR" 1>&2 \
        && return 1;

    [ "${DIR#"$DATA_DIR"/}" = "$DIR" ] \
        && echo "${ERR_PREF}$WONTATTEMPT $DIR" \
            "(which is outside of $DATA_DIR)" 1>&2 \
        && return 1;

    [ ! -d "$DIR" ] \
        && echo "${ERR_PREF}Directory $DIR does not exist" 1>&2 \
        && return 1;

    DEST_DIR=$(timestamp)_"$(echo "${DIR#"$DATA_DIR"/}"|sed "s/\//__/g")";
    DEST="$SNAP_DIR/$DEST_DIR";

    SECRET_DIR_REL_PATH="${SECRET_DIR_PATH#"$DIR/"}";
    if [ "$SECRET_DIR_REL_PATH" != "$DIR" ]; then
        SECRET_FILE_REL_PATH="${SECRET_FILE_PATH#"$DIR/"}";
        EXCL="--exclude=$SECRET_DIR_REL_PATH --exclude=$SECRET_FILE_REL_PATH";
    fi;

    mkdir -p "$DEST";
    rsync -aAXv $EXCL $USER_RSYNC_OPT "$DIR"/ "$DEST";
    if [ "$GPG_ARCHIVE" != "false" ]; then
        DEST_TAR="$DEST_DIR".tar;
        tar -C "$SNAP_DIR" -cvf "$SNAP_DIR/$DEST_TAR" "$DEST_DIR";
        gpg -e "$SNAP_DIR/$DEST_TAR";
        rm "$SNAP_DIR/$DEST_TAR";
    fi;

    freespace "$SNAP_DIR";
}

rsync_host() {

    # Synchronize ~/data on host provided as argument.

    rsync -aAXv --delete $(data_dir)/ "$1":$(data_dir);
}

gcal_moon_sun() {

    # Writes ~/gcal Gcal resource file (if it does not already exist) and runs
    # gcal. Shows moon phase and rise / set times for moon and sun.

    local R=~/gcal;
    local COORD=+48.80+002.23
    # Meudon (France) observatory:
    # 48°48' North (equiv. to 48.80°)
    # 2°14' East (equiv. to 2.23°)
    # Altitude 162m

    [ ! -e "$R" ] \
        && cat << EOF > "$R"
0 Sunrise is at %o$COORD  (UTC)
0 Sunset is at %s$COORD  (UTC)
0 Moon phase %O
0 Moonrise is at %($COORD  (UTC)
0 Moonset is at %)$COORD  (UTC)
0 %Z
EOF

    gcal --resource-file="$R" -H no -ox;
}

net() {

    # Issue a "sudo systemctl <operation> networking" command, <operation>
    # being one of "stop", "start" and "restart". The first argument is used as
    # <operation>.

    local ERR_PREF="${FUNCNAME[0]}: ";

    case "$1" in
        stop | start | restart)
            ;;
        *)
            echo "${ERR_PREF}Unsupported operation: $1" 1>&2 \
                && return 1;
            ;;
    esac;

    sudo systemctl "$1" networking;

}

wif() {

    # Output the name of the wireless network interface if it's up.

    local ERR_PREF="${FUNCNAME[0]}: ";
    local MSG="No wireless interface up";

    local OUTPUT=$(/sbin/iwconfig 2>/dev/null \
        |grep -v "^\(\s\|$\)" \
        |grep -v "\sESSID:off/any\s*$" \
        |sed "s/\s.\+$//");

    [ -z "$OUTPUT" ] && echo "$ERR_PREF$MSG" 1>&2 && return 1;

    echo "$OUTPUT";

}

essid() {

    # Output the ESSID name of the wireless network if the wireless network
    # interface is up.

    local ERR_PREF="${FUNCNAME[0]}: ";
    local MSG="No wireless interface up";

    local OUTPUT=$(/sbin/iwconfig 2>/dev/null \
        |grep -v "^\(\s\|$\)" \
        |sed "s/\s*Nickname:\".\+$//" \
        |grep -v "\sESSID:off/any\s*$" \
        |sed 's/^.\+\sESSID:"\?//' \
        |sed 's/"\s*$//');

    [ -z "$OUTPUT" ] && echo "$ERR_PREF$MSG" 1>&2 && return 1;

    echo "$OUTPUT";

}

wlscan() {

    # Show the available wireless networks.

    local KEY_OFF_MARK="Encr. key off";
    local KEY_ON_MARK="             ";

    local ESSID_SEEN=false;
    local KEY_SEEN=false;
    local QUAL_SEEN=false;

    local ESSID;
    local KEY_MARK;
    local QUAL;

    while IFS= read -r LINE; do

        echo "$LINE"|grep -q "^\s*Cell [0-9]\+ - " \
                && ESSID_SEEN=false && KEY_SEEN=false && QUAL_SEEN=false;

        if [ "$(echo "$LINE"|grep -c '^\s*ESSID:\"[^\"]')" -gt 0 ]; then
            ESSID_SEEN=true;
            ESSID="$(echo "$LINE"|sed 's/\"$//'|sed 's/^.\+\"//')";
        fi;

        if [ "$(echo "$LINE"|grep -c '^\s*Encryption key:off')" -gt 0 ]; then
            KEY_SEEN=true;
            KEY_MARK="$KEY_OFF_MARK";
        fi;
        if [ "$(echo "$LINE"|grep -c '^\s*Encryption key:on')" -gt 0 ]; then
            KEY_SEEN=true;
            KEY_MARK="$KEY_ON_MARK";
        fi;

        if [ "$(echo "$LINE"|grep -c "^\s*Quality=")" -gt 0 ]; then
            QUAL_SEEN=true;
            QUAL=$(printf "%7s" \
                $(echo "$LINE"|sed "s/^.\+Quality=//"|sed "s/ .\+$//"));
        fi;

        if [[ "$ESSID_SEEN" = true \
                && "$KEY_SEEN" = true \
                && "$QUAL_SEEN" = true ]]; then

            echo "$QUAL" "$KEY_MARK" "$ESSID";

            ESSID_SEEN=false;
            KEY_SEEN=false;
            QUAL_SEEN=false;
        fi;

    done < <(sudo /sbin/iwlist "$(wif)" scan 2>/dev/null);

}

ak() {

    # Run akt (Ada Keystore) with the --passcmd option. The command passed via
    # the --passcmd option is a piped chain of commands involving
    # gpg-connect-agent. The point is to benefit from the gpg-agent passphrase
    # caching system.
    #
    # The first argument must be an akt command ("list", "store", "extract",
    # "edit", ...). The only command not allowed here is "create".
    #
    # The second argument must be the (relative or absolute) path to a
    # keystore.
    #
    # The other arguments are passed to akt as well.

    local ERR_PREF="${FUNCNAME[0]}: ";

    [ $# -lt 2 ] \
        && echo "${ERR_PREF}At least two arguments required" \
                "(keystore path and command)." 1>&2 \
        && return 1;

    [ "$1" = "create" ] \
        && echo "${ERR_PREF}\"create\" command not allowed here" \
                "(use \"akt create ...\" directly)." 1>&2 \
        && return 1;

    local AKT_COMMAND="$1";
    local KEYSTORE=$(readlink -f "$2");
    shift; shift;

    local G_C_A=gpg-connect-agent;
    local G_P_P_D="GET_PASSPHRASE --data";
    local ID="AKT+keystore+password+($KEYSTORE)";
    local ERR=X;
    local PROMPT=Password
    local DESCR="Please+enter+keystore+password+($KEYSTORE)";
    local ECHO_G_C_A_INPUT="echo \"$G_P_P_D $ID $ERR $PROMPT $DESCR\"";

    export GPG_TTY=$(tty);
    akt "$AKT_COMMAND" "$KEYSTORE" --passcmd \
        "$ECHO_G_C_A_INPUT|$G_C_A|head -1|sed \"s/^D //\"|tr -d \"\n\"" $@;

}

vpn() {

    # Connect to a VPN using OpenConnect. First argument is mandatory and is
    # the VPN server URL. Second argument is optional and is the VPN protocol
    # (defaults to "gp" (means "Palo Alto Networks GlobalProtect")).

    local VPN_SERVER="$1";
    local VPN_PROTOCOL="${2:-gp}";

    sudo openconnect "$VPN_SERVER";
    sudo openconnect --protocol="$VPN_PROTOCOL" "$VPN_SERVER";
}

rdp() {

    # Launch 'xfreerdp'. First argument is the user name. Second argument is
    # the remote machine URL.

    xfreerdp +glyph-cache /relax-order-checks /u:"$1" /v:"$2" /kbd:0x40c /f;
}

without_gnat_ce() {

    # Remove GNAT Community Edition from the path.

    PATH=$(echo "$PATH" \
        | sed "s/\(.*:\|^\)\(\/opt\/GNAT\/2[0-9]\{3\}\/bin\)\($\|:.*\)/\1\3/" \
        | sed "s/^://" \
        | sed "s/::/:/" \
        | sed "s/:$//");
}

latest_installed_gnat_ce() {

    # Echoes the version of the latest installed GNAT Community Edition.

    find /opt/GNAT/ -mindepth 1 -maxdepth 1 -type d -regextype posix-extended \
        -regex "^\/opt\/GNAT\/2[0-9]{3}$" \
        -exec find {}/bin -mindepth 1 -maxdepth 1 \
        -type f -executable -name gnat \; 2>/dev/null \
        | sed "s/^.*\/\(2[0-9]\{3\}\).*/\1/" \
        | sort \
        | tail -1;
}

with_gnat_ce() {

    # Add GNAT Community Edition to the path. The desired version can be
    # provided as an argument (e.g. "2021"). If no argument is provided, then
    # the latest version is selected (detected using function
    # 'latest_installed_gnat_ce'). If GNAT Community Edition is already in the
    # path, is removed (using function 'without_gnat_ce') before being added
    # again.

    local LATEST_VERSION=$(latest_installed_gnat_ce);

    if [ -z "$LATEST_VERSION" ]; then
        echo "No GNAT Community Edition installation found" 1>&2;
        return 1;
    fi;

    local VERSION="${1:-$LATEST_VERSION}";

    local GNAT_PATH=/opt/GNAT/"$VERSION"/bin/gnat;
    if [ -x "$GNAT_PATH" ]; then
        without_gnat_ce;
        PATH="${GNAT_PATH%/*}":"$PATH"
    else
        echo "$GNAT_PATH does not exist or is not an executable" 1>&2;
        return 1;
    fi;
}
