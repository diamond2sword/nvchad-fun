#!/bin/bash

cd "$HOME" || exit 1

NVIM_PATH="$HOME/.config/nvim"
CMD_DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
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
	pkg install neovim clang python ripgrep luajit luarocks nodejs man
	luarocks install jsregexp
}

{
	# language servers
	pkg install lua-language-server shellcheck shfmt
	npm -g install basedpyright bash-language-server
}



pkg install gh git expect

if [ -d "$NVIM_PATH" ]; then
	echo "ERROR: $NVIM_PATH exists"; read -r
else
	mkdir -p "$NVIM_PATH"
	git clone https://github.com/diamond2sword/nvchad-fun "$NVIM_PATH"
fi


# {
#	 if [ -f "$HOME/.termux.bak" ]; then
#		 echo "ERROR: $HOME/.termux.bak exists"; read -r
#	 else
#		 cp -r "$HOME/.termux" "$HOME/.termux.bak"
#	 fi
#	 cp -rf "$CMD_DIR/.termux" "$HOME/.termux"
#	 termux-reload-settings
# }

# nvim --headless +'Lazy! sync' +q

#git clone https://github.com/NvChad/starter $HOME/.config/nvim && nvim

pkg install zsh
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
_move_config vifm $NVIM_PATH $HOME/.config
_move_config .zshrc $NVIM_PATH $HOME
_move_config .zimrc $NVIM_PATH $HOME
_move_config .termux $NVIM_PATH $HOME
termux-reload-settings

curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh

pkg install zoxide fzf vifm

chsh -s zsh
zsh; disown -a; exit

# {
# 	# vifm
# 	local _name="vifm"
# 	local _path="$HOME/.config/$_name"
#	 if [ -f "$_path.bak" ]; then
#		 echo "ERROR: $_path.bak exists"; read -r
#	 else
#		 cp -r "$_path" "$_path.bak"
#	 fi
# 	cp -r "$CMD_DIR/$_name" "$_path"
# }

