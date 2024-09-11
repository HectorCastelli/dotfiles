#!/bin/sh

_axa_go_proxy='http://172.20.117.31:8080'
_axa_go_proxy_exclusion='localhost,127.0.0.1,.local,0.0.0.0,172.20.117.,artifactory.europe.axa-cloud.com,.axa-cloud.com,*.intraxa'

proxy_git_set() {
	git config --file "$HOME/axa/.gitconfig" http.proxy $_axa_go_proxy
	git config --file "$HOME/axa/.gitconfig" https.proxy $_axa_go_proxy
}
proxy_git_clear() {
	git config --file "$HOME/axa/.gitconfig" --unset http.proxy
	git config --file "$HOME/axa/.gitconfig" --unset https.proxy
}
proxy_git_debug() {
	echo "git http: $(git config --file "$HOME/axa/.gitconfig" --get http.proxy)"
	echo "git https: $(git config --file "$HOME/axa/.gitconfig" --get https.proxy)"
}

proxy_npm_set() {
	npm config set proxy "$_axa_go_proxy" --location user --workspaces=false
	npm config set https-proxy "$_axa_go_proxy" --location user --workspaces=false
	npm config set noproxy "$_axa_go_proxy_exclusion" --location user --workspaces=false
}
proxy_npm_clear() {
	npm config rm proxy --location user --workspaces=false
	npm config rm https-proxy --location user --workspaces=false
	npm config rm noproxy --location user --workspaces=false
}
proxy_npm_debug() {
	echo "NPM proxy:"
	echo "npm http: $(npm config get proxy)"
	echo "npm https: $(npm config get https-proxy)"
	echo "npm noproxy: $(npm config get noproxy)"
}

_vscode_settings_file="$HOME/dotfiles/home/.config/Code/User/settings.json"
proxy_vscode_set() {
	jq ". += { \"http.proxy\": \"$_axa_go_proxy\", \"https.proxy\": \"$_axa_go_proxy\" }" "$_vscode_settings_file" >"$_vscode_settings_file.new"
	mv "$_vscode_settings_file.new" "$_vscode_settings_file"
}
proxy_vscode_clear() {
	jq 'del(."http.proxy", ."https.proxy")' "$_vscode_settings_file" >"$_vscode_settings_file.new"
	mv "$_vscode_settings_file.new" "$_vscode_settings_file"
}
proxy_vscode_debug() {
	echo "VSCode proxy:"
	echo "http: $(jq '.["http.proxy"]' "$_vscode_settings_file")"
	echo "https: $(jq '.["https.proxy"]' "$_vscode_settings_file")"
}

proxy_set() {
	export http_proxy=$_axa_go_proxy
	export https_proxy=$_axa_go_proxy
	export HTTPS_PROXY=$_axa_go_proxy
	export HTTP_PROXY=$_axa_go_proxy
	export ftp_proxy=$_axa_go_proxy
	export FTP_PROXY=$_axa_go_proxy
	export rsync_proxy=$_axa_go_proxy
	export RSYNC_PROXY=$_axa_go_proxy
	export no_proxy="$_axa_go_proxy_exclusion"
	export NO_PROXY="$_axa_go_proxy_exclusion"
	proxy_git_set
	proxy_npm_set
	proxy_vscode_set
	echo "Proxy set"
}
proxy_clear() {
	unset http_proxy
	unset https_proxy
	unset ftp_proxy
	unset rsync_proxy
	unset RSYNC_PROXY
	unset HTTPS_PROXY
	unset HTTP_PROXY
	unset FTP_PROXY
	unset no_proxy
	unset NO_PROXY
	proxy_git_clear
	proxy_npm_clear
	proxy_vscode_clear
	echo "Proxy cleared"
}
proxy_status() {
	echo "http_proxy" $http_proxy
	echo "no_proxy" $no_proxy
	proxy_git_debug
	proxy_npm_debug
	proxy_vscode_debug
}

# proxy_autoload() {
# 	output=$(/usr/sbin/scutil --nwi)

# 	if [ "$(echo "$output" | grep 'REACH : flags 0x00000003 (Reachable,Transient Connection)')" ]; then
# 		echo "🌍🔒 VPN connected"
# 		proxy_set
# 	else
# 		echo "🌍🔓 VPN disconnected"
# 		proxy_clear
# 	fi
# }
