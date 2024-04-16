# dotfiles

This repository contains my dotfiles, with scripts, configs and little tools that
I use to be productive on my day-to-day.

## Installing

To install this, you should clone this repository and run `./setup.sh` from within it.

## Structure:

- [`bin/`](./bin/): Scripts and binaries that should be always available (ie added to `$PATH`)
- [`setup/`](./setup/): Installation scripts, will be executed by the root [`./setup.sh`](./setup.sh) file for a correct installation.
- [`home/`](./home/): Files that should be linked to the user's `$HOME` directory
- [`fonts`](./fonts/): A directory with submodules for multiple fonts to be installed
- [`shell`](./shell/): ZSH shell configuration, aliases, and plugins

## Caveats

This project is not perfect, and it will never be.

Here are some things to keep in mind if you want to use or extend it:

- Changes can affect multiple files, things get a little confusing
- There is no parallelism
- The script will get interrupted when `sudo`ing on some steps
- There is no upgrade, only reinstall