alias am=alsamixer
alias clear_gpg_agent='gpg-connect-agent reloadagent /bye'
alias ds='du -sBM'
alias e='vim -O'
alias fm='fetchmail --mda "procmail -f %F" && inc'
alias g=git
alias gb=gprbuild
alias gc='gprclean -q'
alias gen_cov_html_cum_report='with_gnat_ce 2018; \
    [ ${PWD##*/} == "src" ] \
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
        -t cum_$(basename $(readlink -f $(pwd)/..)); \
    with_gnat_ce'
alias gen_cov_html_report='with_gnat_ce 2018; \
    [ ${PWD##*/} == "src" ] \
    && rm -rf ../lcov \
    && mkdir ../lcov \
    && gprclean -q -r -P default.gpr -XOMPACC_BUILD_MODE=coverage \
    && gprbuild -p -P $(ls *_test.gpr) -XOMPACC_BUILD_MODE=coverage \
    -XOMPACC_CONF_PRAGMA_FILE= \
    && $(find ../gnat_build/src-coverage-bin -name "*_test" | head -1) \
    && lcov -c \
        -d ../gnat_build/src-coverage-obj/ -o ../lcov/report_full.info \
        -t $(basename $(readlink -f $(pwd)/..))_test \
    && lcov \
        -r ../lcov/report_full.info '*/adainclude/*' '*/src-coverage-obj/*' \
        -o ../lcov/report.info \
        -t $(basename $(readlink -f $(pwd)/..))_test \
    && mkdir -p ../lcov/html \
    && genhtml ../lcov/report.info -o ../lcov/html \
        -t $(basename $(readlink -f $(pwd)/..))_test; \
    with_gnat_ce'
alias ggrep='git grep --no-index'
alias gquit=gnome-session-quit
alias gstudio='~/local/GNAT_Studio-x86_64.AppImage -P default.gpr &'
alias guestinfo='sudo virsh list --all && sudo virsh net-dhcp-leases default'
alias list_installed_packages='dpkg-query -f '\''${binary:Package}\n'\'' -W'
alias lla='ls -la'
alias locate='locate -d ~/.locatedb'
alias m=make
alias mute='amixer -q -c 0 sset Master playback mute'
alias nscan='sudo nmap -sP -n 192.168.0.0/23'
alias noise='aplay /usr/share/sounds/alsa/Noise.wav'
alias no_power_save='xset s off && xset -dpms'
alias oc='octave --quiet'
alias power_save='xset s on && xset +dpms'
alias spam='refile +Spam'
alias t=task
alias ta='task add pri:M'
alias tapp='task add pri:H +appointment'
alias tv='vlc http://mafreebox.freebox.fr/freeboxtv/playlist.m3u &'
alias updatedb='updatedb --output=/home/$USER/.locatedb 2>/dev/null'
alias vi='vi -u NONE'
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
        git config --local filter.hide_remote_addresses.clean \
            'clean_filters/hide_remote_addresses %f'
        git config --local filter.hide_debian_repo.clean \
            'clean_filters/hide_debian_repo %f'

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
    local REGEX="%Cpu[0-9]\+\s*:";
    top -b -n1 -1 -w 512 \
        | sed "s/\(\s\+$REGEX\)/\n\1/" \
        | grep "^\s*$REGEX" \
        | sed "s/^\s*$REGEX//";
}

displays() {

    # Show connected displays. One of the displays should be marked as
    # "primary" (here "primary" means "the display which is connected when
    # using the machine in a single monitor setup"). If none or more than one
    # are marked as primary then the code of the present function needs an
    # update.

    xrandr --verbose \
        | grep -e '^[A-Za-z][^ ]* \+connected ' -e Brightness -e Gamma \
        | sed 's/ \+connected .*$//' \
        | sed 's/^\(DVI-0\|eDP-1\|LVDS-1\)/\1 (primary)/';
}

primary_display() {

    # Show primary display. Relies on function 'displays'. See comment in
    # function 'displays'.

    displays | grep " (primary)$" | sed "s/ (primary)$//";
}

display_positions() {

    # Issue a 'xrandr --auto' command followed by a
    # 'xrandr --output <first argument> --left-of <second argument>' command,
    # unless the first argument is "eDP-1", "LVDS-1" or "DVI-0". In this case,
    # the second command is
    # 'xrandr --output <second argument> --right-of <first argument>'.

    xrandr --auto;

    if [ "$1" == "eDP-1" ] || [ "$1" == "LVDS-1" ] || [ "$1" == "DVI-0" ]; then
        xrandr --output "$2" --right-of "$1";
    else
        xrandr --output "$1" --left-of "$2";
    fi;
}

brightness() {

    # Set display brightness. The last argument must be the brightness value
    # (e.g. 0.9). There can be an other argument before the brightness value
    # that is the display name (as shown by function 'displays'). If no display
    # name is provided, then the name of the primary display is used. Relies on
    # functions 'displays' and 'primary_display'. See comment in function
    # 'displays'.

    local DISPL=;
    local VALUE=;

    if [ $# -lt 2 ]; then
        DISPL="$(primary_display)";
        VALUE="$1";
    else
        DISPL="$1";
        VALUE="$2";
    fi;

    xrandr --output "$DISPL" --brightness "$VALUE";
}

gamma() {

    # Set display gamma. The last argument must be the gamma value
    # (e.g. 0.9:0.8:0.7). There can be an other argument before the gamma value
    # that is the display name (as shown by function 'displays'). If no display
    # name is provided, then the name of the primary display is used. Relies on
    # functions 'displays' and 'primary_display'. See comment in function
    # 'displays'.

    local DISPL=;
    local VALUE=;

    if [ $# -lt 2 ]; then
        DISPL="$(primary_display)";
        VALUE="$1";
    else
        DISPL="$1";
        VALUE="$2";
    fi;

    xrandr --output "$DISPL" --gamma "$VALUE";
}

last_subdir() {
    find "$1" -maxdepth 1 -mindepth 1 -type d | sort | tail -1;
}

data_dir() {
    echo ~/data;
}

image_data_subdir() {
    echo image;
}

music_data_subdir() {
    echo music;
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

    local PROCESSED_ARG="${1:-$(pwd)}";
    local F=$(readlink -f "$PROCESSED_ARG");
    local H=$(hostname);
    echo $(df --output=avail -h "$F" | tail -n 1) available in "$F" on "$H" \
        "($(df --output=pcent "$F" | tail -n 1|sed "s/^ *\(.\+\)/\1/") used)";
}

tar_gpg() {

    # Generate an encrypted archive (.tar.gpg file) for the file or directory
    # provided as argument.

    tar -cvf - "$1"|gpg -e > "$1".tar.gpg;
}

gpg_untar() {

    # Decrypt and extract the encrypted archive (.tar.gpg file) provided as
    # argument.

    gpg -d "$1"|tar -xvf -;
}

secret() {

    # Crypt and decrypt the items in the "secret" directory.
    #
    # The first argument must be one of the following:
    #
    # - '-s': Shows unencrypted items, if any. Always exits with exit status 0.
    #         This is the default option.
    # - '-c': Similar to '-s' but exits with exit status 1 if there are
    #         unencrypted items.
    # - '-e': Archives and encrypts an item (results in a .tar.gpg file).
    # - '-d': Decrypts and extracts en item (the .tar.gpg file is not deleted).
    # - '-p': Dumps one file of an encrypted element.
    # - '-n': Shows the path to the "secret" directory.
    #
    # '-e' and '-d' requires the item name (without any leading directory path
    #  and without any extension) to be provided as second argument.
    #
    # '-p' requires one more argument: the name of the file to be dumped
    # (without any leading directory path).

    local ERR_PREF="${FUNCNAME[0]}: ";
    local SECRET_DIR_PATH="$(data_dir)"/secret/directory; # Adapt to your needs.
    local PROCESSED_ARG_1="${1:--s}";
    local VALID_ARG_1=true;
    local ITEM=item;
    local WARNING=Warning;
    local ERROR=Error;
    local EAT="exists as an unencrypted .tar archive";
    local EAF="exists as an unencrypted file or directory";
    local ISA="Invalid second argument";
    local NMF=" (no matching file)";
    local MMF=" (multiple matching files)";

    [ "$PROCESSED_ARG_1" != "-s" ] \
        && [ "$PROCESSED_ARG_1" != "-c" ] \
        && [ "$PROCESSED_ARG_1" != "-e" ] \
        && [ "$PROCESSED_ARG_1" != "-d" ] \
        && [ "$PROCESSED_ARG_1" != "-p" ] \
        && [ "$PROCESSED_ARG_1" != "-n" ] \
        && VALID_ARG_1=false;

    [ "$VALID_ARG_1" == false ] \
        && echo "${ERR_PREF}Valid options are:" \
            "\"-s\", \"-c\", \"-e\", \"-d\", \"-p\" or \"-n\"." 1>&2 \
        && return 1;

    shift;

    local FIND_OUTPUT=$(find "$SECRET_DIR_PATH" -maxdepth 1 -mindepth 1);

    local ITEM_LIST=$(echo "$FIND_OUTPUT" \
        | (while IFS= read -r LINE; do \
               echo "$LINE" \
                   | sed -e "s/\.tar.gpg$//" \
                   | sed -e "s/\.tar$//"; \
           done) | sort -u);

    local OUTPUT_LINE=;
    local N=0;

    local WI="$WARNING: $ITEM";
    local EXIT_STATUS=0;

    local ITEM_ARG_OK=false;

    local FILE_MATCH_COUNT=0;

    local WD=$(pwd);

    case "$PROCESSED_ARG_1" in

        -s|-c)

            [ $# -gt 0 ] && echo "${ERR_PREF}Too many arguments." 1>&2 \
                && return 1;

            if [ "$PROCESSED_ARG_1" == -c ]; then
                WI="$ERROR: $ITEM";
                EXIT_STATUS=1;
            fi;

            for ITEM in $ITEM_LIST; do

                OUTPUT_LINE=$(echo "$FIND_OUTPUT" \
                    | grep "$ITEM.tar$" \
                    | sed "s/^.\+\/\(.\+\)\.tar$/$WI \"\1\" $EAT./");

                [ -n "$OUTPUT_LINE" ] && N=$(($N + 1)) && echo "$OUTPUT_LINE";

                OUTPUT_LINE=$(echo "$FIND_OUTPUT" \
                    | grep "$ITEM$" \
                    | sed "s/^.\+\/\(.\+\)$/$WI \"\1\" $EAF./");

                [ -n "$OUTPUT_LINE" ] && N=$(($N + 1)) && echo "$OUTPUT_LINE";

            done;

            if [ $N -gt 0 ]; then
                return $EXIT_STATUS;
            fi;

            ;;

        -e|-d)

            [ $# -eq 0 ] && echo "${ERR_PREF}Missing argument." 1>&2 \
                && return 1;

            [ $# -gt 1 ] && echo "${ERR_PREF}Too many arguments." 1>&2 \
                && return 1;

            for ITEM in $ITEM_LIST; do
                [ "${ITEM##*/}" == "$1" ] && ITEM_ARG_OK=true && break;
            done;

            [ "$ITEM_ARG_OK" == false ] \
                && echo "${ERR_PREF}Invalid last argument." 1>&2 \
                && return 1;

            cd "$SECRET_DIR_PATH";

            if [ "$PROCESSED_ARG_1" == -e ]; then

                tar_gpg "$1" \
                    && find "$1" -type f -exec shred {} \; && rm -rf "$1";

            else

                 gpg_untar "$1.tar.gpg";

            fi;

            cd "$WD";

            ;;

        -p)

            [ $# -eq 0 ] && echo "${ERR_PREF}Missing arguments." 1>&2 \
                && return 1;

            [ $# -eq 1 ] && echo "${ERR_PREF}Missing argument." 1>&2 \
                && return 1;

            [ $# -gt 2 ] && echo "${ERR_PREF}Too many arguments." 1>&2 \
                && return 1;

            for ITEM in $ITEM_LIST; do
                [ "${ITEM##*/}" == "$1" ] && ITEM_ARG_OK=true && break;
            done;

            [ "$ITEM_ARG_OK" == false ] && echo "${ERR_PREF}$ISA." 1>&2 \
                && return 1;

            cd "$SECRET_DIR_PATH";

            FILE_MATCH_COUNT=$(gpg -d "$1.tar.gpg" 2>/dev/null \
                | tar -tf - | grep -c "\/$2$");

            [ "$FILE_MATCH_COUNT" -eq 0 ] && echo "${ERR_PREF}$ISA$NMF." 1>&2 \
                && return 1;

            [ "$FILE_MATCH_COUNT" -gt 1 ] && echo "${ERR_PREF}$ISA$MMF." 1>&2 \
                && return 1;

            gpg -d "$1.tar.gpg" 2>/dev/null \
                | tar -xOf - $(gpg -d "$1.tar.gpg" 2>/dev/null | tar -tf - \
                | grep "\/$2$");

            cd "$WD";

            ;;

        -n)

            [ $# -gt 0 ] && echo "${ERR_PREF}Too many arguments." 1>&2 \
                && return 1;

            echo "$SECRET_DIR_PATH";

            ;;

    esac;
}

backup_dot_gnupg() {

    # Backup ~/.gnupg to ~/data/office/gpg as an encrypted archive
    # (gpg.tar.gpg). If gpg.tar.gpg already exists, move it to a subdirectory
    # of ~/data/office/gpg named "backup_" plus a timestamp.

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

media() {

    # When used with a single argument, output the argument appended to
    # /media/"$USER" and exit with status 0. The argument is supposed to be a
    # simple name (i.e. a name without any directory separator). In the
    # opposite case, exit with non-zero status.
    #
    # When used with two arguments ('-c' plus a name), does the same except
    # that exit status is non-zero if the output does not designates an
    # existing directory.

    local ERR_PREF="${FUNCNAME[0]}: ";
    local DO_CHECK=false;
    local MA="Missing argument";
    local IA="Invalid argument";

    [ $# -eq 0 ] && echo "${ERR_PREF}$MA." 1>&2 && return 1;

    if [ "$1" == "-c" ]; then
        DO_CHECK=true;
        shift;
    fi;

    [ $# -eq 0 ] && echo "${ERR_PREF}$MA." 1>&2 && return 1;

    [ "${1##/*}" != "$1" ] && echo "${ERR_PREF}$IA." 1>&2 && return 1;

    local MEDIA_ROOT=/media/"$USER";
    local MEDIA_PATH=$(readlink -f "$MEDIA_ROOT"/"$1");

    [ "$MEDIA_PATH" == "" ] && echo "${ERR_PREF}$IA." 1>&2 && return 1;

    [ "$MEDIA_PATH" == "$MEDIA_ROOT" ] && echo "${ERR_PREF}$IA." 1>&2 \
        && return 1;

    [ "${MEDIA_PATH#$MEDIA_ROOT}" == "$MEDIA_PATH" ] \
        && echo "${ERR_PREF}$IA." 1>&2 \
        && return 1;

    echo "$MEDIA_PATH";
    if [ $DO_CHECK == true ]; then
        [ -d "$MEDIA_PATH" ];
    fi;
}

rsync_data() {

    # Issue an 'rsync' command. The command is elaborated based on the first
    # argument (the "target") and the options following it.
    #
    # In all cases, if option '-n' is provided then option '-n' ("dry run") is used in the
    # 'rsync' command.
    #
    # The other allowed option (though not in all cases, depending on the
    # target) is '--restore'.
    #
    # If the target name terminates with a colon then it is considered to be a
    # remote destination (like in a 'scp' command, possibly including a user
    # specification). The issued 'rsync' command synchronizes the ~/data
    # directory on the target with the data directory on the local host (or the
    # other way round if option '--restore' is provided).
    #
    # If the target name is such that it causes 'media -c' to exit with exit
    # status zero then the issued 'rsync' command synchronizes the data
    # subdirectory of the 'media' output the ~/data directory on the local host
    # (or the other way round if option '--restore' is provided). A line is
    # added to file ~/data/rsync_data_runs before the synchronisation to keep
    # track of this synchronization.
    #
    # Otherwise if the target is an existing directory then the 'rsync' command
    # copies the content of the directory to a subdirectory of
    # the ~/snapshot directory. For example, if the target is
    # ~/data/work/important_project then the ~/snapshot subdirectory is like
    # ~/snapshot/2019-07-26T14.00.40Z_work__important_project (note the double
    # underscore between "work" and "important_project"). Note the function
    # won't attempt the directory copy if the target is one of:
    # - ~/data,
    # - ~/data/image,
    # - ~/data/music,
    # - Any directory not in ~/data tree.
    #
    # A 'secret -c' command is issued before issuing the 'rsync' command if the
    # synchronized directory tree contains the "secret" directory (see function
    # 'secret'). A non-zero exit of 'secret -c' causes the function to return
    # immediately.
    #
    # After issuing the 'rsync' command, function 'freespace' is called on the
    # synchronization destination.

    local ERR_PREF="${FUNCNAME[0]}: ";
    local DATA_DIR="$(data_dir)";
    local DATA_DIR_LINK="$(readlink -f "$DATA_DIR")";
    local SECRET_LINK="$(readlink -f "$(secret -n)")";
    local SECRET_CHECK_REQUIRED=true;
    local SPECIFIC_EXCLUDE=;
    local SOURCE=;
    local DEST=;
    local TARGET;
    local HOST_TARGET=;
    local MEDIA_TARGET=;
    local SNAPSHOT_TARGET=;
    local DRY_RUN_OPT=;
    local RESTORE_OPT=;
    local OII="option is invalid";
    local S=snapshot;

    [ $# -eq 0 ] && echo "${ERR_PREF}Missing argument." 1>&2 && return 1;

    [ "$1" != "${1%:}" ] && HOST_TARGET="$1";

    if [ -z "$HOST_TARGET" ]; then

        MEDIA_TARGET="$(media -c "$1" 2>/dev/null)";

        [ $? -ne 0 ] && MEDIA_TARGET=;

    fi;

    if [[ -z "$HOST_TARGET" && -z "$MEDIA_TARGET" ]]; then

        SNAPSHOT_TARGET="$(readlink -f "$1")";

        [ ! -d "$SNAPSHOT_TARGET" ] && SNAPSHOT_TARGET=;

        [ "${SNAPSHOT_TARGET#$DATA_DIR_LINK/}" == "$SNAPSHOT_TARGET" ] \
            && SNAPSHOT_TARGET=;
        [ "$SNAPSHOT_TARGET" == "$DATA_DIR_LINK" ] && SNAPSHOT_TARGET=;
        [ "$SNAPSHOT_TARGET" == "$DATA_DIR_LINK/$(image_data_subdir)" ] \
            && SNAPSHOT_TARGET=;
        [ "$SNAPSHOT_TARGET" == "$DATA_DIR_LINK/$(music_data_subdir)" ] \
            && SNAPSHOT_TARGET=;

        [ "${SECRET_LINK/#$SNAPSHOT_TARGET/}" == "$SECRET_LINK" ] \
            && [ "${SNAPSHOT_TARGET/#$SECRET_LINK/}" == "$SNAPSHOT_TARGET" ] \
            && SECRET_CHECK_REQUIRED=false;

    fi;

    [ -z "$HOST_TARGET" ] && [ -z "$MEDIA_TARGET" ] \
        && [ -z "$SNAPSHOT_TARGET" ] \
        && echo "${ERR_PREF}Can't do anything." 1>&2 && return 1;

    if [ $SECRET_CHECK_REQUIRED == true ]; then
        echo Checking $(secret -n) ...
        secret -c;
        [ $? != 0 ] && return 1;
    fi

    local DELETE_OPT=;

    if [ -n "$HOST_TARGET" ]; then

        SOURCE="$DATA_DIR";
        DEST="$HOST_TARGET";
        DELETE_OPT=--delete;

    elif [ -n "$MEDIA_TARGET" ]; then

        SOURCE="$DATA_DIR";
        DEST="$MEDIA_TARGET"/"$USER";
        DELETE_OPT=--delete;

        [ "$1" == "chee" ] && SPECIFIC_EXCLUDE=\
"--exclude=$(image_data_subdir) --exclude=$(music_data_subdir)";

    else

        SOURCE="$SNAPSHOT_TARGET"/;
        mkdir -p "$(snapshot_dir)";
        DEST="$(snapshot_dir)"/$(timestamp)_;
        DEST="$DEST$(echo "${SNAPSHOT_TARGET#"$DATA_DIR"/}" \
            | sed "s/\//__/g")";

    fi;

    TARGET="$1";

    shift;

    while [ -n "$1" ]; do

        case "$1" in

            -n)

                DRY_RUN_OPT=-n;

                ;;

            --restore)

                if [ -n "$MEDIA_TARGET" ]; then
                    :
                elif [ -n "$HOST_TARGET" ]; then
                    :
                else
                    echo "${ERR_PREF}--restore $OII for $S targets." 1>&2 \
                        && return 1;
                fi;
                RESTORE_OPT=enabled;

                ;;

            *)

                echo "${ERR_PREF}Invalid option: $1." 1>&2 && return 1;

                ;;

        esac;

        shift;

    done;

    [ -n "$MEDIA_TARGET" ] && [ -z "$RESTORE_OPT" ] && [ -z "$DRY_RUN_OPT" ] \
        && echo $(timestamp) "$(hostname)" "->" "$TARGET" \
        >> "$DATA_DIR/"${FUNCNAME[0]}_runs;

    if [ -n "$RESTORE_OPT" ]; then
        if [ -z "$HOST_TARGET" ]; then
            SOURCE="$DEST/${DATA_DIR##*/}";
        else
            SOURCE="$DEST${DATA_DIR##*/}";
        fi;
        DEST="${DATA_DIR%/*}";
        SPECIFIC_EXCLUDE=;
    fi;

    rsync $DRY_RUN_OPT -aAXv $DELETE_OPT $SPECIFIC_EXCLUDE "$SOURCE" "$DEST";

    [ -z "$HOST_TARGET" ] && [ -z "$DRY_RUN_OPT" ] && freespace "$DEST";

    [ -n "$HOST_TARGET" ] && [ -z "$DRY_RUN_OPT" ] && [ -n "$RESTORE_OPT" ] \
        && freespace "$DEST";

    [ -n "$HOST_TARGET" ] && [ -z "$DRY_RUN_OPT" ] && [ -z "$RESTORE_OPT" ] \
        && ssh "${DEST%:}" ". .bash_aliases && freespace $DATA_DIR";
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

latest_alire_gnat_native_dep() {

    # Echoes the version of the latest GNAT native Alire dependency.

    find ~/.config/alire/cache/dependencies/ -mindepth 1 -maxdepth 1 -type d \
        -regextype posix-extended \
        -regex "^\/.*\/dependencies\/gnat_native_.*$" \
        -exec find {}/bin -mindepth 1 -maxdepth 1 \
        -type f -executable -name gnat \; 2>/dev/null \
        | sed "s/^.*\/gnat_native_\([^_]\+\).*$/\1/" \
        | sort \
        | tail -1;
}

latest_alire_gprbuild_dep() {

    # Echoes the version of the latest GPRbuild Alire dependency.

    find ~/.config/alire/cache/dependencies/ -mindepth 1 -maxdepth 1 -type d \
        -regextype posix-extended \
        -regex "^\/.*\/dependencies\/gprbuild_.*$" \
        -exec find {}/bin -mindepth 1 -maxdepth 1 \
        -type f -executable -name gprbuild \; 2>/dev/null \
        | sed "s/^.*\/gprbuild_\([^_]\+\).*$/\1/" \
        | sort \
        | tail -1;
}

latest_alire_gnatprove_dep() {

    # Echoes the version of the latest GNATprove Alire dependency.

    find ~/.config/alire/cache/dependencies/ -mindepth 1 -maxdepth 1 -type d \
        -regextype posix-extended \
        -regex "^\/.*\/dependencies\/gnatprove_.*$" \
        -exec find {}/bin -mindepth 1 -maxdepth 1 \
        -type f -executable -name gnatprove \; 2>/dev/null \
        | sed "s/^.*\/gnatprove_\([^_]\+\).*$/\1/" \
        | sort \
        | tail -1;
}

latest_alire_gnatcov_dep() {

    # Echoes the version of the latest GNATcoverage Alire dependency.

    find ~/.config/alire/cache/dependencies/ -mindepth 1 -maxdepth 1 -type d \
        -regextype posix-extended \
        -regex "^\/.*\/dependencies\/gnatcov_.*$" \
        -exec find {}/bin -mindepth 1 -maxdepth 1 \
        -type f -executable -name gnatcov \; 2>/dev/null \
        | sed "s/^.*\/gnatcov_\([^_]\+\).*$/\1/" \
        | sort \
        | tail -1;
}

with_alire_deps() {

    local LATEST_GNAT_NATIVE_VERSION=$(latest_alire_gnat_native_dep);

    if [ -z "$LATEST_GNAT_NATIVE_VERSION" ]; then
        echo "No GNAT native Alire dependency found" 1>&2;
        return 1;
    fi;

    local LATEST_GPRBUILD_VERSION=$(latest_alire_gprbuild_dep);

    if [ -z "$LATEST_GPRBUILD_VERSION" ]; then
        echo "No GPRbuild Alire dependency found" 1>&2;
        return 1;
    fi;

    local LATEST_GNATPROVE_VERSION=$(latest_alire_gnatprove_dep);

    if [ -z "$LATEST_GNATPROVE_VERSION" ]; then
        echo "No GNATprove Alire dependency found" 1>&2;
        return 1;
    fi;

    local LATEST_GNATCOV_VERSION=$(latest_alire_gnatcov_dep);

    if [ -z "$LATEST_GNATCOV_VERSION" ]; then
        echo "No GNATcoverage Alire dependency found" 1>&2;
        return 1;
    fi;

    local PREFIX=~/.config/alire/cache/dependencies;
    local V=;

    V="$LATEST_GNAT_NATIVE_VERSION";
    local GNAT_NATIV_BIN_DIR=\
$(find "$PREFIX/gnat_native_$V"*/bin -mindepth 0 -maxdepth 0 -type d);

    V="$LATEST_GPRBUILD_VERSION";
    local GPRBUILD_BIN_DIR=\
$(find "$PREFIX/gprbuild_$V"*/bin -mindepth 0 -maxdepth 0 -type d);

    V="$LATEST_GNATPROVE_VERSION";
    local GNATPROVE_BIN_DIR=\
$(find "$PREFIX/gnatprove_$V"*/bin -mindepth 0 -maxdepth 0 -type d);

    V="$LATEST_GNATCOV_VERSION";
    local GNATCOV_BIN_DIR=\
$(find "$PREFIX/gnatcov_$V"*/bin -mindepth 0 -maxdepth 0 -type d);

    PATH=\
"$GNAT_NATIV_BIN_DIR":\
"$GPRBUILD_BIN_DIR":\
"$GNATPROVE_BIN_DIR":\
"$GNATCOV_BIN_DIR":\
"$PATH"
}

dlume2vcard() {

    # Output the Dlume data file content in vCard (.vcf file) format.
    # First name, last name, phone numbers and email addresses are preserved,
    # other information are ignored.
    #
    # Contacts with a first or last name containing anything other than
    # letters, single quotes (') or hyphens are ignored.

    local INPUT_FILE=~/.dlume/dlume-data.xml;
    local FIELD_NAME=;
    local F;                                  # Short name for FIELD_NAME.
    local FIELD_VALUE=;
    local V;                                  # Short name for FIELD_VALUE.
    local FIRST_NAME=;
    local FIRST_NAME_NO_ACCENT=;
    local LAST_NAME=;
    local LAST_NAME_NO_ACCENT=;
    local PHONE=;
    local PHONE_TYPE=;
    local EMAIL=;

    local PHONE_TYPE_PREFIX="TYPE=";
    local SEP="\n";
    local UNACCENT="unaccent UTF-8";
    local NRE="[^A-Za-z'-]";

    local NAME_PROP=N;
    local FORMATTED_NAME_PROP=FN;
    local PHONE_PROP=TEL;
    local EMAIL_PROP=EMAIL;

    while IFS= read -r LINE; do

        if [ "$(echo "$LINE"|grep $'^\t')" != "" ]; then

            FIELD_NAME=$(echo "$LINE" | sed "s/^\s\+<\([^<>]\+\)>.*$/\1/");
            F="$FIELD_NAME";

            FIELD_VALUE=$(echo "$LINE" | sed "s/^\s\+<$F>\(.*\)<\/$F>/\1/");
            V="$FIELD_VALUE";

            case "$FIELD_NAME" in
                first_name)
                    FIRST_NAME="$FIELD_VALUE";
                    FIRST_NAME_NO_ACCENT="$(echo "$FIRST_NAME" | $UNACCENT)";
                    ;;
                last_name)
                    LAST_NAME="$FIELD_VALUE";
                    LAST_NAME_NO_ACCENT="$(echo "$LAST_NAME" | $UNACCENT)";
                    ;;
                home_phone_*)
                    [ -n "$PHONE" ] && PHONE="${PHONE}$SEP"
                    if [ "$(echo "$V"|grep "^0[67]\.")" != "" ]; then
                        PHONE_TYPE="${PHONE_TYPE_PREFIX}CELL:";
                    elif [ "$(echo "$V"|grep "^0[123459]\.")" != "" ]; then
                        PHONE_TYPE="${PHONE_TYPE_PREFIX}VOICE:";
                    fi;
                    PHONE="${PHONE}${PHONE_PROP};";
                    PHONE="${PHONE}${PHONE_TYPE}$(echo "$V"|sed "s/\.//g")";
                    ;;
                work_phone_*)
                    [ -n "$PHONE" ] && PHONE="${PHONE}$SEP"
                    PHONE_TYPE="${PHONE_TYPE_PREFIX}WORK:";
                    PHONE="${PHONE}${PHONE_PROP};";
                    PHONE="${PHONE}${PHONE_TYPE}$(echo "$V"|sed "s/\.//g")";
                    ;;
                cell_phone_*)
                    [ -n "$PHONE" ] && PHONE="${PHONE}$SEP"
                    PHONE_TYPE="${PHONE_TYPE_PREFIX}CELL:";
                    PHONE="${PHONE}${PHONE_PROP};";
                    PHONE="${PHONE}${PHONE_TYPE}$(echo "$V"|sed "s/\.//g")";
                    ;;
                email_*)
                    [ -n "$EMAIL" ] && EMAIL="${EMAIL}$SEP"
                    EMAIL="${EMAIL}${EMAIL_PROP}:$V";
                    ;;
            esac;

        elif [ "$(echo "$LINE"|grep '^<\/record>')" != "" ]; then

            if [ "$FIRST_NAME" == "" ] \
                || [ "$LAST_NAME" == "" ] \
                || [ "$(echo "$FIRST_NAME_NO_ACCENT"|grep "$NRE")" != "" ] \
                || [ "$(echo "$LAST_NAME_NO_ACCENT"|grep "$NRE")" != "" ]; then

                echo IGNORED: "$FIRST_NAME" "$LAST_NAME" 1>&2;

            else

                echo BEGIN:VCARD
                echo VERSION:3.0
                echo "$NAME_PROP:${LAST_NAME};${FIRST_NAME}"
                echo "$FORMATTED_NAME_PROP:${FIRST_NAME} ${LAST_NAME}"
                [ -n "$PHONE" ] && PHONE="${PHONE}\n"
                printf "$PHONE";
                [ -n "$EMAIL" ] && EMAIL="${EMAIL}\n"
                printf "$EMAIL";
                echo END:VCARD

            fi;
            FIRST_NAME=;
            LAST_NAME=;
            PHONE=;
            EMAIL=;

        fi;

    done < "$INPUT_FILE";
}

