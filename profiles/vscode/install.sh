#!/usr/bin/env sh
set -eu

if [ "$(uname)" = "Linux" ]; then
	sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
	echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo >/dev/null
	dnf check-update || true
	sudo dnf install -y code
else
	brew install --cask visual-studio-code
fi

# Setup git editor
git config --file "$TARGET_DIR/home/.gitconfig" core.editor "code --wait"
