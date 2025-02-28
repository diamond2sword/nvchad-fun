local toggleterm_cmd = require('fn.toggleterm.cmd')

return function()
  vim.cmd('normal! "ay')
  local text = vim.fn.getreg('a')
  text = text:gsub("\n*$", "")
  local delimiter = 'FN_TERMUX_COPY_EOF'
  local cmd = 'cat << "'..delimiter..'" | termux-clipboard-set\n'..text..'\n'..delimiter
  toggleterm_cmd(cmd)
end
