# dotfiles

A [dotfiles](https://wiki.archlinux.org/title/Dotfiles) manager optimized for hackability and extensibility.

Instead of bringing it's own set of languages and standards, it is merely a collection of clever shell scripts and files.

It applies changes to your home directory by keeping it's own virtual "target" (a `git` repository) and manipulating it. This allows us to keep track of changes whenever actions are taken and quickly rollback to a previous state.

The files inside the target are then [symlinked](https://rm-rf.es/diferencias-entre-soft-symbolic-y-hard-links/) to the appropriate locations, ensuring your machine works as expected.

## Usage

To use this project, execute the [following script](./scripts/get.sh) in a terminal:

```shell
curl -fsSL https://raw.githubusercontent.com/HectorCastelli/dotfiles/HEAD/scripts/get.sh | sh -s -- get
```

You must have `sh` and `curl` available for this to work.

The script itself will check for any other tools that are required for the first-time setup, and initialize [an installation](#install).

### Custom installation locations

You may install the project in a different location, or from a different repository by using the following environment variables:

- `DOTFILES_DIR`: where the repository will be initialized into. Defaults to `$HOME/dotfiles`
- `DOTFILES_REPO`: the repository with dotfiles that should be cloned. Defaults to `https://github.com/HectorCastelli/dotfiles.git`

## Structure

The project is split into two major areas:

### Scripts

Scripts that take care of the interactions with the project itself.

They manage the project, the installation and uninstallation of profiles and offer basic functionality to work with the project.

### Profiles

Profiles are the main providers of functionality.

Profiles define what and how should be installed and configured (and uninstalled).

They have the following structure:

- `profiles/${name}`: The profile directory
    - `install.sh`: The installation script, executed every time the profile is installed
    - `uninstall.sh`: The uninstallation script, executed in case the user wants to remove a profile
    - `prompt.sh`: An optional script that will ask the user for inputs that are required for the installation script
      - `answers.env`: A file that stores the previous answers to this profile's prompt
    - `home/`: A directory that will be maped to the user's `$HOME` directory
        - `*`: Any files inside are symlinked to the correct destination

#### Mandatory profiles

The profile `0` is a mandatory profile that is executed before all others.

It follows the same structure as a regular profile, but you will not be prompted to install it.

## Commands

### Install

The [general installation script](./scripts/install.sh) takes care of setting up the project and profiles.

It works in the following manner:

1. Install the mandatory profiles
2. Allow you to choose which other profiles you´d like
   1. If any profile has inputs that are needed, you will be prompted for them accordingly
3. Generate a new version of the "target" directory with the an installation script and the final home directory state
4. If there are changes, they will be shown to you
   1. You may abort the installation at this stage without changing anything on your machine
5. If you approve the changes, the installation will proceed

#### Upgrades

Since installations are idempotent, upgrading the system is the done by triggering an installation.

You may use the `--upgrade` flag to keep the choices from your previous installation. Keep in mind this will not prevent profiles from asking new information with their prompts.

### Uninstall a profile

The [profile script](./scripts/profiles.sh) offers an uninstall command that is used to interact and remove existing profiles.

It works in the following manner:

1. Lists all installed profiles
2. Prompts the user for which profiles they would like to uninstall
3. Executed the uninstallation script of each selected profile
4. Executed the installation script again, to generate a new final state. This ensures that the final state is expected and that no leftover files are kept.

#### Uninstalling everything

You may execute the uninstall script with the `--all` flag to completely remove anything installed by this project, including the mandatory profile `0`.

This is a destructive operation, and we recommend you first uninstall all optional profiles to ensure that your system is working as expected.

### Creating profiles

The [profile script](./scripts/profiles.sh) offers the `create` command that creates a new blank profile in the project.

This is a good starting point to ensure you 

#### Mandatory profiles

If you´d like to mark a profile as mandatory, add a file named `.mandatory` to it's directory.

This way, you will not be prompted to install it, and the profile will only be uninstalled with the [`--all` flag](#uninstalling-everything).

### Testing

To test the installation process without altering your machine, you can use a container.

We support `podman` and `docker` for this.

The process is simple, run the following command:

```shell
# Build a test image
./scripts/tests.sh build
# Enter into it
./scripts/tests.sh launch
```

Then, from inside the running container you can do all commands you'd normally do:

```shell
./scripts/target.sh initialize
./scripts/target.sh install_profile 0
./scripts/target.sh apply
# Source the .profile to simulate a new login shell
. ~/.profile
# enter the main shell
zsh
```