alias am=alsamixer
alias ds='du -sBM'
alias e='vi -O'
alias fm='fetchmail --sslproto="" --mda "procmail -f %F" && inc'
alias g=git
alias ggrep='git grep --no-index'
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
    local SECRET_DIR_PATH="$(data_dir)"/secret/directory; # Adapt to your needs.
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
            [ -f "$SECRET_FILE_PATH" ] && shred -u "$SECRET_FILE_PATH";
            tar -C "$SECRET_PARENT" -czvf \
                "$SECRET_FILE_PATH" "${SECRET_DIR_PATH##*/}";
            gpg -c "$SECRET_FILE_PATH";
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
            tar -C "$SECRET_PARENT" -xzvf "$SECRET_FILE_PATH";
            shred -u "$SECRET_FILE_PATH";
            echo "$DONE$DECR";
    esac;
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
    # - Possible values for <target_name> are "chil", "ikki", "mang" and
    #   "mysa".
    # - In the case of the "chil" target, you want to exclude (that is you
    #   don't want to backup) ~/data/image and ~/data/music (see the
    #   SPECIFIC_EXCLUDE local variable).
    # - For all targets, you want to exclude the item (directory or file)
    #   output by "secret -n" and the one output by "secret -z" (see the
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
    local SZ="$(secret -z)";
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

        $RSYNC \
            --exclude="${SN#"$DATA_DIR"/}" \
            --exclude="${SZ#"$DATA_DIR"/}" \
            "$DATA_DIR" "$DEST";
        freespace "$DEST";

    fi;
}

rsync_snapshot() {

    # Copy the content of a directory provided as argument to a subdirectory of
    # the ~/snapshot directory using rsync.
    #
    # For example, the content of directory ~/data/work/important_project would
    # be copied to a directory named like
    # ~/snapshot/2019-07-26T14.00.40Z_work__important_project (not the double
    # underscore between "work" and "important_project").
    #
    # An encrypted archive is also created
    # (~/snapshot/2019-07-26T14.00.40Z_work__important_project.tgz.gpg).
    # Decrypt with
    # gpg ~/snapshot/2019-07-26T14.00.40Z_work__important_project.tgz.gpg
    #
    # I you don't want the encrypted archive, add option "--no-gpg" as first
    # argument.
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
    # "secret -z" are ignored (i.e. not copied).

    local ERR_PREF="${FUNCNAME[0]}: ";
    local GPG_ARCHIVE=true;
    local DATA_DIR="$(data_dir)";
    local SNAP_DIR="$(snapshot_dir)";
    local DIR="$(pwd)";
    local DEST=;
    local DEST_TGZ=;
    local SECRET_DIR_PATH="$(secret -n)"/secret/directory; # Adapt to your needs.
    local SECRET_FILE_PATH="$(secret -z)";
    local SECRET_DIR_REL_PATH=;
    local SECRET_FILE_REL_PATH=;
    local EXCL=;
    local WONTATTEMPT="Won't attempt to snapshot";

    if [ "$1" = --no-gpg ]; then
        GPG_ARCHIVE=false;
        shift;
    fi;

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
    rsync -aAXv $EXCL "$DIR"/ "$DEST";
    if [ "$GPG_ARCHIVE" != "false" ]; then
        DEST_TGZ="$DEST_DIR".tgz;
        tar -C "$SNAP_DIR" -czvf "$SNAP_DIR/$DEST_TGZ" "$DEST_DIR";
        gpg -c "$SNAP_DIR/$DEST_TGZ";
        rm "$SNAP_DIR/$DEST_TGZ";
    fi;

    freespace "$SNAP_DIR";
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