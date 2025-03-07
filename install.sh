#!/bin/bash

cd "$HOME" || exit 1

CMD_DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
NVIM_PATH="$HOME/.config/nvim"
_move_config()
{
	local _name="$1"
	local _from="$2"
	local _to="$3"
	if [ -e "$_to/$_name.bak" ]; then
		echo "ERROR: $_to/$_name.bak exists"; read -r
	elif [ -e "$_to/$_name" ]; then
		mv "$_to/$_name" "$_to/$_name.bak"
	fi
	cp -r "$_from/$_name" "$_to/"
}

{
	pkg update && pkg upgrade
	pkg install termux-api openssl
	termux-setup-storage
}


{
	pkg install neovim clang python ripgrep luajit luarocks nodejs man
	luarocks install jsregexp
}

npm-g-install()
{
	local _installed _pending _pkg
	_pending=("$@")
	_installed="$(npm -g list | tail -n +2 | cut -d' ' -f2 | cut -d@ -f1)"
	for _pkg in ${_pending[@]}; do
		grep -q "$_pkg" <<< "${_installed[@]}" || npm -g install "$_pkg"
	done
}

{
	# language servers
	pkg install lua-language-server shellcheck shfmt
	npm-g-install basedpyright bash-language-server
}

pkg install gh git expect

if [ -d "$NVIM_PATH" ]; then
	echo "ERROR: $NVIM_PATH exists"; read -r
else
	mkdir -p "$NVIM_PATH"
	git clone https://github.com/diamond2sword/nvchad-fun "$NVIM_PATH"
fi

echo -n 'Load Nvim? [y]: '
read _must_load
[[ "$_must_load" =~ ^[yY]$ ]] && {
	nvim --headless '+Lazy sync' +qa
}

{
	# zsh
	pkg install zsh

	_move_config vifm $NVIM_PATH $HOME/.config
	_move_config .zshrc $NVIM_PATH $HOME
	_move_config .zimrc $NVIM_PATH $HOME
	_move_config .termux $NVIM_PATH $HOME
	_move_config .p10k.zsh $NVIM_PATH $HOME
	_move_config .f-sy-h $NVIM_PATH $HOME
	termux-reload-settings

	curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh

	pkg install zoxide fzf vifm

	if ! [[ "$(ps -o comm= -p $$)" =~ .*bash$ ]]; then
		echo ERROR: shell is not bash; read -r
	fi

	chsh -s zsh
	zsh
}
#disown -a
{
	# auto exit
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
	kill -9 $(_termux_session_pid)
}
