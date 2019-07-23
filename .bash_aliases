alias am=alsamixer
alias ds='du -sBM'
alias e='vi -O'
alias fm='fetchmail --sslproto="" --mda "procmail -f %F" && inc'
alias g=git
alias ifp='sudo ifp'
alias lla='ls -la'
alias m=make
alias mute='amixer -q -c 0 sset Master playback mute'
alias noise='aplay /usr/share/sounds/alsa/Noise.wav'
alias oc='octave --quiet'
alias spam='refile +Spam'
alias t=task
alias ta='task add pri:M'
alias tapp='task add pri:H +appointment'
alias tmks='tmux kill-server'
alias tv='vlc http://mafreebox.freebox.fr/freeboxtv/playlist.m3u &'
alias x=startx

secret() {

    # Handle "secret" directory. Exactly one argument required (the option).
    #
    # Option "-n": Output path to secret directory (which may exist or not).
    # Option "-z": Output path to secret directory archive (.tgz file) (which
    #              does probably not exist, used as temporary file).
    # Option "-p": Output path to encrypted secret directory archive (.tgz.gpg
    #              file) (which should exist).
    # Option "-e": Encrypt secret directory.
    # Option "-d": Decrypt secret directory (keeps encrypted file).

    local ERR_PREF="${FUNCNAME[0]}: ";
    local SECRET_DIR_PATH=<abs_secret_dir>
    local SECRET_FILE_PATH="$SECRET_DIR_PATH".tgz;
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
        && [ "$1" != "-z" ] \
        && [ "$1" != "-p" ] \
        && [ "$1" != "-e" ] \
        && [ "$1" != "-d" ] \
        && VALID_ARG=false;

    [[ $ARG = "false" || $VALID_ARG = "false" ]] \
        && echo "${ERR_PREF}$EXAC:" \
            "\"-n\", \"-z\", \"-p\", \"-e\" or \"-d\"." 1>&2 \
        && return 1;

    case "$1" in
        -n)
            echo "$SECRET_DIR_PATH";
            ;;
        -z)
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
            rm -f "$SECRET_FILE_PATH";
            tar -C "$SECRET_PARENT" -czvf \
                "$SECRET_FILE_PATH" "${SECRET_DIR_PATH##*/}";
            gpg -c "$SECRET_FILE_PATH";
            rm "$SECRET_FILE_PATH";
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
            rm -f "$SECRET_FILE_PATH";
            gpg "$SECRET_GPG_PATH";
            tar -C "$SECRET_PARENT" -xzvf "$SECRET_FILE_PATH";
            rm "$SECRET_FILE_PATH";
            echo "$DONE$DECR";
    esac;
}

rsync_data_backup() {

    # Backup ~/data to /media/$USER/<target_name>/$USER using rsync.
    #
    # If the first argument is "--dry-run", then the "-n" option is used in the
    # rsync command to make it a dry run.
    #
    # The following argument must be <target_name>.
    #
    # This function is useful as is if:
    # - Your precious data files are in directory ~/data (and in
    #   subdirectories).
    # - You want to backup your data to /media/$USER/<target_name>/$USER (where
    #   /media/$USER/<target_name> is probably the mount point for an external
    #   drive (thunar-volman uses such mount points)).
    # - <target_name> is one of "chil", "ikki", "mang" and "mysa" (adapt the
    #   case statement in the code if you have different target names).
    # - In the case of the "chil" target, you want to exclude (that is you
    #   don't want to backup) ~/data/image and ~/data/music (see the
    #   SPECIFIC_EXCLUDE local variable).
    # - For all targets, you want to exclude the directories or files returned
    #   by "secret -n" and "secret -z" (see the --exclude options in the rsync
    #   command and see the secret function above).
    #
    # Note the --delete option in the rsync command: Files removed from ~/data
    # are removed in the backup.
    #
    # Note also that there is no trailing slash on the ~/data argument to the
    # rsync command. It implies the the "data" directory is recreated in
    # /media/$USER/<target_name>/$USER.
    # (see
    # qdosmsq.dunbar-it.co.uk/blog/2013/02/rsync-to-slash-or-not-to-slash).

    local ERR_PREF="${FUNCNAME[0]}: ";
    local DRYRUN_OPT=;
    local TARGET=;
    local SPECIFIC_EXCLUDE=;
    local DEST=;

    [ $# -eq 0 ] \
        && echo "${ERR_PREF}At least one argument required." 1>&2 \
        && return 1;

    if [ "$1" = --dry-run ]; then
        DRYRUN_OPT=-n;
        shift;
    fi;

    [ $# -eq 0 ] \
        && echo "${ERR_PREF}Missing target name argument." 1>&2 \
        && return 1;

    TARGET="$1";

    case "$TARGET" in
        ikki | mang | mysa)
            ;;
        chil)
            SPECIFIC_EXCLUDE="--exclude=image --exclude=music";
            ;;
        *)
            echo "${ERR_PREF}Unknown target: $TARGET" 1>&2 \
                && return 1;
            ;;
    esac;

    DEST="/media/$USER/$TARGET/$USER";

    [ ! -d "$DEST" ] \
        && echo "${ERR_PREF}Inexistent Destination directory: $DEST." 1>&2 \
        && return 1;

    rsync $DRYRUN_OPT -aAXv --delete \
        --exclude=<relative_unbacked_up_dir_path> \
        --exclude=<relative_unbacked_up_dir_path> \
        $SPECIFIC_EXCLUDE \
        ~/data "$DEST";
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
