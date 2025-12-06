#!/usr/bin/env sh

alias g='git'
alias ga='git add'
# Add all files on the root of the repository
alias ga!='git add $(git rev-parse --show-toplevel)'
alias gb='git branch'
alias gbD='git branch --delete'
alias gco='git checkout'
alias gcor='git checkout --recurse-submodules'
alias gsw='git switch'
alias gswr='git switch --recurse-submodules'
alias gc='git commit --verbose'
alias gca='git commit --verbose --amend'
alias gcm='git commit --verbose --message'
alias gcnm='git commit --verbose --no-verify --message'
# Commit with a "revert-me:" prefix
gcwip() {
	if [ $# -eq 0 ]; then
		echo "Usage: gcwip <commit message>"
		return 1
	fi
	gcm "revert-me: $*"
}
alias gcundo='git reset HEAD~1 --soft'
gcl() {
	git fetch --all
	info "Deleting local branches that no longer have a remote"
	git branch -vv | grep 'gone]' | awk '{print $1}' | xargs git branch -D
	info "Listing local branches that do have a remote"
	git branch --no-merged | awk '{print $1}'
}
alias gf='git fetch'
alias gf!='git fetch --all'
alias glo='git log --oneline --decorate'
alias glo!='git log --graph'
alias gl='git pull'
alias gll='git fetch --all && git pull'
alias glr='git pull --rebase'
alias gp='git push'
alias gpd='git push --dry-run'
alias gpf!='git push --force'
alias grm='git rm'
alias grmc='git rm --cached'
alias grb='git rebase'
alias grbmain='git fetch origin main && git rebase origin/main'
alias grv='git revert'
alias gst='git status'
gmain() {
	if git show-ref --verify --quiet refs/heads/main; then
		gb -D main
	fi
	g fetch
	gsw main
	gcl
}
gdiff() {
	branch=$(git rev-parse --abbrev-ref HEAD)
	if [ "$branch" = "main" ]; then
		echo "You are on the main branch. Please switch to a different branch."
		return 1
	fi
	base="main"
	echo "These files were changed between $branch and $base"
	merge_base=$(git merge-base "$branch" "$base")
	git diff --name-only "$branch" "$merge_base"
}
# For every commit that start with a "revert-me" prefix, revert it if it hasn't been done already
grvall() {
	# Exit if current branch is "main"
	current_branch=$(git rev-parse --abbrev-ref HEAD)
	if [ "$current_branch" = "main" ]; then
		error "You are on the 'main' branch."
		return 1
	fi

	# List all commits in the current branch (SHA and subject)
	git log --pretty=format:"%H %s" | while IFS= read -r line; do
		sha=$(echo "$line" | awk '{print $1}')
		message=$(echo "$line" | sed "s/^$sha //")

		case "$message" in
		revert-me* | revertme* | revert\ me*)
			# Check if this commit has already been reverted
			already_reverted=$(git log --pretty=format:"%H %s" | grep "Revert" | grep "$sha")
			if [ -n "$already_reverted" ]; then
				echo "Commit $sha has already been reverted. Skipping."
				continue
			fi

			echo "Reverting commit: $sha - $message"
			git revert "$sha"
			echo "Press Enter to confirm the reversion is as expected..."
			# shellcheck disable=SC2034
			# `dummy` is unused
			read -r dummy
			;;
		esac
	done
}
