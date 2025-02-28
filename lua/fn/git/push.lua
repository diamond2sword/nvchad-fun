local git_cmd = require('fn.git.cmd')

return function()
  git_cmd('push \"\'update project\'\"')
end

-- local get_git_bash_path = require('plugins.user.fn.git.get-git-bash-path')
-- local toggleterm_cmd = require('plugins.user.fn.toggleterm.cmd')
--
-- return function()
--   local git_bash_path = get_git_bash_path()
--   if git_bash_path == nil then return end
--   local default_cmd = 'bash '..git_bash_path..' push \"\'Update project\'\"'
--   vim.ui.input({
--     prompt = ' Git Push: Confirm',
--     default =  default_cmd
--   }, function(cmd)
--     if cmd == nil then return end
--     toggleterm_cmd(cmd)
--   end)
-- end
