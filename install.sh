#!/bin/bash

_pkg(){ pkg "$@"; }
_pause(){ read; }
_termux_setup_storage(){ termux-setup-storage; }
if [[ "$_auto" == true ]]; then
	_pkg(){ yes | pkg "$@"; }
	_pause(){ :; }
	_termux_setup_storage(){ yes | termux-setup-storage; }
fi

(return 0 2>/dev/null)
if [[ "$?" != 0 ]]; then
	echo ERROR: must be sourced; _pause
	exit 1
fi

if ! [[ "$SHELL" =~ .*bash$ ]]; then
	echo ERROR: shell is not bash; _pause
	return 1
fi

if ! cd "$HOME"; then
	echo ERROR: cannot cd to \$HOME; _pause
	return 1
fi

_move_config()
{
	local _name="$1"
	local _from="$2"
	local _to="$3"
	if [ -e "$_to/$_name.bak" ]; then
		echo "ERROR: $_to/$_name.bak exists"; _pause
	elif [ -e "$_to/$_name" ]; then
		mv "$_to/$_name" "$_to/$_name.bak"
	fi
	cp -r "$_from/$_name" "$_to/"
}


_npm_g_install()
{
	local _installed _pending _pkg
	_pending=("$@")
	_installed="$(npm -g list | tail -n +2 | cut -d' ' -f2 | cut -d@ -f1)"
	for _pkg in ${_pending[@]}; do
		grep -q "$_pkg" <<< "${_installed[@]}" || npm -g install "$_pkg" --verbose
	done
}
	
_termux_session_pid()
{
	# kill the third from the most parent processes
	# 1st: phone's
	# 2nd: termux
	# 3rd: session
	_ppid(){ ps -o ppid= -p $1; }
	_p=$$
	_ps=()
	while [[ "$_p" ]]; do
		_ps+=("$_p")
		_p=$(_ppid $_p)
	done
	_comm=""
	_len=${#_ps[@]}
	#_i=1
	for ((_i=_len-1; _i>=0; _i--)); do
		_p=${_ps[_i]}
		_comm=$(ps -o comm= -p $_p)
		[[ "$_comm" =~ ^.*$SHELL$ ]] && break
	done
	echo $_p 
}

CMD_DIR=$(cd $(dirname $0); pwd)
NVIM_PATH="$HOME/.config/nvim"
{
	_pkg update && _pkg upgrade
	_pkg install termux-api openssl
	_termux_setup_storage
}

{
	_pkg install neovim clang python ripgrep luajit luarocks nodejs man
	luarocks install jsregexp
}

{
	# language servers
	_pkg install lua-language-server shellcheck shfmt
	_npm_g_install basedpyright bash-language-server
}

{
	# github
	_pkg install gh git expect

	if [ -d "$NVIM_PATH" ]; then
		echo "ERROR: $NVIM_PATH exists"; _pause
	else
		mkdir -p "$NVIM_PATH"
		git clone https://github.com/diamond2sword/nvchad-fun "$NVIM_PATH"
	fi

	nvim --headless '+Lazy! sync' +qa
}

{
	# zsh
	_pkg install zsh zoxide fzf vifm

	_move_config .vifm $NVIM_PATH $HOME
	_move_config .zshrc $NVIM_PATH $HOME
	_move_config .zimrc $NVIM_PATH $HOME
	_move_config .termux $NVIM_PATH $HOME
	_move_config .p10k.zsh $NVIM_PATH $HOME
	_move_config .f-sy-h $NVIM_PATH $HOME

	curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh

	termux-reload-settings
	chsh -s zsh
	zsh
}
#disown -a
{
	# auto exit
	kill -9 $(_termux_session_pid)
}
