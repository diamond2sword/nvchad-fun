local function table_override(table, opts)
  for k, v in pairs(opts or {}) do
    table[k] = v
  end
end

local notify_exit_code = function(msg_cmd, msg_ok, msg_err)
  return function(exit_code)
    if exit_code == 0 then
      vim.notify(msg_cmd..'\n\n'..(msg_ok or 'SUCCESS'), vim.log.levels.INFO)
    else
      vim.notify(msg_cmd..'\n\n'..(msg_err or 'ERROR'), vim.log.levels.ERROR)
    end
  end
end

local cmds_join = function(cmds)
  local cmd_result
  for i, cmd in ipairs(cmds) do
    if i == 1 then
      cmd_result = cmd
    else
      cmd_result = cmd_result..'\n'..cmd
    end
  end
  return cmd_result
end

local first_file_win = require('fn.buf.first-file-win')

local toggleterm_cmd = function(cmd, opts)
  local file_win = first_file_win()
  if file_win == nil then return end
  vim.api.nvim_set_current_win(file_win)

  local current_win = vim.api.nvim_get_current_win()
  local default_opts = {
    cmd = cmd,
    sleep = 3,
    hidden = false,
    direction = "horizontal",
    on_create = function()
      vim.api.nvim_set_current_win(current_win)
      vim.api.nvim_input('<Esc>')
    end,
    auto_scroll = true,
    on_exit = function(_, _, exit_code)
      notify_exit_code(cmd)(exit_code)
    end,
  }
  table_override(default_opts, opts)
  local delimiter = "FN_TOGGLETERM_CMD_EOF"
  local echo_cmd = 'cat << "'..delimiter..'"\n'..cmd..'\n'..delimiter
  local sleep_cmd = 'sleep '..default_opts.sleep
  default_opts.cmd = cmds_join({echo_cmd, default_opts.cmd, sleep_cmd})

  local Terminal = require("toggleterm.terminal").Terminal
  local term = Terminal:new(default_opts)
  term:toggle()
  vim.notify(cmd..'\n\n'..'EXECUTING...', vim.log.levels.INFO)
end

return toggleterm_cmd
