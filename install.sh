#!/bin/bash

CMD_DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
_move_config()
{
	local _name="$1"
	local _path="$2"
  if [ -f "$_path.bak" ]; then
    echo "ERROR: $_path.bak exists"; read -r
  else
    cp -r "$_path" "$_path.bak"
  fi
	cp -r "$CMD_DIR/$_name" "$_path"
}

cd "$HOME" || exit 1

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

if [ -d "$CMD_DIR" ]; then
  echo "ERROR: $CMD_DIR exists"; read -r
else
  mkdir -p "$CMD_DIR"
  cd "$CMD_DIR" || exit 1
  git clone https://github.com/diamond2sword/nvchad-fun "$CMD_DIR"
fi

_move_config .termux $HOME/.termux
termux-reload-settings
# {
#   if [ -f "$HOME/.termux.bak" ]; then
#     echo "ERROR: $HOME/.termux.bak exists"; read -r
#   else
#     cp -r "$HOME/.termux" "$HOME/.termux.bak"
#   fi
#   cp -rf "$CMD_DIR/.termux" "$HOME/.termux"
#   termux-reload-settings
# }

nvim --headless +'Lazy! sync' +q

#git clone https://github.com/NvChad/starter $HOME/.config/nvim && nvim

pkg install zsh
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh

pkg install zoxide fzf vifm

_move_config vifm $HOME/.config/vifm
_move_config .zshrc $HOME/.zshrc
_move_config .zimrc $HOME/.zimrc
# {
# 	# vifm
# 	local _name="vifm"
# 	local _path="$HOME/.config/$_name"
#   if [ -f "$_path.bak" ]; then
#     echo "ERROR: $_path.bak exists"; read -r
#   else
#     cp -r "$_path" "$_path.bak"
#   fi
# 	cp -r "$CMD_DIR/$_name" "$_path"
# }
