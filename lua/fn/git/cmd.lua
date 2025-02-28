local get_git_bash_path = require('fn.git.get-git-bash-path')
local toggleterm_cmd = require('fn.toggleterm.cmd')

return function(cmd)
  local git_bash_path = get_git_bash_path()
  if git_bash_path == nil then return end
  local default_cmd = 'bash '..git_bash_path..' '..cmd
  vim.ui.input({
    prompt = ' Git Push: Confirm',
    default = default_cmd
  }, function(cmd_confirmed)
		vim.notify('cmd: '..cmd_confirmed)
    if cmd_confirmed == nil then return end
    toggleterm_cmd(cmd_confirmed)
  end)
end
