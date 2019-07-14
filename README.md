# Thierry Rascle's configuration files

## General information

This repository contains most of the configuration files I had to customize on
my [Debian GNU/Linux](https://www.debian.org) machines.

You may also be interested in my [personal notes](https://thierr26.github.io)
which provides details about the installation, configuration and/or usage of
Debian GNU/Linux and various softwares.

## Directory structure

The files and directories in this repository are meant to be placed *directly*
in the user's home directory (`~`), except:

- `root_user_config`: the files and directories in `root_user_config` are meant
  to be placed in root's home directory (`/root`). For example,
  `root_user_config/.bashrc` is meant to be `/root/.bashrc`.

- `system_config`: the files and directories in `system_config` are meant
  to be placed in the file system root directory (`/`). For example,
  `system_config/etc/apt/sources.list` is meant to be `/etc/apt/sources.list`.

## Clean filters

The `clean_filters` directory contains shell scripts. I use them as clean
filters to substitute personal information with placeholders like
"<my_email_address>" in certain files (see file `.gitattributes`).

I had to issue commands like the following in the working directory to activate
the filters:

```
git config --local filter.hide_git_name_and_email.clean 'clean_filters/hide_git_name_and_email %f'
```

## Author

[Thierry Rascle](mailto:thierr26@free.fr)

## License

This work is licensed under the [Unlicense license](http://unlicense.org).
