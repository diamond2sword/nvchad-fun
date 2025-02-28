local first_file_buf = require('fn.buf.first-file-buf')
local toggleterm_cmd = require("fn.toggleterm.cmd")

return function()
  local buf = first_file_buf()
  if buf == nil then return end
  local buf_name = vim.api.nvim_buf_get_name(buf)
  local swp_file = vim.fn.swapname(buf_name)
  local cmd = 'rm -rf '..swp_file
  toggleterm_cmd(cmd)
end
