require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("v","<C-C>", require('fn.termux.copy'))

local _git = require('fn.git.cmd')
map("n", "<Leader>g", "", { desc = "Git" })
map("n", "<Leader>g<C-S>", function() _git('push') end, { desc = "Push" })

map("n", "<Leader>g<C-L>", function() _git("login") end,
  { desc = "Login" })
