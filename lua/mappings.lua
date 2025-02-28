require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("v","<C-C>",
  function()
    vim.cmd('normal! "ay')
    local text = vim.fn.getreg('a')
    text = text:gsub("\n*$", "")
    local delimiter = 'FN_TERMUX_COPY_EOF'
    local cmd = 'cat << "'..delimiter..'" | termux-clipboard-set\n'..text..'\n'..delimiter
    vim.fn.jobstart(cmd, {
      on_stdout = function()
        vim.notify("Copied")
      end
    })
  end
)

local _gitbashpath = function()
  local buf_path = vim.api.nvim_buf_get_name(0)
  local buf_dir = vim.fn.fnamemodify(buf_path, ":h")
  local repo_dir = vim.fn.systemlist("git -C "..buf_dir.." rev-parse --show-toplevel")[1]
  -- return repo_dir.."/git.bash"
  local git_bash_path = repo_dir.."/git.bash"
  if not vim.loop.fs_stat(git_bash_path) then
    vim.notify("no git.bash in repo", vim.log.levels.WARN)
    return nil
  end
  return git_bash_path
end

local _git = function(git_args)
  local gitbashpath = _gitbashpath()
  if not gitbashpath then return end
  local cmd = 'bash '.._gitbashpath()..' '..git_args
  vim.notify(cmd)
  vim.fn.jobstart(cmd, {
    on_stdout = function()
      vim.notify("Saved")
    end
  })
  -- vim.ui.input(
  --   {
  --     prompt = ' Git Push: Confirm',
  --     default = cmd
  --   },
  --   function(cmd_confirmed)
  --     -- if cmd_confirmed == nil then return end
  --     vim.fn.jobstart(cmd_confirmed, {
  --       on_stdout = function()
  --         vim.notify("Copied")
  --       end
  --     })
  --   end
  -- )
end

map("n", "<C-S>", function() _git("push") end)