sftp_dcim_camera() {

    # Start sftp. The destination is the /DCIM/Camera directory of a host. The
    # first argument is the port the SSH server of the host is listening on and
    # the second argument is the host address or name with the user name if
    # needed (e.g. host_name or user_name@host_name).

    sftp -P "$1" "$2":/DCIM/Camera;
}

lowercase_posix_portable() {

    # Convert standard input to a lowercase POSIX portable file name. Ampersand
    # ('&') character is converted to "and". Anything that is not a letter, a
    # digit or an hyphen is converted to underscore ('_').

    sed "s/&/and/" \
        | unaccent UTF-8 \
        | tr '[:upper:]' '[:lower:]' \
        | tr -c "a-z0-9-" [_*];
}

cdown_gnudb() {

    # Runs 'cdown -H gnudb.gnudb.org -P 8880'. If arguments are provided, then
    # there must be two arguments and the first one must be "-d". The second
    # one must be the optical disc drive device (e.g. "/dev/sr0", "/dev/sr1").

    local DEV_OPT=;

    if [ $# -gt 0 ]; then
        [ $# -eq 1 ] && echo "Missing argument" 1>&2 && exit 1;
        [ $# -gt 2 ] && echo "Too many arguments" 1>&2 && exit 1;
        [ "$1" != "-d" ] \
            && echo 'First argument should be "-d"' 1>&2 && exit 1;
        echo device "$2";
    fi;

    cdown -H gnudb.gnudb.org -P 8880 $@
}

postprocess_cdown_output_for_ripcd() {

    # The input (read from standard input) is supposed to be the output of
    # 'cdown' (or of function 'cdown_gnudb'). The output is aimed at being
    # piped to 'ripcd'.

    local TEXT_KIND=;
    local TEXT=;
    local CONVERTED_TEXT=;
    local TRACK_NUM_OFFS_WRITTEN=false;

    while IFS= read -r LINE; do

        echo "$LINE" | grep -q "^\(device\|cdname\|artist\|track\) " \
            || continue;

        if [ $TRACK_NUM_OFFS_WRITTEN == false ]; then
            echo track_number_offset 0;
            TRACK_NUM_OFFS_WRITTEN=true;
        fi;

        TEXT_KIND="${LINE%% *}";

        [ "$TEXT_KIND" == device ] && echo "$LINE" && continue;

        TEXT="${LINE#* }";
        CONVERTED_TEXT="$(echo -n "$TEXT" | lowercase_posix_portable)";

        echo "$TEXT_KIND $CONVERTED_TEXT (\"$TEXT\")"

    done;

    [ $TRACK_NUM_OFFS_WRITTEN == false ] \
        || echo -e "\nIf accented letters are not rendered properly, try" \
                   "piping cdown output to 'iconv -f latin1'." 1>&2;
}

ripcd() {

    # Build audio (Ogg) files from audio CD. The input is read on standard
    # input and is supposed to be the output of
    # 'postprocess_cdown_output_for_ripcd'. The output files are written to the
    # output of 'last_subdir $(data_dir)/$(music_data_subdir)'.

    local TEXT_KIND=;
    local TEXT=;
    local CONVERTED_TEXT=;
    local DEV_OPT=;
    local TRACK_NUM_OFFS=0;
    local K=0;
    local K_S=;
    local ARTIST=;
    local ARTIST_CONVERTED=;
    local CDNAME=;
    local CDNAME_CONVERTED=;
    local MUSIC_DIR=;
    local OUTPUT_DIR=;
    local OUTPUT_DIR_CREATED=false;
    local OUTPUT_FILE;

    while IFS= read -r LINE; do

        TEXT_KIND="${LINE%% *}";
        TEXT="${LINE#* }";

        case "$TEXT_KIND" in

            device)
                DEV_OPT="-d $TEXT";
                ;;

            track_number_offset)
                TRACK_NUM_OFFS="$TEXT";
                ;;

            cdname|artist|track)

                CONVERTED_TEXT="${TEXT%% (\"*}";
                TEXT="${TEXT#* (\"}";
                TEXT="${TEXT%\")}";

                case "$TEXT_KIND" in

                    cdname)
                        CDNAME="$TEXT";
                        CDNAME_CONVERTED="$CONVERTED_TEXT";
                        ;;

                    artist)
                        ARTIST="$TEXT";
                        ARTIST_CONVERTED="$CONVERTED_TEXT";
                        ;;

                    track)
                        K=$((K + 1));
                        K_S=$(printf "%02d" $((K + $TRACK_NUM_OFFS)));
                        OUTPUT_FILE="$OUTPUT_DIR/${K_S}_-_$CONVERTED_TEXT.ogg";
                        echo "Creating $OUTPUT_FILE";
                        cdparanoia $DEV_OPT $K - | oggenc -a "$ARTIST" \
                            -t "$TEXT" -l "$CDNAME" -c "tracknumber=$K_S" \
                            -o "$OUTPUT_FILE" -;
                        ;;

                esac;

                ;;

        esac;

        if [ -n "$CDNAME" ] && [ -n "$ARTIST" ] \
            && [ "$OUTPUT_DIR_CREATED" == false ]; then

            MUSIC_DIR="$(last_subdir $(data_dir)/$(music_data_subdir))";
            OUTPUT_DIR="$MUSIC_DIR/$ARTIST_CONVERTED/$CDNAME_CONVERTED";
            mkdir -p "$OUTPUT_DIR";

            OUTPUT_DIR_CREATED=true;

        fi;

    done;
}
