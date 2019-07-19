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
    # - For all targets, you want to exclude one specific directory and one
    #   specific file (see the --exclude options in the rsync command).
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

    rsync $DRYRUN_OPT -aAXv --delete \
        --exclude=<relative_unbacked_up_dir_path> \
        --exclude=<relative_unbacked_up_file_path> \
        $SPECIFIC_EXCLUDE \
        ~/data "/media/$USER/$TARGET/$USER";
}
