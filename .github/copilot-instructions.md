## Purpose

This repo is a minimal, hackable dotfiles manager implemented as a set of shell scripts and a collection of "profiles". The guidance below helps an AI coding agent make focused, correct edits that follow the project's conventions.

## Big picture (what matters)

## Developer workflows & important commands
  - sh -c "$(curl -fsSL https://raw.githubusercontent.com/HectorCastelli/dotfiles/HEAD/scripts/get.sh)"
  - `sh` and `curl` are required for the bootstrap step.

## Project-specific patterns & conventions
  - `install.sh` — apply changes for that profile (idempotent). Example template is under `profiles/_template/install.sh` which begins with #!/usr/bin/env bash and `set -u`.
  - `uninstall.sh` — undo what the profile installed.
  - `prompt.sh` — (optional) request interactive inputs required by `install.sh`.
  - `home/` — a directory whose files are symlinked into $HOME; treat it as the canonical declaration of desired home files.
  - Use /usr/bin/env bash for the shebang and include at least `set -u` (the template shows this pattern).

## Integration points & external dependencies

## How an agent should approach common tasks

## Quick file references (examples)

If anything in this guide is unclear or you want the agent to be more prescriptive about testing, linting, or stricter script headers, tell me which area to expand and I will iterate.
