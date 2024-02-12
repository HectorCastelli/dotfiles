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
	npm config set proxy $_axa_go_proxy
	npm config set https-proxy $_axa_go_proxy
	npm config set noproxy $_axa_go_proxy_exclusion
}
proxy_npm_clear() {
	npm config rm proxy
	npm config rm https-proxy
	npm config rm noproxy
}
proxy_npm_debug() {
	echo "NPM proxy:"
	echo "npm http: $(npm config get proxy)"
	echo "npm https: $(npm config get https-proxy)"
	echo "npm noproxy: $(npm config get noproxy)"
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
	echo "Proxy cleared"
}
proxy_status() {
	echo "http_proxy" $http_proxy
	echo "no_proxy" $no_proxy
	proxy_git_debug
	proxy_npm_debug
}