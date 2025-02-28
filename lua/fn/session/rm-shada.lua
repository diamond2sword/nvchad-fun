local toggleterm_cmd = require("fn.toggleterm.cmd")

return function()
  local shada_dir = vim.fn.stdpath("state").."/shada"
  local cmd = 'rm -rf '..shada_dir.."/*"
  toggleterm_cmd(cmd)
end
