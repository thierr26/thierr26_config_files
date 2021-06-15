# ~/.bashrc: executed by bash(1) for non-login shells.

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
# PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '
# umask 022
if [ -n "$SSH_TTY" ]; then
    in_ssh_session=yes
else
    tty_dev=$(tty);
    tty_dev_trimmed=${tty_dev#/*/};
    w|grep -v " .*grep"|grep -q " $tty_dev_trimmed .* sshd: " \
        && in_ssh_session=yes
    unset tty_dev tty_dev_trimmed
fi
if [ -n "$in_ssh_session" ]; then
    ps1_host_part='@\[\033[47m\]\[\033[32m\]\h\[\033[00m\]'
else
    ps1_host_part=
fi
PS1="\[\033[41m\]\[\033[01;32m\]\u\[\033[00m\]$ps1_host_part:\[\033[32m\]\w\[\033[00m\]\$ "
unset in_ssh_session ps1_host_part

# You may uncomment the following lines if you want `ls' to be colorized:
export LS_OPTIONS='--color=auto'
eval "`dircolors`"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'
#
# Some more alias to avoid making mistakes:
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
