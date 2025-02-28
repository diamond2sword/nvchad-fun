#!/bin/bash

NVIM_PATH="$HOME/.config/nvim"

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

if [ -d "$NVIM_PATH" ]; then
  echo "ERROR: $NVIM_PATH exists"; read -r
else
  mkdir -p "$NVIM_PATH"
  cd "$NVIM_PATH" || exit 1
  git clone https://github.com/diamond2sword/nvchad-fun "$NVIM_PATH"
fi

{
  if [ -f "$HOME/.termux.bak" ]; then
    echo "ERROR: $HOME/.termux.bak exists"; read -r
  else
    cp -r "$HOME/.termux" "$HOME/.termux.bak"
  fi
  cp -rf "$NVIM_PATH/.termux" "$HOME/.termux"
  termux-reload-settings
}

nvim --headless +'Lazy! sync' +q

#git clone https://github.com/NvChad/starter $HOME/.config/nvim && nvim
