# dotfiles

This repository contains my dotfiles, with scripts, configs and little tools that
I use to be productive on my day-to-day.

## Installing

To install this, you should run the following snippet from a terminal:

`sh -c "$(curl -fsSL https://raw.githubusercontent.com/HectorCastelli/dotfiles/main/bootstrap.sh)"`

Be warned, this will clone a bunch of submodules and might take a while on slower
connections.

## Structure:

- [`bin/`](./bin/): Scripts and binaries that should be always available (ie added to `$PATH`)
- [`setup/`](./setup/): Installation scripts, will be executed by the root [`./setup.sh`](./setup.sh) file for a correct installation.