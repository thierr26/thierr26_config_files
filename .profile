# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

if [ -d /usr/bin/mh ] ; then
    PATH="$PATH":/usr/bin/mh
fi

if [ -d /opt/alire/bin ] ; then
    PATH="$PATH":/opt/alire/bin
fi

if [ -d /usr/local/opt/gnat-19.2-x86_64/bin ] ; then
    PATH="$PATH":/usr/local/opt/gnat-19.2-x86_64/bin
    export COMPILER_PATH="/usr/libexec/gcc/x86_64-redhat-linux/4.8.2:\
/usr/local/opt/gnat-19.2-x86_64/libexec/gcc/x86_64-pc-linux-gnu/7.3.1"
fi

if [ -d ~/data/dvlpt/ada/ompacc/shared_gnat_project ] ; then
    if echo "$GPR_PROJECT_PATH"|grep -v -q "ompacc\/shared_gnat_project" ; then
        if [ -n "$GPR_PROJECT_PATH" ]; then
            export GPR_PROJECT_PATH=\
~/data/dvlpt/ada/ompacc/shared_gnat_project:\
~/data/dvlpt/ada/ompacc/gnat_projects:\
"$GPR_PROJECT_PATH"
        else
            export GPR_PROJECT_PATH=\
~/data/dvlpt/ada/ompacc/shared_gnat_project:\
~/data/dvlpt/ada/ompacc/gnat_projects
        fi
    fi
fi

if [ -d ~/data/dvlpt/ada/libaspocc/aspocc/gnat_project ] ; then
    if echo "$GPR_PROJECT_PATH"|grep -v -q "aspocc\/gnat_project" ; then
        if [ -n "$GPR_PROJECT_PATH" ]; then
            export GPR_PROJECT_PATH=\
~/data/dvlpt/ada/libaspocc/aspocc/gnat_project:\
"$GPR_PROJECT_PATH"
        else
            export GPR_PROJECT_PATH=\
~/data/dvlpt/ada/libaspocc/aspocc/gnat_project
        fi
    fi
fi

if [ -d ~/data/dvlpt/ada/tesstam/gnat_project ] ; then
    if echo "$GPR_PROJECT_PATH"|grep -v -q "tesstam\/gnat_project" ; then
        if [ -n "$GPR_PROJECT_PATH" ]; then
            export GPR_PROJECT_PATH=\
~/data/dvlpt/ada/tesstam/gnat_project:\
"$GPR_PROJECT_PATH"
        else
            export GPR_PROJECT_PATH=\
~/data/dvlpt/ada/tesstam/gnat_project
        fi
    fi
fi

if [ -d ~/.config/alire/cache/dependencies/gnatcov_22.0.1_eae687f0/share\
/gnatcoverage/gnatcov_rts ] ; then
    if echo "$GPR_PROJECT_PATH"|grep -v -q "gnatcoverage\/gnatcov_rts" ; then
        if [ -n "$GPR_PROJECT_PATH" ]; then
            export GPR_PROJECT_PATH=\
~/.config/alire/cache/dependencies/gnatcov_22.0.1_eae687f0/share\
/gnatcoverage/gnatcov_rts:\
"$GPR_PROJECT_PATH"
        else
            export GPR_PROJECT_PATH=\
~/.config/alire/cache/dependencies/gnatcov_22.0.1_eae687f0/share\
/gnatcoverage/gnatcov_rts
        fi
    fi
fi
